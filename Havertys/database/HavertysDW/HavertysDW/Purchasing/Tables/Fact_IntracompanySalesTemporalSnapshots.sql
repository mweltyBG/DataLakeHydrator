﻿CREATE TABLE [Purchasing].[Fact_IntracompanySalesTemporalSnapshots] (
    [Intracompany_Sales_sk]        INT            IDENTITY (1, 1) NOT NULL,
    [Ordered_Quantity]             INT            NULL,
    [Reserved_Quantity]            INT            NULL,
    [Cancelled_Quantity]           INT            NULL,
    [Invoice_Price]                DECIMAL (9, 2) NULL,
    [Delivered_Quantity]           INT            NULL,
    [Order_Date_fk]                INT            NOT NULL,
    [Delivery_Date_fk]             INT            NOT NULL,
    [Fully_Reserved_Date_fk]       INT            NOT NULL,
    [Created_Date_fk]              INT            NOT NULL,
    [Dont_Optimize_Untill_Date_fk] INT            NOT NULL,
    [Override_Reserve_Date_fk]     INT            NOT NULL,
    [Pending_Quick_Ship_Date_fk]   INT            NOT NULL,
    [From_Warehouse_Location_fk]   INT            NOT NULL,
    [To_Warehouse_Location_fk]     INT            NOT NULL,
    [Issue_Location_fk]            INT            NOT NULL,
    [Posted_Location_fk]           INT            NOT NULL,
    [SKU_fk]                       INT            NOT NULL,
    [SKU_History_fk]               INT            NOT NULL,
    [Transaction_Link_fk]          INT            NOT NULL,
    [ICS_Number_nk]                INT            NULL,
    [ICS_Line_Number_nk]           INT            NULL,
    [Division_nk]                  INT            NULL,
    [Market_nk]                    INT            NULL,
    [Status_Code]                  VARCHAR (50)   NULL,
    [Status]                       VARCHAR (50)   NULL,
    [Generation_Code]              VARCHAR (50)   NULL,
    [Generation]                   VARCHAR (50)   NULL,
    [Priority_Code]                VARCHAR (1)    NULL,
    [Priority]                     VARCHAR (50)   NULL,
    [Status_Line_Code]             VARCHAR (2)    NULL,
    [Status_Line]                  VARCHAR (50)   NULL,
    [Invoice_Price_Type_Code]      VARCHAR (1)    NULL,
    [Invoice_Price_Type]           VARCHAR (50)   NULL,
    [Reserve_Type_Code]            VARCHAR (2)    NULL,
    [Reserve_Type]                 VARCHAR (50)   NULL,
    [PO_Number]                    INT            NULL,
    [Sales_Rervation_Number]       INT            NULL,
    [Sales_Market]                 INT            NULL,
    [Pending_Docking_Number]       INT            NULL,
    [Pending_Docking_PO_Number]    INT            NULL,
    [Pending_Docking_PO_Line]      INT            NULL,
    [Procurement_Status_Code]      VARCHAR (2)    NULL,
    [Procurement_Status]           VARCHAR (50)   NULL,
    [EDI_Processed_Flag]           VARCHAR (1)    NULL,
    [Created_Fill_Group_Flag]      VARCHAR (1)    NULL,
    [Sales_Invoice_Printed_Flag]   VARCHAR (1)    NULL,
    [Buying_Distribution_Number]   INT            NULL,
    [Ready_To_Order_PO_Flag]       VARCHAR (1)    NULL,
    [Created_For_Dist_Flag]        VARCHAR (1)    NULL,
    [Layawy_Flag]                  VARCHAR (1)    NULL,
    [LP_Number]                    INT            NULL,
    [HashKey]                      CHAR (40)      NOT NULL,
    [Snapshot_StartDate]           DATE           NOT NULL,
    [Snapshot_EndDate]             DATE           NOT NULL,
    [Snapshot_Current_Flag]        BIT            NOT NULL,
    [SourceSystem_fk]              INT            NOT NULL,
    [ETLBatchID_Insert]            INT            NOT NULL,
    [ETLBatchID_Update]            INT            NOT NULL,
    CONSTRAINT [PK_Intracompany_Sales_sk] PRIMARY KEY NONCLUSTERED ([Intracompany_Sales_sk] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_Fact_IntracompanySalesTemporalSnapshots]
    ON [Purchasing].[Fact_IntracompanySalesTemporalSnapshots];
