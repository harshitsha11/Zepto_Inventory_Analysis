CREATE DATABASE zepto;
USE zepto;

-- CREATING TABLE
DROP TABLE IF EXISTS zepto_inventory;
CREATE TABLE zepto_inventory(
sku_id INT AUTO_INCREMENT PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(120),
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INT,
discountedSellingPrice NUMERIC(8,2),
weightInGms INT,
outOfStock VARCHAR(10),
quantity INT
);

SELECT * FROM zepto_inventory;

-- DATA EXPLORATION
-- COUNT OF ROWS
SELECT COUNT(*) FROM zepto_inventory;

-- SAMPLE DATA
SELECT * FROM zepto_inventory
LIMIT 10;

-- NULL VALUES
SELECT * FROM zepto_inventory
WHERE
category IS NULL
OR 
name IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
availableQuantity IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR 
outOfStock IS NULL
OR
quantity IS NULL;

-- PRODUCT CATEGORIES
SELECT DISTINCT category FROM zepto_inventory
ORDER BY category;

-- PRODUCTS IN STOCK VS OUT OF STOCK
SELECT outOfStock, COUNT(sku_id) FROM zepto_inventory
GROUP BY outOfStock;

-- PRODUCT NAMES PRESENT MORE THAN ONCE
SELECT name, COUNT(sku_id) AS "Number of SKUs" FROM zepto_inventory
GROUP BY name
HAVING COUNT(sku_id)>1
ORDER BY COUNT(sku_id) DESC;

-- DATA CLEANING
-- PRODUCTS WITH PRICE = 0
SELECT * FROM zepto_inventory
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- DELETE PRODUCTS WITH PRICE = 0 
SET SQL_SAFE_UPDATES = 0;

DELETE FROM zepto_inventory
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- PRICES ARE IN PAISE SO, CONVERT PAISE INTO RUPEES
UPDATE zepto_inventory
SET mrp = mrp/100,  discountedSellingPrice = discountedSellingPrice/100;


-- 1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent FROM zepto_inventory
ORDER BY discountPercent DESC 
LIMIT 10;

-- 2. What are the products with high mrp but out of stock.
SELECT DISTINCT name, mrp FROM zepto_inventory
WHERE outOfStock = 'TRUE'
ORDER BY mrp DESC
LIMIT 10;

-- 3. Calculate estimated revenue for each category.
SELECT DISTINCT category, SUM(discountedSellingPrice*availableQuantity) as revenue FROM zepto_inventory
GROUP BY category
ORDER BY revenue DESC;

-- 4. Find all products where mrp is greater than Rs 500 and discount is less than 10%.
SELECT name, mrp, discountPercent FROM zepto_inventory
WHERE mrp>500 AND discountPercent<10;

-- 5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category, ROUND(AVG(discountPercent),2) AS averageDiscount FROM zepto_inventory
GROUP BY category
ORDER BY AVG(discountPercent) DESC
LIMIT 5;

-- 6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, discountedSellingPrice, weightInGms, ROUND((discountedSellingPrice/weightInGms),3) AS pricePerGms 
FROM zepto_inventory
WHERE weightInGms>100
ORDER BY pricePerGms;

-- 7. Group the products into categories like low, medium and bulk.
SELECT name, weightInGms, CASE
WHEN weightInGms < 1000 THEN 'Low'
WHEN weightInGms < 5000 THEN 'Medium'
ELSE 'Bulk'
END AS weightCategory
FROM zepto_inventory;

-- 8. What is total inventory weight per category.
SELECT category, SUM(weightInGms*availableQuantity) AS inventoryWeight FROM zepto_inventory
GROUP BY category
ORDER BY inventoryWeight;
