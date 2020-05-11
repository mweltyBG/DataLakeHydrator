



CREATE PROCEDURE [etl].[JobAuditStart] (
	@JobName NVARCHAR(500) = 'default',
	@DataFactoryName NVARCHAR(200) = 'unknown'
)
AS

SET @JobName = ISNULL(NULLIF(@JobName, ''), 'default')

DECLARE @IdentityValue int, @MasterProcessNumber int, @Parallelism int;

-- David 2020-04-15: explore whether setting job parallelism for ADF pipelines makes sense
--SELECT @Parallelism = JobParallelism FROM ETL.JobParallelism WHERE JobConfiguration = @JobConfiguration;

-- Check to see the last status of this job. For restartability, if the job failed last time then attempt to pick up where it left off.
-- If the job is the default job, then check the KeyValueConfig table to see whether restartability for the default job has been enabled or not. 
-- If the setting does not exist in KeyValueConfig, then assume no restartability on the default job 
-- (i.e. by default the default job does not attempt to restart if the last default job failed. instead it performs a completely fresh run each time)

DECLARE @checkLastJobExecution BIT
IF @JobName = 'default'
	SET @checkLastJobExecution = (SELECT COUNT(*) FROM etl.KeyValueConfig WHERE ConfigKey = 'EnableRestartabilityForDefaultJob' AND ConfigValue = 'true')
ELSE
	SET @checkLastJobExecution = 1

DECLARE @attemptJobRestart BIT = 0 -- controls whether the ETL will ultimately attempt to pick up from a prior job execution
DECLARE @restartJobAuditKey INT -- if a restart needs to be attempted, this is the JobAuditKey that it will try to restart
IF @checkLastJobExecution = 1
BEGIN
	-- look in the JobAudit table for the most recent (as determined by job StartTime. if the job is marked as failed, then attempt a restart of that job
	SELECT TOP 1 @restartJobAuditKey = JobAuditKey, @attemptJobRestart = 1
	FROM etl.JobAudit
	LEFT OUTER JOIN etl.Job
		ON JobAudit.JobKey = Job.JobKey
	
	WHERE (Job.JobName = @JobName OR (@JobName = 'default' AND JobAudit.JobKey = 0))
		AND JobAudit.Status = 'failed'
	ORDER BY JobAudit.StartTime DESC

END

-- if we are attempting a restart, then update the status on the JobAudit record and return the JobAuditKey from the stored proc.
-- otherwise, this is a fresh job run, in which case we need to prepare the work list of ETL tasks for this job

IF @attemptJobRestart = 1 AND @restartJobAuditKey > 0
BEGIN
	UPDATE etl.JobAudit SET RestartTime = GETUTCDATE(), Status = 'Restarting' WHERE JobAuditKey = @restartJobAuditKey

	-- return the existing JobAuditKey value
	SELECT @restartJobAuditKey AS JobAuditKey
END
ELSE
BEGIN
	-- we are not attempting a restart of a prior job. 
	-- this means we need to prepare the worklist of tasks for this job, create a row in the JobAudit table, and return the JobAuditKey from the new row
	DECLARE @newJobAuditKey INT
	DECLARE @JobStatus NVARCHAR(200) = 'Job created'

	-- first we need the job key. if we cannot find a job with the supplied JobName, then update the status message and throw an error
	DECLARE @JobKey INT = -1
	SELECT TOP 1 @JobKey = JobKey FROM etl.Job WHERE JobName = @JobName ORDER BY JobKey
	IF @JobKey = -1 AND @JobName != 'default'
	BEGIN
		DECLARE @ErrorMessage NVARCHAR(2048);
		SET @ErrorMessage =  'Error: job "' + @JobName + '" not found in the etl.Job table.';
		THROW 50000, @ErrorMessage, 1;
	END
	ELSE
	BEGIN
		INSERT INTO etl.JobAudit (JobKey, StartTime, Status, DataFactoryName)
		VALUES (@JobKey, GETUTCDATE(), @JobStatus, @DataFactoryName)

		DECLARE @JobAuditKey INT
		SET @JobAuditKey = SCOPE_IDENTITY()

		-- tasklist population: we'll query the etl.Task table and create a row in etl.TaskAudit for each Task that needs to be performed.
		-- every single task belongs to the "default" job
	
		INSERT INTO etl.TaskAudit (JobAuditKey, TaskKey, Status, IsRunning)
		SELECT DISTINCT
			@JobAuditKey
		,	Task.TaskKey
		,	'Task created' AS Status
		,	0 AS IsRunning
		FROM etl.Task
		LEFT OUTER JOIN etl.TaskJobBridge
			ON Task.TaskKey = TaskJobBridge.TaskKey
		LEFT OUTER JOIN etl.Job
			ON TaskJobBridge.JobKey = Job.JobKey
		WHERE (@JobName = 'default' OR Job.JobName = @JobName)
			AND ISNULL(Task.DisableAction, 0) != 1

		-- return the newly-created JobAuditKey value
		SELECT @JobAuditKey AS JobAuditKey
	END
END