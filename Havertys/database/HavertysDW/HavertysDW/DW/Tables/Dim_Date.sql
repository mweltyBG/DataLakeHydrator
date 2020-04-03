﻿CREATE TABLE [DW].[Dim_Date] (
    [Date_sk]                         INT          NOT NULL,
    [Isworkday_Store]                 TINYINT      NOT NULL,
    [Isworkday_Delivery]              TINYINT      NOT NULL,
    [Calendar_date]                   DATE         NOT NULL,
    [Calendar_name_sht]               VARCHAR (10) NOT NULL,
    [Calendar_name_lng]               VARCHAR (20) NOT NULL,
    [Calendar_year_day_number]        SMALLINT     NOT NULL,
    [Calendar_year_day_name]          VARCHAR (25) NOT NULL,
    [Calendar_quarter_day_number]     TINYINT      NOT NULL,
    [Calendar_quarter_day_name]       VARCHAR (20) NOT NULL,
    [Calendar_month_day_number]       TINYINT      NOT NULL,
    [Calendar_month_day_name]         VARCHAR (20) NOT NULL,
    [Calendar_weekday_number]         TINYINT      NOT NULL,
    [Calendar_weekday_code]           CHAR (3)     NOT NULL,
    [Calendar_weekday_name]           VARCHAR (30) NOT NULL,
    [Calendar_week_of_month_number]   TINYINT      NOT NULL,
    [Calendar_week_of_month_name]     VARCHAR (20) NOT NULL,
    [Calendar_week_of_year_number]    SMALLINT     NOT NULL,
    [Calendar_week_of_year_name]      VARCHAR (20) NOT NULL,
    [Calendar_weekbegin_date]         DATE         NULL,
    [Calendar_weekending_date]        DATE         NULL,
    [Calendar_weekending_name]        VARCHAR (20) NULL,
    [Calendar_month_number]           TINYINT      NOT NULL,
    [Calendar_month_code]             CHAR (3)     NOT NULL,
    [Calendar_month_name]             VARCHAR (10) NOT NULL,
    [Calendar_quarter_number]         TINYINT      NOT NULL,
    [Calendar_quarter_code]           CHAR (2)     NOT NULL,
    [Calendar_quarter_name]           VARCHAR (10) NOT NULL,
    [Calendar_month_week_year_number] INT          NOT NULL,
    [Calendar_month_week_year_code]   VARCHAR (20) NOT NULL,
    [Calendar_month_year_number]      INT          NOT NULL,
    [Calendar_month_year_code]        VARCHAR (8)  NOT NULL,
    [Calendar_quarter_year_number]    INT          NOT NULL,
    [Calendar_quarter_year_code]      VARCHAR (10) NOT NULL,
    [Calendar_quarter_year_name]      VARCHAR (15) NOT NULL,
    [Calendar_year_number]            INT          NOT NULL,
    [Calendar_year_name]              VARCHAR (4)  NOT NULL,
    [Reporting_week_number]           TINYINT      NULL,
    [Reporting_weekbegin_date]        DATE         NULL,
    [Reporting_weekending_date]       DATE         NULL,
    [Reporting_weekending_name]       VARCHAR (20) NULL,
    [Reporting_weekday_number]        TINYINT      NULL,
    [Reporting_month_number]          TINYINT      NULL,
    [Reporting_month_code]            CHAR (3)     NULL,
    [Reporting_month_name]            VARCHAR (10) NULL,
    [Reporting_quarter_number]        TINYINT      NULL,
    [Reporting_quarter_code]          CHAR (2)     NULL,
    [Reporting_quarter_name]          VARCHAR (10) NULL,
    [Reporting_month_year_number]     INT          NULL,
    [Reporting_month_year_code]       VARCHAR (8)  NULL,
    [Reporting_quarter_year_number]   INT          NULL,
    [Reporting_quarter_year_code]     VARCHAR (10) NULL,
    [Reporting_quarter_year_name]     VARCHAR (15) NULL,
    [Reporting_year_number]           INT          NULL,
    [Reporting_year_name]             VARCHAR (4)  NULL,
    [Holiday_name]                    VARCHAR (20) NULL,
    [SameDayOfWeekLastYear_date]      DATE         NULL,
    [SameDayOfWeekLastYear_fk]        INT          NULL,
    [ETLBatchID_Insert]               INT          NULL,
    [ETLBatchID_Update]               INT          NULL,
    CONSTRAINT [PK_Date_sk] PRIMARY KEY CLUSTERED ([Date_sk] ASC) WITH (DATA_COMPRESSION = PAGE)
);













