﻿CREATE TABLE [Updates].[Dim_Product_Update] (
    [ProductID]             INT             NULL,
    [ProductAlternateKey]   NVARCHAR (MAX)  NOT NULL,
    [_nk]                   NVARCHAR (MAX)  NOT NULL,
    [ProductSubcategoryKey] INT             NULL,
    [WeightUnitMeasureCode] NVARCHAR (MAX)  NOT NULL,
    [SizeUnitMeasureCode]   NVARCHAR (MAX)  NOT NULL,
    [EnglishProductName]    NVARCHAR (MAX)  NOT NULL,
    [StandardCost]          DECIMAL (19, 4) NULL,
    [FinishedGoodsFlag]     INT             NOT NULL,
    [Color]                 NVARCHAR (MAX)  NOT NULL,
    [SafetyStockLevel]      NVARCHAR (MAX)  NOT NULL,
    [ReorderPoint]          NVARCHAR (MAX)  NOT NULL,
    [ListPrice]             DECIMAL (19, 4) NULL,
    [Size]                  NVARCHAR (MAX)  NOT NULL,
    [SizeRange]             NVARCHAR (MAX)  NOT NULL,
    [Weight]                DECIMAL (8, 2)  NULL,
    [DaysToManufacture]     NVARCHAR (MAX)  NOT NULL,
    [ProductLine]           NVARCHAR (MAX)  NOT NULL,
    [DealerPrice]           NVARCHAR (MAX)  NOT NULL,
    [Class]                 NVARCHAR (MAX)  NOT NULL,
    [Style]                 NVARCHAR (MAX)  NOT NULL,
    [ModelName]             NVARCHAR (MAX)  NOT NULL,
    [EnglishDescription]    NVARCHAR (MAX)  NOT NULL,
    [FrenchDescription]     NVARCHAR (MAX)  NOT NULL,
    [ChineseDescription]    NVARCHAR (MAX)  NOT NULL,
    [ArabicDescription]     NVARCHAR (MAX)  NOT NULL,
    [HebrewDescription]     NVARCHAR (MAX)  NOT NULL,
    [ThaiDescription]       NVARCHAR (MAX)  NOT NULL,
    [GermanDescription]     NVARCHAR (MAX)  NOT NULL,
    [JapaneseDescription]   NVARCHAR (MAX)  NOT NULL,
    [TurkishDescription]    NVARCHAR (MAX)  NOT NULL,
    [StartDate]             DATETIME        NULL,
    [EndDate]               DATETIME        NULL,
    [Status]                NVARCHAR (MAX)  NOT NULL,
    [HashKey]               NVARCHAR (MAX)  NOT NULL,
    [_sk_Dest]              INT             NULL,
    [_nk_Dest]              NVARCHAR (MAX)  NULL,
    [HashKey_Dest]          NVARCHAR (MAX)  NULL
);

