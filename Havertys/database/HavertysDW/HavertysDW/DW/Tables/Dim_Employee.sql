﻿CREATE TABLE [DW].[Dim_Employee] (
    [Employee_sk]       INT           IDENTITY (1, 1) NOT NULL,
    [Employee_ID_nk]    VARCHAR (50)  NOT NULL,
    [EmployeeType_Code] VARCHAR (50)  NOT NULL,
    [EmployeeType_Name] VARCHAR (50)  NULL,
    [Sales_ID]          INT           NOT NULL,
    [WMS_ID]            INT           NOT NULL,
    [Driver_ID]         INT           NULL,
    [Designer_ID]       INT           NULL,
    [First_Name]        VARCHAR (50)  NOT NULL,
    [Last_Name]         VARCHAR (50)  NOT NULL,
    [Full_Name]         VARCHAR (100) NOT NULL,
    [Division_ID]       INT           NOT NULL,
    [Market_ID]         INT           NOT NULL,
    [Branch_ID]         INT           NOT NULL,
    [Common_Name]       VARCHAR (50)  CONSTRAINT [DF__Dim_Emplo__Commo__3F914C5E] DEFAULT ('') NOT NULL,
    [HashKey]           CHAR (40)     NULL,
    [SourceSystem_fk]   INT           NOT NULL,
    [ETLBatchID_Insert] INT           NOT NULL,
    [ETLBatchID_Update] INT           NOT NULL,
    CONSTRAINT [PK_Employee_sk] PRIMARY KEY CLUSTERED ([Employee_sk] ASC) WITH (DATA_COMPRESSION = PAGE)
);












GO
CREATE UNIQUE NONCLUSTERED INDEX [IUX_Employee_ID_nk]
    ON [DW].[Dim_Employee]([Employee_ID_nk] ASC) WITH (DATA_COMPRESSION = PAGE);



