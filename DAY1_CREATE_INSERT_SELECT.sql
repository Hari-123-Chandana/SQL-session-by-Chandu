
------------------------------------------

CREATE TABLE TRANS_V2 (     --SYNTAX FOR CREATING AN EMPTY TABLE , SPECIFY THE NAME OF THE TABLE NAME
TNXID INT,              --ASSIGN APPROPRIATE DATATYPES TO THE COLUMNS CREATED (BASICALLY WHAT TYPE OF DATA YOU WANT TO STORE)
PRODUCTDESC VARCHAR(255),
PRICE FLOAT
);

INSERT INTO TRANS_V2       --FILL IN INFORMATION INTO THE TABLE CREATED (HERE ITS TRANSACION TABLE)
VALUES                  -- ALL VALUES SHOULD BE STORED IN ORDER OF THE COLUMN NAMES
(1001,'TSHIRT',100.50), -- DATATYPES OF THE COLUMNS AND THE VALUES IN IT SHOULD BE SAME
(1002,'SHIRT',50),
(1003,'PANT',40);


SELECT * FROM TRANS_V2;    --VIEW THE ENTIRE TABLE WITH ALL THE INFORMATION/DATA



-------------------------------------------

------------------------------------------

sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'max server memory', 32768;   -- for 32 GB
GO  
RECONFIGURE;  
GO

--------------------------------------------------

CREATE DATABASE ECOMMERCE;

USE ECOMMERCE;

CREATE TABLE TRANS (     --SYNTAX FOR CREATING AN EMPTY TABLE , SPECIFY THE NAME OF THE TABLE NAME
TNXID INT PRIMARY KEY, --ASSIGN APPROPRIATE DATATYPES TO THE COLUMNS CREATED (BASICALLY WHAT TYPE OF DATA YOU WANT TO STORE)
PRODUCTID VARCHAR(255),
PRODUCTDESC VARCHAR(255),
PRICE FLOAT
);

INSERT INTO TRANS       --FILL IN INFORMATION INTO THE TABLE CREATED (HERE ITS TRANSACION TABLE)
VALUES                  -- ALL VALUES SHOULD BE STORED IN ORDER OF THE COLUMN NAMES
(1001,'P1','TSHIRT',100.50), -- DATATYPES OF THE COLUMNS AND THE VALUES IN IT SHOULD BE SAME
(1002,'P2','SHIRT',50),
(1003,'P3','PANT',40),
(1004,'P4','SAREE',120),
(1005,'P5','TOP',110),
(1006,'P6','TSHIRT',60),
(1007,'P1','TSHIRT',90),
(1008,'P3','PANT',50),
(1009,'P7','TSHIRT',70)
;


SELECT * FROM TRANS;    --VIEW THE ENTIRE TABLE WITH ALL THE INFORMATION/DATA

--USE TRANS;
ALTER TABLE TRANS ADD DISCOUNT INT ;
--ALTER TABLE TRANS ADD QTY INT AFTER PRODUCTDESC;

--ALTER TABLE TRANS RENAME DISCOUNT TO DISC_PEC;  MYSQL SYNTAX
EXEC SP_RENAME 'TRANS.DISCOUNT', 'DISC_PEC', 'COLUMN';  --SQL SERVER SYNTAX

--Alter table table_name modify column column_name varchar(30);  MYSQL SYNTAX
-- ALTER TABLE dbo.TRANS ALTER COLUMN TNXID VARCHAR (255);


UPDATE TRANS SET DISC_PEC=10 WHERE TNXID=1001;
UPDATE TRANS SET DISC_PEC=15 WHERE TNXID=1002;
UPDATE TRANS SET DISC_PEC=5 WHERE TNXID=1003;
UPDATE TRANS SET DISC_PEC=20 WHERE TNXID=1004;
UPDATE TRANS SET DISC_PEC=8 WHERE TNXID=1005;
UPDATE TRANS SET DISC_PEC=12 WHERE TNXID=1006;
UPDATE TRANS SET DISC_PEC=11 WHERE TNXID=1007;
UPDATE TRANS SET DISC_PEC=15 WHERE TNXID=1008;
UPDATE TRANS SET DISC_PEC=5 WHERE TNXID=1009;


SELECT TRANS.TNXID, TRANS.PRODUCTDESC FROM TRANS;

SELECT TOP 2 * FROM TRANS;
--SELECT * FROM TRANS LIMIT 2;

SELECT * FROM TRANS WHERE PRICE>=50;

SELECT PRODUCTDESC FROM TRANS WHERE PRICE>=50;

SELECT PRODUCTDESC FROM TRANS WHERE PRICE>=50 AND PRICE<=100;
SELECT * FROM TRANS WHERE PRICE>=50 AND PRICE<=100;
SELECT PRODUCTID, PRODUCTDESC FROM TRANS WHERE PRICE BETWEEN 50 AND 100;
SELECT * FROM TRANS WHERE PRODUCTDESC IN ('TSHIRT','SHIRT');

SELECT * FROM TRANS ORDER BY PRICE; -- DEFAULT IS ASCENDING
SELECT * FROM TRANS ORDER BY PRICE DESC ;


SELECT * FROM TRANS ORDER BY PRICE, DISC_PEC;
SELECT * FROM TRANS ORDER BY PRICE DESC, DISC_PEC;

SELECT DISTINCT PRODUCTID FROM TRANS;

INSERT INTO TRANS       --FILL IN INFORMATION INTO THE TABLE CREATED (HERE ITS TRANSACION TABLE)
VALUES                  -- ALL VALUES SHOULD BE STORED IN ORDER OF THE COLUMN NAMES
(1010,'P1','TSHIRT',NULL,NULL)
;

SELECT * FROM TRANS;
SELECT * FROM TRANS WHERE PRICE IS NOT NULL;
SELECT *, ISNULL(PRICE,50) AS UPDT_PRC FROM TRANS;
SELECT *, COALESCE(PRICE,100) AS UPDT_PRC2 FROM TRANS;

SELECT *
	, CASE
	WHEN PRICE>100 THEN 'HIGH'
	WHEN PRICE>50 AND PRICE<100 THEN 'MEDIUM'
	ELSE 'LOW'
	END AS PRICE_CLASS
	FROM TRANS;

SELECT *
		, CASE 
		WHEN PRODUCTDESC IN ('TSHIRT','SHIRT') THEN 'MENS WEAR'
		WHEN PRODUCTDESC IN ('SAREE','TOP') THEN 'WOMEN WEAR'
		WHEN PRODUCTDESC IN ('PANT') THEN 'UNISEX'
		ELSE 'UNK'
		END AS PROD_CLASS
		FROM TRANS;


------------------
--ALTER TABLE TRANS DROP DISC_PER;
ALTER TABLE dbo.TRANS DROP COLUMN PRICE;

--ALTER TABLE dbo.TRANS drop constraint DISC_PER;

TRUNCATE TABLE TRANS;

DROP TABLE TRANS;
