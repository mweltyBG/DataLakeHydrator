﻿CREATE TABLE [DW].[Dim_Product] (
    [Product_sk]            INT             IDENTITY (1, 1) NOT NULL,
    [ProductID]             INT             NULL,
    [ProductAlternateKey]   NVARCHAR (100)  NULL,
    [ProductSubcategoryKey] INT             NULL,
    [WeightUnitMeasureCode] NVARCHAR (100)  NOT NULL,
    [SizeUnitMeasureCode]   NVARCHAR (100)  NOT NULL,
    [EnglishProductName]    NVARCHAR (100)  NULL,
    [StandardCost]          DECIMAL (19, 4) NULL,
    [FinishedGoodsFlag]     INT             NOT NULL,
    [Color]                 NVARCHAR (100)  NULL,
    [SafetyStockLevel]      NVARCHAR (100)  NOT NULL,
    [ReorderPoint]          NVARCHAR (100)  NOT NULL,
    [ListPrice]             DECIMAL (19, 4) NULL,
    [Size]                  NVARCHAR (100)  NULL,
    [SizeRange]             NVARCHAR (100)  NOT NULL,
    [Weight]                DECIMAL (8, 2)  NULL,
    [DaysToManufacture]     NVARCHAR (100)  NOT NULL,
    [ProductLine]           NVARCHAR (100)  NOT NULL,
    [DealerPrice]           NVARCHAR (100)  NOT NULL,
    [Class]                 NVARCHAR (100)  NOT NULL,
    [Style]                 NVARCHAR (100)  NOT NULL,
    [ModelName]             NVARCHAR (100)  NULL,
    [EnglishDescription]    NVARCHAR (1000) NULL,
    [FrenchDescription]     NVARCHAR (1000) NULL,
    [ChineseDescription]    NVARCHAR (1000) NULL,
    [ArabicDescription]     NVARCHAR (1000) NULL,
    [HebrewDescription]     NVARCHAR (1000) NULL,
    [ThaiDescription]       NVARCHAR (1000) NULL,
    [GermanDescription]     NVARCHAR (1000) NOT NULL,
    [JapaneseDescription]   NVARCHAR (1000) NOT NULL,
    [TurkishDescription]    NVARCHAR (1000) NOT NULL,
    [StartDate]             DATETIME        NULL,
    [EndDate]               DATETIME        NULL,
    [Status]                NVARCHAR (MAX)  NOT NULL,
    [HashKey]               NVARCHAR (MAX)  NULL
);

