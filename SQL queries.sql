-- create a database
CREATE DATABASE IF NOT EXISTS fetch_db;

-- use the database
USE fetch_db;

-- create the users table
CREATE TABLE users(
ID VARCHAR(255),
CREATED_DATE DATE,
BIRTH_DATE DATE,
STATE varchar(255),
LANGUAGE varchar(255),
GENDER varchar(255),
AGE INT,
UNREASONABLE_AGE VARCHAR(255)
);

-- create the transactions table
CREATE TABLE transactions(
RECEIPT_ID VARCHAR(255),
PURCHASE_DATE DATE,
SCAN_DATE DATE,
STORE_NAME VARCHAR(255),
USER_ID VARCHAR(255),
BARCODE VARCHAR(255),
FINAL_QUANTITY FLOAT,
FINAL_SALE float
);

-- create the products table
CREATE TABLE products(
CATEGORY_1 VARCHAR(255),
CATEGORY_2 VARCHAR(255),
CATEGORY_3 VARCHAR(255),
CATEGORY_4 VARCHAR(255),
MANUFACTURER VARCHAR(255),
BRAND VARCHAR(255),
BARCODE VARCHAR(255)
);
SHOW DATABASES;

DESCRIBE products;
select count(*)
as total_ROWS from products;

select count(*)
as total_ROWS2 from users;

select count(*)
as total_rows from transactions;


-- closed-ended: 1. what are the top 5 brands by receipts scanned users 21 and over


SELECT 
    p.BRAND, 
    COUNT(DISTINCT t.RECEIPT_ID) AS total_receipts, 
    COUNT(DISTINCT t.USER_ID) AS total_users
FROM 
    transactions t
LEFT JOIN
    users u 
ON 
    t.USER_ID = u.ID
LEFT JOIN 
    products p
ON 
    t.BARCODE = p.BARCODE
Where
    TIMESTAMPDIFF(YEAR,u.BIRTH_DATE,CURDATE())>= 21 and BRAND is not NULL
GROUP BY 
    p.BRAND
ORDER BY 
    total_receipts DESC
LIMIT 5;

-- Checking transaction records for users 21 and over
SELECT 
    COUNT(*) AS total_transactions, 
    count(u.ID) AS over_21 
FROM 
    transactions t 
LEFT JOIN
    users u
ON
    t.USER_ID = u.ID
Where
    u.AGE >=21;

-- 2. closed-ended: What are the top 5 brands by sales among users that have had their account for at least six months?
SELECT
   p.BRAND,
   SUM(t.FINAL_QUANTITY * FINAL_SALE) as final_sales,
   COUNT(DISTINCT t.USER_ID) AS users_over_6_months
FROM
   transactions t
LEFT JOIN
   users u
ON
   t.USER_ID = u.ID
LEFT JOIN
   products p
ON
   t.BARCODE = p.BARCODE
WHERE
   u.CREATED_DATE <= DATE_SUB(CURDATE(),INTERVAL 6 MONTH) and p.BRAND is not NULL
GROUP BY
   t.BARCODE, p.BRAND
ORDER BY
   final_sales DESC
LIMIT 5;

-- Open-ended questions: 3. Who are Fetch’s power users?
-- Purpose:
-- I want to group users by demographics (age and gender) to identify which groups contain the most power users.
-- This is because identifying individual power users may not be actionable. 
-- By understanding the target audience, we can focus marketing efforts on specific demographic groups and deliver targeted ads.

-- Assumptions:
-- 1. Power Users: Defined solely by high total sales, as transaction amounts drive revenue (e.g., company earns a percentage of each transaction amount).
-- 2. Age Calculation: Derived dynamically from BIRTH_DATE using TIMESTAMPDIFF.
-- 3. Age Groups:
--    a. Young People: 0-17 years
--    b. Young Adults: 18-35 years
--    c. Middle-Aged: 36-60 years
--    d. Senior: 61+ years
-- 4. Gender Identification: Based on the GENDER column in the database.
-- 5. Data Validity: Users with null or missing AGE, GENDER, or FINAL_SALE are excluded to ensure accurate grouping.
-- 6. Target Audience: Analyzing power users by group helps optimize advertising and marketing campaigns for the most valuable demographics.

SELECT
  CASE
  -- age group
  WHEN TIMESTAMPDIFF(YEAR,u.BIRTH_DATE,CURDATE()) BETWEEN 0 AND 17 THEN 'Young People(0-17y)'
  WHEN TIMESTAMPDIFF(YEAR,u.BIRTH_DATE,CURDATE()) BETWEEN 18 AND 35 THEN 'Young Adults(18-35y)'
  WHEN TIMESTAMPDIFF(YEAR,u.BIRTH_DATE,CURDATE()) BETWEEN 36 AND 60 THEN 'Middle-Aged(36-60y)'
  WHEN TIMESTAMPDIFF(YEAR,u.BIRTH_DATE,CURDATE()) >60 THEN 'Elderly(60+y)'
  ELSE 'Unknow'
END AS age_group, 
u.GENDER,
SUM(t.FINAL_SALE*t.FINAL_QUANTITY) as total_sales
From
 users u
RIGHT JOIN
 transactions t
ON
 u.ID=t.USER_ID
WHERE
 u.BIRTH_DATE is not null
 AND u.GENDER is not null
 AND t.FINAL_SALE is not null
 AND t.FINAL_QUANTITY is not null
GROUP BY
 u.GENDER, age_group
ORDER BY
 total_sales DESC;
 
 /*
Conclusions:

1. Female Users Across Most Groups:
   - Female users outspend males in the majority of age groups.
   - Middle-Aged Females (36-60y) contribute the highest total sales and represent a loyal and valuable customer base.
   - Young Adult Females (18-35y) also demonstrate significant potential for growth and long-term retention.

2. Balanced Marketing for Elderly Users:
   - While elderly males spend more, both genders contribute meaningfully in this group.
   - Comfort, health, and ease of access should be emphasized in campaigns targeting elderly users.

3. Opportunities in Young Adults (18-35y):
   - Young Adult Females represent a promising market segment with growing purchasing power.
   - Focus on creating campaigns that promote loyalty, such as trendy, eco-friendly, or lifestyle-based subscription programs. Build a connection with this group to encourage long-term customer retention.


Business Implication:
- Middle-Aged Females (36-60y) are core power users and should be prioritized for retention campaigns with a family and health-oriented approach.
- Young Adult Females (18-35y) represent a growth opportunity; fostering loyalty in this demographic can ensure long-term revenue.
- Elderly Males (60+) should be addressed through tailored campaigns to maximize engagement and revenue.
*/
