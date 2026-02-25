CREATE TABLE Store_Dimension
(
  StoreKey INT NOT NULL,
  StoreID VARCHAR(3) NOT NULL,
  StoreZip CHAR(5) NOT NULL,
  RegionID CHAR(1) NOT NULL,
  Regionname VARCHAR(25) NOT NULL,
  PRIMARY KEY (StoreKey)
);

CREATE TABLE CustomerDimension
(
  CustomerKey INT NOT NULL,
  CustomerID CHAR(7) NOT NULL,
  CustomerName VARCHAR(15) NOT NULL,
  CustomerZip CHAR(5) NOT NULL,
  PRIMARY KEY (CustomerKey)
);

CREATE TABLE Calendar_Dimension
(
  CalendarKey INT NOT NULL,
  FullDate DATE NOT NULL,
  MonthYear INT NOT NULL,
  Year INT NOT NULL,
  PRIMARY KEY (CalendarKey)
);

CREATE TABLE ProductDimension
(
  ProductKey INT NOT NULL,
  Productid CHAR(3) NOT NULL,
  ProductName VARCHAR(25) NOT NULL,
  SalesProductPrice NUMERIC(7,2) NOT NULL,
  ProductType VARCHAR(20) NOT NULL,
  VendorID CHAR(2) NOT NULL,
  VendorName VARCHAR(25) NOT NULL,
  CatergoryID CHAR(2) NOT NULL,
  CatergoryName VARCHAR(25) NOT NULL,
  RentalProductPriceDaily NUMERIC(7,2) NOT NULL,
  RentalProductPriceWeekly NUMERIC(7,2) NOT NULL,
  PRIMARY KEY (ProductKey)
);


---Revenue Fact Table for Data Staging
CREATE TABLE Revenue_Fact_Table
(
  DollarsGenerated NUMERIC(7,2) NOT NULL,
  Unitssold INT NOT NULL,
  TID VARCHAR(8) NOT NULL,
  StoreKey INT NOT NULL,
  CustomerKey INT NOT NULL,
  CalendarKey INT NOT NULL,
  ProductKey INT NOT NULL,
  PRIMARY KEY (StoreKey, CustomerKey, CalendarKey, ProductKey, TID)
);

----Revenue Fact Table for DataWarehouse 
CREATE TABLE Revenue_Fact_Table
(
  DollarsGenerated NUMERIC(7,2) NOT NULL,
  Unitssold INT NOT NULL,
  TID VARCHAR(8) NOT NULL,
  StoreKey INT NOT NULL,
  CustomerKey INT NOT NULL,
  CalendarKey INT NOT NULL,
  ProductKey INT NOT NULL,
  PRIMARY KEY (StoreKey, CustomerKey, CalendarKey, ProductKey, TID),
  FOREIGN KEY (StoreKey) REFERENCES Store_Dimension(StoreKey),
  FOREIGN KEY (CustomerKey) REFERENCES CustomerDimension(CustomerKey),
  FOREIGN KEY (CalendarKey) REFERENCES Calendar_Dimension(CalendarKey),
  FOREIGN KEY (ProductKey) REFERENCES ProductDimension(ProductKey)
);

CREATE TABLE Store_Dimension
(
  StoreKey INT NOT NULL,
  StoreID VARCHAR(3) NOT NULL,
  StoreZip CHAR(5) NOT NULL,
  RegionID CHAR(1) NOT NULL,
  Regionname VARCHAR(25) NOT NULL,
  PRIMARY KEY (StoreKey)
);

CREATE TABLE CustomerDimension
(
  CustomerKey INT NOT NULL,
  CustomerID CHAR(7) NOT NULL,
  CustomerName VARCHAR(15) NOT NULL,
  CustomerZip CHAR(5) NOT NULL,
  PRIMARY KEY (CustomerKey)
);

CREATE TABLE Calendar_Dimension
(
  CalendarKey INT NOT NULL,
  FullDate DATE NOT NULL,
  MonthYear INT NOT NULL,
  Year INT NOT NULL,
  PRIMARY KEY (CalendarKey)
);

CREATE TABLE ProductDimension
(
  ProductKey INT NOT NULL,
  Productid CHAR(3) NOT NULL,
  ProductName VARCHAR(25) NOT NULL,
  SalesProductPrice NUMERIC(7,2) NOT NULL,
  ProductType VARCHAR(20) NOT NULL,
  VendorID CHAR(2) NOT NULL,
  VendorName VARCHAR(25) NOT NULL,
  CatergoryID CHAR(2) NOT NULL,
  CatergoryName VARCHAR(25) NOT NULL,
  RentalProductPriceDaily NUMERIC(7,2) NOT NULL,
  RentalProductPriceWeekly NUMERIC(7,2) NOT NULL,
  PRIMARY KEY (ProductKey)
);

CREATE TABLE Revenue_Fact_Table
(
  DollarsGenerated NUMERIC(7,2) NOT NULL,
  Unitssold INT NOT NULL,
  TID VARCHAR(8) NOT NULL,
  StoreKey INT NOT NULL,
  CustomerKey INT NOT NULL,
  CalendarKey INT NOT NULL,
  ProductKey INT NOT NULL,
  PRIMARY KEY (StoreKey, CustomerKey, CalendarKey, ProductKey, TID)
);



INSERT INTO ProductDimension(ProductID, ProductName, SalesProductPrice, ProductType, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly)
SELECT p.productid, p.productname, p.productprice, 'Sales Product', v.vendorid, v.vendorname, c.categoryid, c.categoryname, NULL, NULL
FROM mushamrn_F25_ZAGIMORE.product p , mushamrn_F25_ZAGIMORE.vendor v, mushamrn_F25_ZAGIMORE.category c
WHERE p.categoryid = c.categoryid  AND v.vendorid = p.vendorid
UNION
SELECT r.productid, r.productname, NULL, 'Rental Product', v.vendorid, v.vendorname, c.categoryid, c.categoryname, r.productpricedaily, r.productpriceweekly
FROM mushamrn_F25_ZAGIMORE.rentalProducts r , mushamrn_F25_ZAGIMORE.vendor v, mushamrn_F25_ZAGIMORE.category c
WHERE r.categoryid = c.categoryid  AND v.vendorid = r.vendorid;



INSERT INTO StoreDimension(RegionID, RegionName, StoreID, StoreZIP)
SELECT re.regionid, re.regionname, s.storeid, s.storezip
FROM mushamrn_F25_ZAGIMORE.store s, mushamrn_F25_ZAGIMORE.region re
WHERE re.regionid = s.regionid;



INSERT INTO CustomerDimension(CustomerID, CustomerName, CustomerZIP)
SELECT c.customerid, c.customername, c.customerzip
FROM mushamrn_F25_ZAGIMORE.customer c;




-- EXTRACTING SALES REVENUE FACTS
SELECT sv.noofitems as Unitssold , sv.noofitems*pr.productprice as DollarsGenerated , sv.tid as TID , "Sales" as RevenueType,pr.productid,st.customerid,st.storeid,st.tdate
FROM mushamrn_F25_ZAGIMORE.salestransaction st, mushamrn_F25_ZAGIMORE.soldvia sv,
mushamrn_F25_ZAGIMORE.product pr
WHERE pr.productid= sv.productid
AND sv.tid=st.tid


-- EXTRACTING RENTAL REVENUE FACTS
SELECT rv.duration as Unitssold, rv.duration*rp.productpricedaily as DollarsGenerated,rv.tid as TID, "Rental ,Daily " as RevenueType,rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt, mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rv.tid=rt.tid
AND rv.rentaltype='D'
UNION
SELECT rv.duration as Unitssold, rv.duration*rp.productpriceweekly as DollarsGenerated,rv.tid as TID, "Rental ,Weekly " as RevenueType,rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt, mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rv.tid=rt.tid
AND rv.rentaltype='W'



SELECT rv.duration as Unitssold, rv.duration*rp.productpricedaily as DollarsGenerated,rv.tid as TID, "Rental ,Daily " as RevenueType,rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt, mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rv.tid=rt.tid
AND rv.rentaltype='D'
UNION
SELECT rv.duration as Unitssold, rv.duration*rp.productpriceweekly as DollarsGenerated,rv.tid as TID, "Rental ,Weekly " as RevenueType,rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt, mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rv.tid=rt.tid
AND rv.rentaltype='W'



DROP TABLE IF EXISTS IFT;

CREATE TABLE IFT as I
SELECT sv.noofitems as UnitsSold,sv.noofitems*pr.productprice as DollarsGenerated, sv.tid as TID, "Sales" as RevenueType,pr-productid,
st.customerid,st.storeid,st.tdate
FROM mushamrn_F25_ZAGIMORE.salestransaction st, mushamrn_F25_ZAGIMORE.soldvia sV,
mushamrn_F25_ZAGIMORE.product pr
WHERE pr. productid= sv.productid
AND sv.tid=st.tid
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpricedaily as DollarsGenerated,rv.tid as TID, "Rental,daily" as RevenueType, rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt,mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE. rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "D"
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpriceweekly as DollarsGenerated,rv.tid as TID, "Rental,weekly" as RevenueType, rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt,mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "W";




--INSERT DATA INTO THE FACT TABLE

SELECT i.RevenueType, i. TID, i.UnitsSold,i.DollarsGenerated, pd.productkey,cc.calendarkey,cd.customerkey,sd.storekey
FROM IFT i, ProductDimension pd, CustomerDimension cd, StoreDimension sd, CalendarDimension co
WHERE i.productid= pd.productid
AND i. customerid= cd.customerid
AND
i.storeid= sd.storeid
AND
i.tdate= cc.FullDate
AND
LEFT (i.RevenueType,1)=LEFT(pd.producttype, 1)


---Populate the fact table
					
INSERT INTO Revenue_Fact_Table (RevenueType,TID, UnitsSold,DollarsGenerated,ProductKey,CalendarKey,CustomerKey,StoreKey)
SELECT i.RevenueType, i.TID, i.UnitsSold,i.DollarsGenerated, pd.productkey,cc.calendarkey,cd.customerkey,sd.storekey
FROM IFT i, ProductDimension pd, CustomerDimension cd, StoreDimension sd, CalendarDimension cc
WHERE i.productid= pd.productid
AND i.customerid= cd.customerid
AND
i.storeid= sd.storeid
AND
i.tdate= cc.FullDate
AND
LEFT (i.RevenueType,1)=LEFT(pd.producttype, 1)

---loading from Data Staging to Datawarehouse 

INSERT INTO mushamrn_F25_ZAGIMORE_DW.ProductDimension(ProductKey,ProductID,ProductName,SalesProductPrice,ProductType,VendorID,VendorName,
CategoryID,CategoryName,RentalProductPriceDaily,RentalProductPriceWeekly)
SELECT ProductKey,ProductID,ProductName,SalesProductPrice,ProductType,VendorID,VendorName,
CategoryID,CategoryName,RentalProductPriceDaily,RentalProductPriceWeekly
FROM ProductDimension



INSERT INTO mushamrn_F25_ZAGIMORE_DW.CustomerDimension(CustomerKey,CustomerID,CustomerName,CustomerZip)
SELECT 
CustomerKey,
CustomerID,
CustomerName,
CustomerZip
FROM 
CustomerDimension



INSERT INTO mushamrn_F25_ZAGIMORE_DW.StoreDimension(StoreKey,StoreID,StoreZip,RegionID,RegionName)
SELECT 	
StoreKey,
StoreID,
StoreZip,
RegionID,
RegionName
FROM StoreDimension


---insterting into DW 

INSERT INTO mushamrn_F25_ZAGIMORE_DW.Revenue_Fact_Table(
DollarsGenerated,
UnitsSold,
TID,
RevenueType,
ProductKey,
StoreKey,
CustomerKey,
CalendarKey)

SELECT
DollarsGenerated,
UnitsSold,
TID,
RevenueType,
ProductKey,
StoreKey,
CustomerKey,
CalendarKey
FROM Revenue_Fact_Table
-----adding product cat to dw
CREATE TABLE mushamrn_F25_ZAGIMORE_DW.Product_cat_dimension
SELECT * FROM Product_cat_dimension
 
---- snapshots 

CREATE TABLE Product_cat_dimension AS
SELECT DISTINCT p.categoryID, p.Categoryname
FROM ProductDimension as p;

ALTER TABLE Product_cat_dimension
ADD COLUMN Product_Cat_Key INT AUTO_INCREMENT Primary Key;


---- Creating One Way Aggregation by Product Category 

CREATE TABLE One_Way_Revenue_Agg_By_Product_Cat AS
SELECT SUM(r.UnitsSold) AS TotalUnitSold, SUM(r.DollarsGenerated) AS
TotalRevenueGenerated,
r.CalendarKey, r.CustomerKey, r.StoreKey, pcd.Product_Cat_Key
FROM Revenue_Fact_Table AS r, Product_cat_dimension AS pcd, ProductDimension AS pd
WHERE r.ProductKey = pd.ProductKey
AND
pcd.categoryID = pd.categoryID
GROUP BY r.CalendarKey, r.CustomerKey, r.StoreKey, pcd.Product_Cat_Key;

--spot check 

SELECT * 
FROM Revenue_Fact_Table 
WHERE calendarkey=4 AND CustomerKey=5 AND StoreKey=6

ALTER TABLE One_Way_Revenue_Agg_By_Product_Cat
ADD PRIMARY KEY(Calendar_Key, CustomerKey, StoreKey, Product_Cat_Key);
	
----iNTIAL LOAD OF THE 

CREATE TABLE mushamrn_F25_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat AS 
SELECT * 
FROM  One_Way_Revenue_Agg_By_Product_Cat 

------ Adding the foreign keys 
ALTER TABLE mushamrn_F25_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat
ADD FOREIGN KEY(CalendarKey) REFERENCES mushamrn_F25_ZAGIMORE_DW.CalendarDimension(CalendarKey)
ADD FOREIGN KEY(CustomerKey) REFERENCES mushamrn_F25_ZAGIMORE_DW.CustomerDimension(CustomerKey)
ADD FOREIGN KEY(StoreKey) REFERENCES mushamrn_F25_ZAGIMORE_DW.StoreDimension(StoreKey)
ADD FOREIGN KEY(Product_Cat_Key) REFERENCES mushamrn_F25_ZAGIMORE_DW.Product_cat_dimension(Product_Cat_Key)

----One way aggregation by ZIP --- Homework 

CREATE TABLE One_Way_Revenue_Agg_By_Product_catAS
SELECT SUM(r.UnitsSold) AS TotalUnitSold, SUM(r.DollarsGenerated) AS
TotalRevenueGenerated,
r.CalendarKey, r.CustomerKey, r.StoreKey, pcd.Product_Cat_Key
FROM Revenue_Fact_Table AS r, ProductDimension AS pd
WHERE r.ProductKey = pd.ProductKey
AND
pcd.categoryID = pd.categoryID
GROUP BY r.CalendarKey, r.CustomerKey, r.StoreKey, pcd.Product_Cat_Key;


CREATE TABLE One_Way_Revenue_Agg_By_Customer_Zip AS
SELECT 
    SUM(r.UnitsSold) AS TotalUnitsSold, 
    SUM(r.DollarsGenerated) AS TotalRevenueGenerated
    r.CalendarKey, 
    r.StoreKey, 
    r.ProductKey,
    cd.CustomerZip,
FROM Revenue_Fact_Table AS r ,CustomerDimension AS cd 
WHERE  r.CustomerKey = cd.CustomerKey
GROUP BY 
    r.CalendarKey, 
    r.StoreKey, 
    r.ProductKey,
    cd.CustomerZip;


ALTER TABLE `One_Way_Revenue_Agg_By_Customer_Zip` 
ADD PRIMARY KEY(`CalendarKey`, `StoreKey`, `ProductKey`, `CustomerZip`);

ALTER TABLE mushamrn_F25_ZAGIMORE_DW.One_Way_Revenue_Agg_By_CustomerZip
ADD FOREIGN KEY(CalendarKey) REFERENCES mushamrn_F25_ZAGIMORE_DW.CalendarDimension(CalendarKey)
ADD FOREIGN KEY(StoreKey) REFERENCES mushamrn_F25_ZAGIMORE_DW.StoreDimension(StoreKey)
ADD FOREIGN KEY(ProductKey) REFERENCES mushamrn_F25_ZAGIMORE_DW.ProductDimension(ProductKey)


---- creating a snapshot
CREATE TABLE Daily_Store_Snapshot AS 
SELECT SUM(r.UnitsSold) AS TotalUnitSold, SUM(r.DollarsGenerated) AS
TotalRevenueGenerated,
COUNT(DISTINCT r.TID) AS TotalNumberOfTransactions, AVG(r.DollarsGenerated)
AS AverageRevenueGenerated, r.CalendarKey, r.StoreKey
FROM Revenue_Fact_Table AS r
GROUP BY r.CalendarKey, r.StoreKey;

ALTER TABLE Daily_Store_Snapshot
MODIFY COLUMN AverageRevenueGenerated DECIMAL(9,2);

ALTER TABLE `Daily_Store_Snapshot` ADD PRIMARY KEY(`CalendarKey`, `StoreKey`);

------ Adding metrics to the dily snap shots
ALTER TABLE Daily_Store_Snapshot
ADD Footwear_Revenue DECIMAL(9,2),
ADD High_Revenue_trx_cnt INT,
ADD Local_Revenue INT 



CREATE TABLE LR AS 
SELECT  SUM(r.DollarsGenerated) AS
Local_Revenue, r.CalendarKey, r.StoreKey
FROM Revenue_Fact_Table AS r , StoreDimension AS sd, CustomerDimension AS cd
WHERE r.StoreKey= sd.StoreKey
AND r.CustomerKey= cd.CustomerKey
AND LEFT(cd.CustomerZip,2)= LEFT(sd.StoreZip,2)
GROUP BY r.CalendarKey, r.StoreKey;

UPDATE Daily_Store_Snapshot ds, LR
SET ds.Local_Revenue= LR.Local_Revenue
WHERE ds.CalendarKey= LR.CalendarKey
AND ds.StoreKey= LR.StoreKey;
 

UPDATE Daily_Store_Snapshot ds
SET Local_Revenue=0
WHERE ds.Local_Revenue IS NULL;





CREATE TABLE ETC AS
SELECT COUNT(DISTINCT TID) AS High_Revenue_trx_cnt, Storekey, CalendarKey
FROM Revenue_Fact_Table
WHERE TID IN (
    SELECT TID
    FROM Revenue_Fact_Table
    GROUP BY TID
    HAVING SUM(DollarsGenerated) > 100
)
GROUP BY StoreKey, CalendarKey


---CREATING A TABLE FOOTWARE TABLE AND REPLACING  A COLUMN IN THE DAILY SNAPSHOT TABLE

CREATE TABLE FootwearRevenue AS
SELECT SUM(r.DollarsGenerated) AS TotalfootwearRevenue,  r.CalendarKey, r.StoreKey
FROM Revenue_Fact_Table AS r, ProductDimension AS pd
WHERE pd.CategoryName = "Footwear"
AND pd.ProductKey = r.ProductKey
GROUP BY r.CalendarKey, r.StoreKey;


UPDATE Daily_Store_Snapshot ds, FootwearRevenue fw
SET ds.Footwear_Revenue = fw.TotalfootwearRevenue
WHERE ds.CalendarKey = fw.CalendarKey
AND ds.StoreKey = fw.StoreKey;


UPDATE Daily_Store_Snapshot
SET footwear_revenue=0 WHERE footwear_revenue IS NULL


--UPDATING THE COUNT OF THE HIGH REVENUE TRANS COUNT IN THE SNAPSHOT TABLE

UPDATE Daily_Store_Snapshot ds, ETC e
SET ds.high_revenue_tran_count = e.high_revenue_tran_count;
WHERE ds.StoreKey= e.StoreKey
AND ds.CalendarKey = e.CalendarKey


UPDATE Daily_Store_Snapshot
SET high_revenue_tran_count=0
WHERE high_revenue_tran_count IS NULL

----- repurpose and tweaking 
----Daily Refresh of Fact table 

ALTER TABLE Revenue_Fact_Table 
ADD Extraction_time_stamp TIMESTAMP,
 ADD F_loaded BOOLEAN;

UPDATE Revenue_Fact_Table
SET Extraction_time_stamp =NOW()- INTERVAL 5 DAY,

UPDATE Revenue_Fact_Table
SET F_loaded= TRUE


INSERT INTO mushamrn_F25_ZAGIMORE.salestransaction VALUES ('Z022','9-0-111','S5','2025-11-11');
 
INSERT INTO mushamrn_F25_ZAGIMORE.soldvia VALUES('1X1','Z022',1);
INSERT INTO mushamrn_F25_ZAGIMORE.soldvia VALUES('2X2','Z022',1);


INSERT INTO mushamrn_F25_ZAGIMORE.rentaltransaction(tid, customerid, storeid, tdate) VALUES('R1','6-7-888','S7','2025-11-11');
 
INSERT INTO mushamrn_F25_ZAGIMORE.rentvia(productid, tid, rentaltype, duration) VALUES ('4X4','R1','W',2);
INSERT INTO mushamrn_F25_ZAGIMORE.rentvia(productid, tid, rentaltype, duration) VALUES ('5X5','R1','D',3);

----SPOT CHECKING THE RECORD COUNTS BEFORE AND AFTER THE REFRESH
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE.soldvia
UNION 
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE.rentvia
UNION
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table
UNION 
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DW.Revenue_Fact_Table


----EXTRACTING THE NEW FACTS THAT OCCURED SINCE THE LAST REFRESH
DROP TABLE IF EXISTS IFT;
CREATE TABLE IFT AS
SELECT sv.noofitems as UnitsSold,sv.noofitems*pr.productprice as DollarsGenerated, sv.tid as TID, "Sales" as RevenueType,pr.productid,
st.customerid,st.storeid,st.tdate
FROM mushamrn_F25_ZAGIMORE.salestransaction st, mushamrn_F25_ZAGIMORE.soldvia sv,
mushamrn_F25_ZAGIMORE.product pr
WHERE pr.productid= sv.productid
AND sv.tid=st.tid
AND st.tdate > (SELECT(MAX(DATE(Extraction_time_stamp))) FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table)
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpricedaily as DollarsGenerated,rv.tid as TID, "Rental,daily" as RevenueType, rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt,mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "D"
AND rt.tdate >(SELECT (MAX(DATE(Extraction_time_stamp))) FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table)
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpriceweekly as DollarsGenerated,rv.tid as TID, "Rental,weekly" as RevenueType, rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt,mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "W"
AND rt.tdate >(SELECT (MAX(DATE(Extraction_time_stamp))) FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table)


INSERT INTO Revenue_Fact_Table (CalendarKey,CustomerKey,DollarsGenerated,ProductKey,StoreKey,TID,UnitsSold,Revenue_Type)
SELECT cc.calendarkey,cd.customerkey,i.DollarsGenerated,pd.productkey,sd.storekey,i.TID, i.UnitsSold,i.Revenue_Type
FROM IFT i, ProductDimension pd, CustomerDimension cd, StoreDimension sd, CalendarDimension cc
WHERE i.productid= pd.productid
AND i.customerid= cd.customerid
AND
i.storeid= sd.storeid
AND
i.tdate= cc.FullDate
AND
LEFT (i.Revenue_Type,1)=LEFT(pd.producttype, 1)



INSERT INTO Revenue_Fact_Table (
DollarsGenerated,
UnitsSold,
TID,
RevenueType,
ProductKey,
StoreKey,
CustomerKey,
CalendarKey,
Extraction_time_stamp,
F_loaded)
SELECT i.UnitsSold AS UnitsSold, i.DollarsGenerated AS DollarsGenerated, i.TID as TID, i.RevenueType AS RevenueType, pd.ProductKey, sd.StoreKey, cd.CustomerKey, cc.CalendarKey, NOW(), FALSE
FROM IFT i, ProductDimension pd, StoreDimension sd, CalendarDimension cc, CustomerDimension cd
WHERE i.productid = pd.productid
AND i.storeid = sd.storeid
AND i.customerid = cd.customerid
AND i.tdate = cc.FullDate
AND LEFT(i.RevenueType,1) = LEFT(pd.ProductType,1);


SELECT DollarsGenerated, UnitsSold, TID, RevenueType,ProductKey,CalendarKey,CustomerKey,StoreKey
FROM Revenue_Fact_Table
WHERE F_loaded= FALSE;

UPDATE Revenue_Fact_Table
SET F_loaded= TRUE


INSERT INTO mushamrn_F25_ZAGIMORE.customer VALUES('9-0-112','Ritcher','46202')
INSERT INTO mushamrn_F25_ZAGIMORE.customer VALUES('9-0-113','Smith','46203')
INSERT INTO mushamrn_F25_ZAGIMORE.customer VALUES('9-0-114','Johnson','46204');


----------------
SELECT CustomerID 
FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension


SELECT c.CustomerID,c.CustomerName, c.CustomerZip, NOW(), FALSE
FROM mushamrn_F25_ZAGIMORE.Customer c
WHERE c.CustomerID NOT IN (
    SELECT cd.CustomerID
    FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd
);

ALTER TABLE mushamrn_F25_ZAGIMORE_DS.CustomerDimension
ADD Extraction_time_stamp TIMESTAMP,
ADD F_loaded BOOLEAN 


UPDATE mushamrn_F25_ZAGIMORE_DS.CustomerDimension
SET Extraction_time_stamp = NOW() - INTERVAL 7 DAY,
F_loaded = TRUE;


INSERT INTO mushamrn_F25_ZAGIMORE_DS.CustomerDimension (CustomerID, CustomerName, CustomerZip, Extraction_time_stamp, F_loaded)
SELECT c.CustomerID, c.CustomerName, c.CustomerZip, NOW(), FALSE
FROM mushamrn_F25_ZAGIMORE.customer c
WHERE c.CustomerID NOT IN (
    SELECT cd.CustomerID
    FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd
);

INSERT INTO mushamrn_F25_ZAGIMORE_DW.CustomerDimension (CustomerKey, CustomerID, CustomerName, CustomerZip)
SELECT cd.CustomerKey, cd.CustomerID, cd.CustomerName, cd.CustomerZip
FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd
WHERE cd.F_loaded = FALSE;

UPDATE mushamrn_F25_ZAGIMORE_DS.CustomerDimension
SET F_loaded = TRUE
WHERE F_loaded = FALSE;




------Creating a procedure 



CREATE PROCEDURE Refresh_Customer_Dimension()
BEGIN
INSERT INTO mushamrn_F25_ZAGIMORE_DS.CustomerDimension (CustomerID, CustomerName, CustomerZip, Extraction_time_stamp, F_loaded)
SELECT c.CustomerID, c.CustomerName, c.CustomerZip, NOW(), FALSE
FROM mushamrn_F25_ZAGIMORE.customer c
WHERE c.CustomerID NOT IN (
    SELECT cd.CustomerID
    FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd
);

INSERT INTO mushamrn_F25_ZAGIMORE_DW.CustomerDimension (CustomerKey, CustomerID, CustomerName, CustomerZip)
SELECT cd.CustomerKey, cd.CustomerID, cd.CustomerName, cd.CustomerZip
FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd
WHERE cd.F_loaded = FALSE;

UPDATE mushamrn_F25_ZAGIMORE_DS.CustomerDimension
SET F_loaded = TRUE
WHERE F_loaded = FALSE;
END


 
------------------   
----Store Dimension Refresh Procedure
ALTER TABLE mushamrn_F25_ZAGIMORE_DS.StoreDimension
ADD Extraction_time_stamp TIMESTAMP,
ADD F_loaded BOOLEAN ;

UPDATE mushamrn_F25_ZAGIMORE_DS.StoreDimension
SET Extraction_time_stamp = NOW() - INTERVAL 7 DAY,
F_loaded = TRUE;

INSERT INTO `store` (`storeid`, `storezip`, `regionid`) VALUES ('S15', '13676', 'T');
INSERT INTO `store` (`storeid`, `storezip`, `regionid`) VALUES ('S16', '12345', 'N'), ('S17', '13676', 'I');


 CREATE PROCEDURE Refresh_Store_Dimension()
    BEGIN
    INSERT INTO mushamrn_F25_ZAGIMORE_DS.StoreDimension 
       (StoreID, StoreZip, RegionID, RegionName, Extraction_time_stamp, F_loaded)
SELECT 
       s.storeid, 
       s.storezip, 
       s.regionid, 
       r.regionname, 
       NOW(), 
       FALSE
FROM 
       mushamrn_F25_ZAGIMORE.store  s,
       mushamrn_F25_ZAGIMORE.region r
WHERE 
       s.regionid = r.regionid
       AND s.storeid NOT IN (
            SELECT sd.storeid 
            FROM mushamrn_F25_ZAGIMORE_DS.StoreDimension sd
       );

    INSERT INTO mushamrn_F25_ZAGIMORE_DW.StoreDimension (StoreKey, StoreID, StoreZip, RegionID,RegionName)
    SELECT sd.StoreKey, sd.StoreID, sd.StoreZip, sd.RegionID ,sd.RegionName
    FROM mushamrn_F25_ZAGIMORE_DS.StoreDimension sd
    WHERE sd.F_loaded = FALSE;

    UPDATE mushamrn_F25_ZAGIMORE_DS.StoreDimension
    SET F_loaded = TRUE
    WHERE F_loaded = FALSE;
    END
 
------------------
----PRODUCT DIMENSION REFRESH PROCEDURE
ALTER TABLE mushamrn_F25_ZAGIMORE_DS.ProductDimension
ADD Extraction_time_stamp TIMESTAMP,
ADD F_loaded BOOLEAN ;

UPDATE mushamrn_F25_ZAGIMORE_DS.ProductDimension
SET Extraction_time_stamp = NOW() - INTERVAL 7 DAY,
F_loaded = TRUE;


INSERT INTO mushamrn_F25_ZAGIMORE.product (`productid`, `productname`, `productprice`, `vendorid`, `categoryid`) VALUES ('9X1', 'PS5', '5.00', 'OA', 'EL');
INSERT INTO mushamrn_F25_ZAGIMORE.product (`productid`, `productname`, `productprice`, `vendorid`, `categoryid`) VALUES ('9X2', 'Nike', '100.00', 'MK', 'FW'), ('9X3', 'Bed', '50.00', 'WL', 'CP');


    CREATE PROCEDURE Refresh_Product_Dimension()
        BEGIN
INSERT INTO mushamrn_F25_ZAGIMORE_DS.ProductDimension 
    (ProductID, ProductName, SalesProductPrice, ProductType,
     VendorID, VendorName, CategoryID, CategoryName,
     RentalProductPriceDaily, RentalProductPriceWeekly,
     Extraction_time_stamp, F_loaded)

SELECT 
    p.ProductID,
    p.ProductName,
    p.ProductPrice AS SalesProductPrice,               
    'Sales Product' AS ProductType,
    v.VendorID,
    v.VendorName,
    c.CategoryID,
    c.CategoryName,
    NULL AS RentalProductPriceDaily,
    NULL AS RentalProductPriceWeekly,
    NOW() AS Extraction_time_stamp,
    FALSE AS F_loaded
FROM 
    mushamrn_F25_ZAGIMORE.product  p,
    mushamrn_F25_ZAGIMORE.vendor   v,
    mushamrn_F25_ZAGIMORE.category c
WHERE 
    p.categoryid = c.categoryid
    AND v.vendorid = p.vendorid
    AND p.productid NOT IN (
        SELECT pd.productid
        FROM mushamrn_F25_ZAGIMORE_DS.ProductDimension pd
    )
UNION
SELECT 
    r.productid,
    r.productname,
    NULL AS SalesProductPrice,
    'Rental Product' AS ProductType,
    v.vendorid,
    v.vendorname,
    c.categoryid,
    c.categoryname,
    r.productpricedaily,
    r.productpriceweekly,
    NOW() AS Extraction_time_stamp,
    FALSE AS F_loaded
FROM 
    mushamrn_F25_ZAGIMORE.rentalProducts r,
    mushamrn_F25_ZAGIMORE.vendor        v,
    mushamrn_F25_ZAGIMORE.category      c
WHERE 
    r.categoryid = c.categoryid
    AND v.vendorid = r.vendorid
    AND r.productid NOT IN (
        SELECT pd.productid
        FROM mushamrn_F25_ZAGIMORE_DS.ProductDimension pd
    );

    INSERT INTO mushamrn_F25_ZAGIMORE_DW.ProductDimension (ProductKey, ProductID, ProductName, SalesProductPrice, ProductType, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly)
    SELECT pd.ProductKey, pd.ProductID, pd.ProductName, pd.SalesProductPrice, pd.ProductType, pd.VendorID, pd.VendorName, pd.CategoryID, pd.CategoryName, pd.RentalProductPriceDaily, pd.RentalProductPriceWeekly
    FROM mushamrn_F25_ZAGIMORE_DS.ProductDimension pd
    WHERE pd.F_loaded = FALSE;

    UPDATE mushamrn_F25_ZAGIMORE_DS.ProductDimension
    SET F_loaded = TRUE
    WHERE F_loaded = FALSE;
    END

------------------------------------------------------------------------------------------------------------------------  
--DAILY FACT TABLE REFRESH PROCEDURE
------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE Daily_Fact_Refresh()
BEGIN
DROP TABLE IF EXISTS IFT;
CREATE TABLE IFT AS
SELECT sv.noofitems as UnitsSold,sv.noofitems*pr.productprice as DollarsGenerated, sv.tid as TID, "Sales" as RevenueType,pr.productid,
st.customerid,st.storeid,st.tdate
FROM mushamrn_F25_ZAGIMORE.salestransaction st, mushamrn_F25_ZAGIMORE.soldvia sv,
mushamrn_F25_ZAGIMORE.product pr
WHERE pr.productid= sv.productid
AND sv.tid=st.tid
AND st.tdate > (SELECT(MAX(DATE(Extraction_time_stamp))) FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table)
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpricedaily as DollarsGenerated,rv.tid as TID, "Rental,daily" as RevenueType, rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt,mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "D"
AND rt.tdate >(SELECT (MAX(DATE(Extraction_time_stamp))) FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table)
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpriceweekly as DollarsGenerated,rv.tid as TID, "Rental,weekly" as RevenueType, rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt,mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "W"
AND rt.tdate >(SELECT (MAX(DATE(Extraction_time_stamp))) FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table);

ALTER TABLE IFT
MODIFY RevenueType VARCHAR(25) COLLATE utf8mb4_0900_ai_ci;


INSERT INTO Revenue_Fact_Table (
DollarsGenerated,
Unitssold,
TID,
StoreKey,
CustomerKey,
CalendarKey,
ProductKey,
Revenue_Type,
Extraction_time_stamp,
F_loaded)
SELECT i.DollarsGenerated,
i.UnitsSold,
i.TID,
sd.storekey,
cd.customerkey,
cc.calendarkey,
pd.productkey,
i.RevenueType,
NOW(),
FALSE
FROM IFT i, ProductDimension pd, CustomerDimension cd, StoreDimension sd, CalendarDimension cc
WHERE i.productid= pd.productid
AND i.customerid= cd.customerid
AND
i.storeid= sd.storeid
AND
i.tdate= cc.FullDate
AND
LEFT (i.RevenueType,1)=LEFT(pd.producttype, 1);


INSERT INTO mushamrn_F25_ZAGIMORE_DW.RevenueFact(
    DollarsGenerated,
    UnitsSold,
    TID,
    RevenueType,
    ProductKey,
    StoreKey,
    CustomerKey,
    CalendarKey
)
SELECT 
    DollarsGenerated,
    Unitssold        AS UnitsSold,
    TID,
    Revenue_Type     AS RevenueType,
    ProductKey,
    StoreKey,
    CustomerKey,
    CalendarKey
FROM Revenue_Fact_Table
WHERE F_LOADED = FALSE;

END

------------------------------------------------------------------------------------------------------------------------------
----------
CREATE PROCEDURE Late_Arriving_Fact_Refresh()
BEGIN
DROP TABLE IF EXISTS IFT;
CREATE TABLE IFT AS
SELECT sv.noofitems as UnitsSold,sv.noofitems*pr.productprice as DollarsGenerated, sv.tid as TID, "Sales" as RevenueType,pr.productid,
st.customerid,st.storeid,st.tdate
FROM mushamrn_F25_ZAGIMORE.salestransaction st, mushamrn_F25_ZAGIMORE.soldvia sv,
mushamrn_F25_ZAGIMORE.product pr
WHERE pr.productid= sv.productid
AND sv.tid = st.tid
AND st.tid NOT IN  (SELECT tid from mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table)
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpricedaily as DollarsGenerated,rv.tid as TID, "Rental,daily" as RevenueType, rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt,mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "D"
AND rt.tid NOT IN (SELECT tid FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table)
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpriceweekly as DollarsGenerated,rv.tid as TID, "Rental,weekly" as RevenueType, rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM mushamrn_F25_ZAGIMORE.rentaltransaction rt,mushamrn_F25_ZAGIMORE.rentvia rv,mushamrn_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "W"
AND rt.tid NOT IN (SELECT tid FROM tshabas_ZAGIMORE_FALL_DS25.Revenue_Fact_Table);

ALTER TABLE IFT
MODIFY RevenueType VARCHAR(25) COLLATE utf8mb4_0900_ai_ci;

INSERT INTO Revenue_Fact_Table (
DollarsGenerated,
Unitssold,
TID,
StoreKey,
CustomerKey,
CalendarKey,
ProductKey,
Revenue_Type,
Extraction_time_stamp,
F_loaded)
SELECT i.DollarsGenerated,
i.UnitsSold,
i.TID,
sd.storekey,
cd.customerkey,
cc.calendarkey,
pd.productkey,
i.RevenueType,
NOW(),
FALSE
FROM IFT i, ProductDimension pd, CustomerDimension cd, StoreDimension sd, CalendarDimension cc
WHERE i.productid= pd.productid
AND i.customerid= cd.customerid
AND
i.storeid= sd.storeid
AND
i.tdate= cc.FullDate
AND
LEFT (i.RevenueType,1)=LEFT(pd.producttype, 1);


INSERT INTO mushamrn_F25_ZAGIMORE_DW.RevenueFact(
    DollarsGenerated,
    UnitsSold,
    TID,
    RevenueType,
    ProductKey,
    StoreKey,
    CustomerKey,
    CalendarKey
)
SELECT 
    DollarsGenerated,
    Unitssold        AS UnitsSold,
    TID,
    Revenue_Type     AS RevenueType,
    ProductKey,
    StoreKey,
    CustomerKey,
    CalendarKey
FROM Revenue_Fact_Table
WHERE F_LOADED = FALSE;


UPDATE Revenue_Fact_Table
SET F_LOADED = TRUE
WHERE F_LOADED = FALSE;

END

----SPOT CHECKING THE RECORD COUNTS BEFORE AND AFTER THE REFRESH FOR STORES
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE.store
UNION
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DS.StoreDimension
UNION 
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DW.StoreDimension;

----SPOT CHECKING THE RECORD COUNTS BEFORE AND AFTER THE REFRESH FOR PRODUCTS
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE.product
UNION
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DS.ProductDimension
UNION 
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DW.ProductDimension;

----SPOT CHECKING THE RECORD COUNTS BEFORE AND AFTER THE REFRESH FOR FACT TABLE
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DS.Revenue_Fact_Table
UNION 
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DW.Revenue_Fact_Table;


---SPOT CHECKING THE RECORD COUNTS BEFORE AND AFTER THE REFRESH FOR CUSTOMERS
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE.customer
UNION
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension
UNION 
SELECT COUNT(*)
FROM mushamrn_F25_ZAGIMORE_DW.CustomerDimension;


----Type two changes
--SUBJECT TO CHANGE FOR SALES : ProductName,SalesProductPrice,VendorID,VendorName
--SUBJECT TO CHANGE FOR RENTALS: ProductName,SalesProductPrice,VendorID,VendorName,RentalProductPriceWeekly


--(DO THIS FOR THE CUSTOMER  AND DAWAREHOUSE AS WELL)
ALTER TABLE mushamrn_F25_ZAGIMORE_DS.ProductDimension
ADD DVF DATE,
ADD DVU DATE,
ADD CurrentStatus BOOLEAN; 

UPDATE mushamrn_F25_ZAGIMORE_DS.ProductDimension
SET DVF = '2013-01-01',
DVU = '2030-01-01',
CurrentStatus = TRUE;

INSERT INTO ProductDimension(
ProductID,
ProductName,
SalesProductPrice,
ProductType,
VendorID,
VendorName,
CategoryID,
CategoryName,
RentalProductPriceDaily,
RentalProductPriceWeekly,
Extraction_time_stamp,
F_loaded,
DVF,
DVU,
CurrentStatus
)

SELECT 
    p.ProductID,
    p.ProductName,
    p.ProductPrice ,            
    'Sales Product' ,
    v.VendorID,
    v.VendorName,
    c.CategoryID,
    c.CategoryName,
    NULL ,
    NULL ,
    NOW() ,
    FALSE,
    DATE(NOW()),
    '2030-01-01',
    TRUE
FROM 
    mushamrn_F25_ZAGIMORE.product  p,
    mushamrn_F25_ZAGIMORE.vendor   v,
    mushamrn_F25_ZAGIMORE.category c,
    mushamrn_F25_ZAGIMORE_DS.ProductDimension pd
WHERE 
    p.categoryid = c.categoryid
    AND v.vendorid = p.vendorid
    AND p.productid = pd.productid
    AND (p.ProductName <> pd.ProductName OR pd.SalesProductPrice <> p.ProductPrice
    OR pd.VendorID <> v.VendorID OR pd.VendorName <> v.VendorName)
    AND pd.ProductType = 'Sales Product'
UNION
    SELECT 
    p.ProductID,
    p.ProductName,
    NULL,            
    'Rental Product' ,
    v.VendorID,
    v.VendorName,
    c.CategoryID,
    c.CategoryName,
    p.productpricedaily ,
    p.productpriceweekly,
    NOW() ,
    FALSE,
    DATE(NOW()),
    '2030-01-01',
    TRUE
FROM 
    mushamrn_F25_ZAGIMORE.rentalProducts  p,
    mushamrn_F25_ZAGIMORE.vendor   v,
    mushamrn_F25_ZAGIMORE.category c,
    mushamrn_F25_ZAGIMORE_DS.ProductDimension pd
WHERE 
    p.categoryid = c.categoryid
    AND v.vendorid = p.vendorid
    AND p.productid = pd.productid
    AND (p.ProductName <> pd.ProductName OR pd.RentalProductPriceDaily <> p.productpricedaily
     OR pd.RentalProductPriceWeekly <> p.productpriceweekly
    OR pd.VendorID <> v.VendorID OR pd.VendorName <> v.VendorName)
    AND pd.ProductType = 'Rental Product'

UPDATE ProductDimension pd1,  ProductDimension pd2
SET pd1.DVU = DATE(NOW())-INTERVAL 1 DAY ,
pd1.CurrentStatus= FALSE
WHERE pd1.ProductID = pd2.ProductID 
AND pd1.ProductType = pd2.ProductType
AND pd1.DVF < pd2.DVF
AND pd1.CurrentStatus=TRUE

---spot check
SELECT pd1.ProductKey,pd1.DVF,pd1.DVU, pd1.CurrentStatus,pd2.ProductKey,pd2.DVF,pd2.DVU,pd2.CurrentStatus
FROM ProductDimension pd1,  ProductDimension pd2
WHERE pd1.ProductID = pd2.ProductID 
AND pd1.ProductType = pd2.ProductType
AND pd1.DVF < pd2.DVF


   

   

----For DW

ALTER TABLE mushamrn_F25_ZAGIMORE_DW.ProductDimension
ADD DVF DATE,
ADD DVU DATE,
ADD CurrentStatus BOOLEAN; 

UPDATE mushamrn_F25_ZAGIMORE_DW.ProductDimension
SET DVF = '2013-01-01',
DVU = '2030-01-01',
CurrentStatus = TRUE;

REPLACE INTO mushamrn_F25_ZAGIMORE_DW.ProductDimension (ProductKey, ProductID, ProductName, SalesProductPrice, ProductType, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly)
    SELECT pd.ProductKey, pd.ProductID, pd.ProductName, pd.SalesProductPrice, pd.ProductType, pd.VendorID, pd.VendorName, pd.CategoryID, pd.CategoryName, pd.RentalProductPriceDaily, pd.RentalProductPriceWeekly
    FROM mushamrn_F25_ZAGIMORE_DS.ProductDimension pd

     UPDATE mushamrn_F25_ZAGIMORE_DS.ProductDimension
    SET F_loaded = TRUE
    WHERE F_loaded = FALSE;

----CUSTOMER 

ALTER TABLE mushamrn_F25_ZAGIMORE_DS.CustomerDimension
ADD DVF DATE,
ADD DVU DATE,
ADD CurrentStatus BOOLEAN; 

UPDATE mushamrn_F25_ZAGIMORE_DS.CustomerDimension
SET DVF = '2013-01-01',
DVU = '2030-01-01',
CurrentStatus = TRUE;

INSERT INTO CustomerDimension(
CustomerID,
CustomerName,
CustomerZip,
Extraction_time_stamp,
F_loaded,
DVF,
DVU,
CurrentStatus
)
SELECT
    c.CustomerID,
    c.CustomerName,
    c.CustomerZip,
    NOW() AS Extraction_time_stamp,
    FALSE AS F_loaded,
    DATE(NOW()) AS DVF,
    '2030-01-01' AS DVU,
    TRUE AS CurrentStatus
FROM
    mushamrn_F25_ZAGIMORE.customer c,
    mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd
WHERE
    c.CustomerID = cd.CustomerID
    AND (c.CustomerName <> cd.CustomerName OR c.CustomerZip <> cd.CustomerZip); 

UPDATE mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd1,  mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd2
SET cd1.DVU = DATE(NOW())-INTERVAL 1 DAY ,
cd1.CurrentStatus= FALSE
WHERE cd1.CustomerID = cd2.CustomerID 
AND cd1.DVF < cd2.DVF
AND cd1.CurrentStatus=TRUE;

---spot check
SELECT cd1.CustomerKey,cd1.DVF,cd1.DVU, cd1.CurrentStatus,cd2.CustomerKey,cd2.DVF,cd2.DVU,cd2.CurrentStatus
FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd1,  mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd2
WHERE cd1.CustomerID = cd2.CustomerID 
AND cd1.DVF < cd2.DVF;

----FOR DW
ALTER TABLE mushamrn_F25_ZAGIMORE_DW.CustomerDimension
ADD DVF DATE,
ADD DVU DATE,
ADD CurrentStatus BOOLEAN;  

UPDATE mushamrn_F25_ZAGIMORE_DW.CustomerDimension
SET DVF = '2013-01-01',
DVU = '2030-01-01',
CurrentStatus = TRUE;

REPLACE INTO mushamrn_F25_ZAGIMORE_DW.CustomerDimension (CustomerKey, CustomerID, CustomerName, CustomerZip, DVF, DVU, CurrentStatus)
    SELECT cd.CustomerKey, cd.CustomerID, cd.CustomerName, cd.CustomerZip, cd.DVF, cd.DVU, cd.CurrentStatus
    FROM mushamrn_F25_ZAGIMORE_DS.CustomerDimension cd;

 UPDATE mushamrn_F25_ZAGIMORE_DS.CustomerDimension
    SET F_loaded = TRUE
    WHERE F_loaded = FALSE;

-----------------
DELIMITER $$

CREATE PROCEDURE UpdateProductDimension_Changes()
BEGIN

   
    INSERT INTO mushamrn_F25_ZAGIMORE_DS.ProductDimension(
        ProductID,
        ProductName,
        SalesProductPrice,
        ProductType,
        VendorID,
        VendorName,
        CategoryID,
        CategoryName,
        RentalProductPriceDaily,
        RentalProductPriceWeekly,
        Extraction_time_stamp,
        F_loaded,
        DVF,
        DVU,
        CurrentStatus
    )
    SELECT 
        p.ProductID,
        p.ProductName,
        p.ProductPrice,
        'Sales Product',
        v.VendorID,
        v.VendorName,
        c.CategoryID,
        c.CategoryName,
        NULL,
        NULL,
        NOW(),
        FALSE,
        DATE(NOW()),
        '2030-01-01',
        TRUE
    FROM 
        mushamrn_F25_ZAGIMORE.product p
        JOIN mushamrn_F25_ZAGIMORE.vendor v ON v.vendorid = p.vendorid
        JOIN mushamrn_F25_ZAGIMORE.category c ON p.categoryid = c.categoryid
        JOIN mushamrn_F25_ZAGIMORE_DS.ProductDimension pd ON p.productid = pd.productid
    WHERE 
        (p.ProductName <> pd.ProductName 
         OR pd.SalesProductPrice <> p.ProductPrice
         OR pd.VendorID <> v.VendorID 
         OR pd.VendorName <> v.VendorName)
        AND pd.ProductType = 'Sales Product'

    UNION ALL

    SELECT 
        p.ProductID,
        p.ProductName,
        NULL,
        'Rental Product',
        v.VendorID,
        v.VendorName,
        c.CategoryID,
        c.CategoryName,
        p.productpricedaily,
        p.productpriceweekly,
        NOW(),
        FALSE,
        DATE(NOW()),
        '2030-01-01',
        TRUE
    FROM 
        mushamrn_F25_ZAGIMORE.rentalProducts p
        JOIN mushamrn_F25_ZAGIMORE.vendor v ON v.vendorid = p.vendorid
        JOIN mushamrn_F25_ZAGIMORE.category c ON p.categoryid = c.categoryid
        JOIN mushamrn_F25_ZAGIMORE_DS.ProductDimension pd ON p.productid = pd.productid
    WHERE 
        (p.ProductName <> pd.ProductName
         OR pd.RentalProductPriceDaily <> p.productpricedaily
         OR pd.RentalProductPriceWeekly <> p.productpriceweekly
         OR pd.VendorID <> v.VendorID 
         OR pd.VendorName <> v.VendorName)
        AND pd.ProductType = 'Rental Product';


  
    UPDATE mushamrn_F25_ZAGIMORE_DS.ProductDimension pd1
    JOIN mushamrn_F25_ZAGIMORE_DS.ProductDimension pd2
        ON pd1.ProductID = pd2.ProductID
        AND pd1.ProductType = pd2.ProductType
    SET 
        pd1.DVU = DATE(NOW()) - INTERVAL 1 DAY,
        pd1.CurrentStatus = FALSE
    WHERE 
        pd1.DVF < pd2.DVF
        AND pd1.CurrentStatus = TRUE;


   
    REPLACE INTO mushamrn_F25_ZAGIMORE_DW.ProductDimension (
        ProductKey,
        ProductID,
        ProductName,
        SalesProductPrice,
        ProductType,
        VendorID,
        VendorName,
        CategoryID,
        CategoryName,
        RentalProductPriceDaily,
        RentalProductPriceWeekly,
        DVF,
        DVU,
        CurrentStatus
    )
    SELECT 
        pd.ProductKey,
        pd.ProductID,
        pd.ProductName,
        pd.SalesProductPrice,
        pd.ProductType,
        pd.VendorID,
        pd.VendorName,
        pd.CategoryID,
        pd.CategoryName,
        pd.RentalProductPriceDaily,
        pd.RentalProductPriceWeekly,
        pd.DVF,
        pd.DVU,
        pd.CurrentStatus
    FROM 
        mushamrn_F25_ZAGIMORE_DS.ProductDimension pd;


   
    UPDATE mushamrn_F25_ZAGIMORE_DS.ProductDimension
    SET F_loaded = TRUE
    WHERE F_loaded = FALSE;

END $$

DELIMITER ;


CREATE TABLE Calendar_Month_Dimension
(CalendarMonthKey INT AUTO_INCREMENT,
CalendarMonth INT,
CalendarYear INT,
PRIMARY KEY (CalendarMonthKey));


INSERT INTO Calendar_Month_Dimension
SELECT DISTINCT CalendarMonth, CalendarYear
FROM Calendar_Dimension;

--e) Create and Populate Monthly_Genre_Snapshot
CREATE TABLE Monthly_Genre_Snapshot AS
SELECT SUM(cf.UnitsSold), SUM(cf.RevenueGenerated), cm.CalendarMonthKey, g.GenreKey
FROM Core as cf, Genre_Dimension as g, Calendar_Month_Dimension cm, Calendar_Dimension c, Track_Dimension t
WHERE cf.CalendarKey = c.CalendarKey
AND c.CalendarMonth = cm.CalendarMonth
AND cf.TrackKey= t.TrackKey
AND t.GenreID = g.GenreID
GROUP BY cm.CalendarMonthKey, g.GenreKey;

CREATE PROCEDURE populateCalendar()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE fd DATE DEFAULT '2013-01-01';
  DECLARE nd DATE;

  SET nd = fd;

  myloop: LOOP
    INSERT INTO CalendarDimension(FullDate, MonthYear, Year)
    VALUES (
      nd,
      CONCAT(LPAD(MONTH(nd),2,'0'),YEAR(nd)),
      YEAR(nd)
    );

    SET nd = DATE_ADD(fd, INTERVAL i DAY);
    SET i = i + 1;

    IF i > 8000 THEN
      LEAVE myloop;
    END IF;
  END LOOP myloop;

END;

-- CREATING AN INTERMEDIATE TABLE
 
DROP TABLE IF EXISTS IFT;


CREATE TABLE IFT as
SELECT sv.noofitems as UnitsSold,sv.noofitems*pr.productprice as DollarsGenerated,sv.tid as TID, "Sales" as RevenueType,pr.productid,
st.customerid,st.storeid,st.tdate
FROM wamburej_F25_ZAGIMORE.salestransaction st,wamburej_F25_ZAGIMORE.soldvia sv,
wamburej_F25_ZAGIMORE.product pr  
WHERE pr.productid= sv.productid
AND sv.tid=st.tid
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpricedaily as DollarsGenerated,rv.tid as TID,"Rental,daily" as RevenueType,
rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM wamburej_F25_ZAGIMORE.rentaltransaction rt,wamburej_F25_ZAGIMORE.rentvia rv,wamburej_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "D"
UNION
SELECT rv.duration as UnitsSold,rv.duration*rp.productpriceweekly as DollarsGenerated,rv.tid as TID,"Rental,weekly" as RevenueType,
rp.productid,rt.customerid,rt.storeid,rt.tdate
FROM wamburej_F25_ZAGIMORE.rentaltransaction rt,wamburej_F25_ZAGIMORE.rentvia rv,wamburej_F25_ZAGIMORE.rentalProducts rp
WHERE rv.productid= rp.productid
AND rt.tid=rv.tid
AND rv.rentaltype= "W";

-- EXTRACT DATA INTO THE FACT TABLE

INSERT INTO RevenueFact(DollarsGenerated,UnitsSold,TID,RevenueType,ProductKey,CalendarKey,StoreKey,CustomerKey
)
SELECT i.DollarsGenerated, i.UnitsSold, i.TID, i.RevenueType,pd.ProductKey,cd.CalendarKey,sd.StoreKey,cud.CustomerKey
FROM IFT i,stalins_F25_ZAGIMORE_DS.ProductDimension pd, stalins_F25_ZAGIMORE_DS.CustomerDimension cud,
stalins_F25_ZAGIMORE_DS.CalendarDimension cd, stalins_F25_ZAGIMORE_DS.StoreDimension sd
WHERE i.productid=pd.productid AND
i.customerid=cud.customerid AND
i.storeid=sd.storeid AND
i.tdate=cd.FullDate AND
LEFT(i.RevenueType,1)=LEFT(pd.ProductType,1);