SELECT *
FROM dirty_cafe_sales;

DROP TABLE IF EXISTS cafe_staging;
 
CREATE TABLE cafe_staging
LIKE dirty_cafe_sales;

INSERT INTO cafe_staging
SELECT *
FROM dirty_cafe_sales;

SELECT *
FROM cafe_staging;

-- Remove duplicate

SELECT * 
FROM (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY `Transaction ID`, Item, Quantity, `Price Per Unit`,
	`Total Spent`, `Payment Method`, Location, `Transaction Date`) AS `Row Num`
	FROM cafe_staging
) AS temp
WHERE `Row Num` > 1;

-- Standardlize the Data

SELECT DISTINCT Quantity, `Price Per Unit`, `Total Spent`
FROM cafe_staging;

UPDATE cafe_staging
SET `Total Spent` = NULL
WHERE `Total Spent` = 'ERROR'
OR `Total Spent` = 'UNKNOWN'
OR `Total Spent` = '';

ALTER TABLE cafe_staging
MODIFY COLUMN `Total Spent` DOUBLE;

UPDATE cafe_staging
SET `Price Per Unit` = ROUND(`Price Per Unit`, 2);

UPDATE cafe_staging
SET `Total Spent` = Quantity * `Price Per Unit`
WHERE `Total Spent` IS NULL;

UPDATE cafe_staging
SET `Total Spent` = Round(`Total Spent`, 2);

SELECT DISTINCT `Payment Method`
FROM cafe_staging; 

UPDATE cafe_staging
SET `Payment Method` = NULL
WHERE `Payment Method` = 'ERROR'
OR `Payment Method` = 'UNKNOWN'
OR `Payment Method` = '';

SELECT DISTINCT Item, Quantity, `Price Per Unit`, `Total Spent` 
FROM cafe_staging
ORDER BY Item;

UPDATE cafe_staging
SET Item = CASE
    WHEN `Total Spent` / Quantity = 2 THEN 'Coffee'
    WHEN `Total Spent` / Quantity = 1 THEN 'Cookie'
    WHEN `Total Spent` / Quantity = 5 THEN 'Salad'
    WHEN `Total Spent` / Quantity = 1.5 THEN 'Tea'
    ELSE NULL
END
WHERE Item = 'ERROR' OR Item = 'UNKNOWN' OR Item = '';

SELECT DISTINCT Location
FROM cafe_staging; 

UPDATE cafe_staging
SET Location = NULL
WHERE Location = 'ERROR'
OR Location = 'UNKNOWN'
OR Location = '';

SELECT DISTINCT `Transaction Date`
FROM cafe_staging
WHERE `Transaction Date` NOT LIKE "20__-__-__";

UPDATE cafe_staging
SET `Transaction Date` = NULL
WHERE `Transaction Date` = 'ERROR'
OR `Transaction Date` = 'UNKNOWN'
OR `Transaction Date` = '';

ALTER TABLE cafe_staging
MODIFY COLUMN `Transaction Date` Date;

-- Add Significant Cols

ALTER TABLE cafe_staging
ADD COLUMN `Day of the Week` TEXT;

UPDATE cafe_staging
SET `Day of the Week` = DAYNAME(`Transaction Date`);

SELECT *
FROM cafe_staging;
