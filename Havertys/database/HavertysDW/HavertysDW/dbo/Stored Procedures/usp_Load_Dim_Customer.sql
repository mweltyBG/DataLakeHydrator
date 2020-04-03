﻿



CREATE PROCEDURE [dbo].[usp_Load_Dim_Customer] 
AS

UPDATE Dest
SET
 Dest.[Customer_Sequence_nk]		  = Staging.[Customer_Sequence_nk]
,Dest.[Customer_ID_nk]				  = Staging.[Customer_ID_nk]
,Dest.[Sequence_Status]				  = Staging.[Sequence_Status]
,Dest.[Bill_First_Name]				  = Staging.[Bill_First_Name]
,Dest.[Bill_Last_Name]				  = Staging.[Bill_Last_Name]
,Dest.[Bill_Name_Status]			  = Staging.[Bill_Name_Status]
,Dest.[Bill_Address]				  = Staging.[Bill_Address]
,Dest.[Bill_City]					  = Staging.[Bill_City]
,Dest.[Bill_State]					  = Staging.[Bill_State]
,Dest.[Bill_ZIP]					  = Staging.[Bill_ZIP]
,Dest.[Bill_ZIP4]					  = Staging.[Bill_ZIP4]
,Dest.[Bill_Latitude]				  = Staging.[Bill_Latitude]
,Dest.[Bill_Longitude]				  = Staging.[Bill_Longitude]
,Dest.[Bill_Address_Status]			  = Staging.[Bill_Address_Status]
,Dest.[Delivery_First_Name]			  = Staging.[Delivery_First_Name]
,Dest.[Delivery_Last_Name]			  = Staging.[Delivery_Last_Name]
,Dest.[Delivery_Name_Status]		  = Staging.[Delivery_Name_Status]
,Dest.[Delivery_Address]			  = Staging.[Delivery_Address]
,Dest.[Delivery_City]				  = Staging.[Delivery_City]
,Dest.[Delivery_State]				  = Staging.[Delivery_State]
,Dest.[Delivery_ZIP]				  = Staging.[Delivery_ZIP]
,Dest.[Delivery_ZIP4]				  = Staging.[Delivery_ZIP4]
,Dest.[Delivery_Latitude]			  = Staging.[Delivery_Latitude]
,Dest.[Delivery_Longitude]			  = Staging.[Delivery_Longitude]
,Dest.[Delivery_Address_Status]		  = Staging.[Delivery_Address_Status]
,Dest.[Customer_Profile_Created_Date] = Staging.[Customer_Profile_Created_Date]
,Dest.[Customer_First_Name]			  = Staging.[Customer_First_Name]
,Dest.[Customer_Last_Name]			  = Staging.[Customer_Last_Name]
,Dest.[Customer_Name_Status]		  = Staging.[Customer_Name_Status]
,Dest.[Customer_Address]			  = Staging.[Customer_Address]
,Dest.[Customer_City]				  = Staging.[Customer_City]
,Dest.[Customer_State]				  = Staging.[Customer_State]
,Dest.[Customer_ZIP]				  = Staging.[Customer_ZIP]
,Dest.[Customer_ZIP4]				  = Staging.[Customer_ZIP4]
,Dest.[Customer_Latitude]			  = Staging.[Customer_Latitude]
,Dest.[Customer_Longitude]			  = Staging.[Customer_Longitude]
,Dest.[Customer_Phone_Type]			  = Staging.[Customer_Phone_Type]
,Dest.[Customer_Phone]				  = Staging.[Customer_Phone]
,Dest.[Customer_Phone_Extension]	  = Staging.[Customer_Phone_Extension]
,Dest.[Customer_Phone_Status]		  = Staging.[Customer_Phone_Status]
,Dest.[Customer_Email]				  = Staging.[Customer_Email]
,Dest.[Customer_Email_Status]		  = Staging.[Customer_Email_Status]
,Dest.[Customer_Created_Date]		  = Staging.[Customer_Created_Date]
,Dest.[Customer_Status]				  = Staging.[Customer_Status]
,Dest.[No_Email]					  = Staging.[No_Email]
,Dest.[Room_Plan]					  = Staging.[Room_Plan]
,Dest.[Send_Advertising]			  = Staging.[Send_Advertising]
,Dest.[Send_Catalog]				  = Staging.[Send_Catalog]
,Dest.[Send_News]					  = Staging.[Send_News]
,Dest.[Send_P_Mail]					  = Staging.[Send_P_Mail]
,Dest.[HashKey]						  = Staging.[HashKey]
,Dest.[ETLBatchID_Update]			  = Staging.[ETLBatchID_Update]
FROM
[DW].[Dim_Customer] Dest
INNER JOIN [Updates].[Dim_Customer_Update] Staging ON Dest.Customer_sk = Staging.Customer_sk_Dest