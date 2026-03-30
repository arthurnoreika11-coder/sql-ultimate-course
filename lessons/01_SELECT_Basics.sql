-- ============================================================
-- PROJECT 1: Sales Analytics Report
-- LESSON 1: Querying Data with SELECT
-- ============================================================
-- Database: SalesDB (MyDatabase for this lesson)
-- Tables used: customers, orders
--
-- By the end of this lesson you will be able to:
--   - Retrieve all or specific columns from a table
--   - Filter rows with WHERE
--   - Sort results with ORDER BY
--   - Summarize data with GROUP BY and HAVING
--   - Deduplicate results with DISTINCT
--   - Limit results with TOP / LIMIT
-- ============================================================


-- ------------------------------------------------------------
-- PART 1: ANATOMY OF A SELECT STATEMENT
-- ------------------------------------------------------------
-- Every SELECT query follows this skeleton (order matters):
--
--   SELECT   <columns>
--   FROM     <table>
--   WHERE    <row filter>
--   GROUP BY <grouping columns>
--   HAVING   <group filter>
--   ORDER BY <sort columns>
--
-- SQL evaluates these clauses in this order:
--   FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
-- That's why you can't use a SELECT alias inside a WHERE clause.
-- ------------------------------------------------------------


-- ============================================================
-- SECTION 1: Retrieving columns
-- ============================================================

-- 1a. Get every column from the customers table.
--     * means "all columns" — handy for exploring, but avoid
--     it in production queries (fragile if columns change).
SELECT *
FROM customers;

-- 1b. Get only the columns you actually need.
--     Explicit columns are faster and self-documenting.
SELECT
    first_name,
    country,
    score
FROM customers;


-- ============================================================
-- SECTION 2: Filtering rows with WHERE
-- ============================================================

-- 2a. Customers from Germany only.
SELECT *
FROM customers
WHERE country = 'Germany';

-- 2b. Customers with a score above zero.
--     != means "not equal to" (you can also write <>).
SELECT *
FROM customers
WHERE score != 0;

-- 2c. Combine columns and a filter together.
--     Only show name + country, and only for German customers.
SELECT
    first_name,
    country
FROM customers
WHERE country = 'Germany';

-- Common WHERE operators:
--   =        equal
--   != / <>  not equal
--   >  <     greater / less than
--   >= <=    greater-or-equal / less-or-equal
--   BETWEEN x AND y
--   IN (x, y, z)
--   LIKE 'pattern%'
--   IS NULL / IS NOT NULL


-- ============================================================
-- SECTION 3: Sorting results with ORDER BY
-- ============================================================

-- 3a. Highest score first.
SELECT *
FROM customers
ORDER BY score DESC;   -- DESC = descending (high → low)

-- 3b. Lowest score first.
SELECT *
FROM customers
ORDER BY score ASC;    -- ASC = ascending (low → high), default

-- 3c. Sort by country A→Z, then within each country by score high→low.
--     Multiple sort keys are separated by commas.
SELECT *
FROM customers
ORDER BY country ASC, score DESC;

-- 3d. Combine WHERE + ORDER BY.
SELECT
    first_name,
    country,
    score
FROM customers
WHERE score != 0
ORDER BY score DESC;


-- ============================================================
-- SECTION 4: Summarising with GROUP BY
-- ============================================================

-- GROUP BY collapses many rows into one row per group.
-- Every column in SELECT must either:
--   (a) appear in GROUP BY, or
--   (b) be wrapped in an aggregate function (SUM, COUNT, AVG…)

-- 4a. Total score per country.
SELECT
    country,
    SUM(score) AS total_score
FROM customers
GROUP BY country;

-- 4b. Total score AND customer count per country.
SELECT
    country,
    SUM(score)  AS total_score,
    COUNT(id)   AS total_customers
FROM customers
GROUP BY country;

-- 4c. THIS WILL ERROR — first_name is in SELECT but not in
--     GROUP BY and is not aggregated. SQL doesn't know which
--     name to show when multiple customers share a country.
/*
SELECT
    country,
    first_name,          -- ← problem column
    SUM(score) AS total_score
FROM customers
GROUP BY country;
*/


-- ============================================================
-- SECTION 5: Filtering groups with HAVING
-- ============================================================

-- WHERE filters individual rows (before grouping).
-- HAVING filters groups (after grouping).

-- 5a. Countries whose average score is above 430.
SELECT
    country,
    AVG(score) AS avg_score
FROM customers
GROUP BY country
HAVING AVG(score) > 430;

-- 5b. Same, but first exclude customers with score = 0,
--     then group, then apply the HAVING filter.
SELECT
    country,
    AVG(score) AS avg_score
FROM customers
WHERE  score != 0           -- row-level filter
GROUP BY country
HAVING AVG(score) > 430;    -- group-level filter


-- ============================================================
-- SECTION 6: Removing duplicates with DISTINCT
-- ============================================================

-- 6a. All unique countries in the customers table.
SELECT DISTINCT country
FROM customers;


-- ============================================================
-- SECTION 7: Limiting rows with TOP (SQL Server) / LIMIT (MySQL/Postgres)
-- ============================================================

-- 7a. First 3 customers in table order.
SELECT TOP 3 *          -- SQL Server syntax
FROM customers;
-- MySQL / PostgreSQL equivalent: SELECT * FROM customers LIMIT 3;

-- 7b. Top 3 customers by highest score.
SELECT TOP 3 *
FROM customers
ORDER BY score DESC;

-- 7c. Two most recent orders.
SELECT TOP 2 *
FROM orders
ORDER BY order_date DESC;


-- ============================================================
-- SECTION 8: Putting it all together
-- ============================================================

-- Business question:
--   "Which countries have a healthy average customer score
--    (ignoring zero-score records), ranked best to worst?"

SELECT
    country,
    AVG(score) AS avg_score
FROM customers
WHERE  score != 0
GROUP BY country
HAVING AVG(score) > 430
ORDER BY avg_score DESC;


-- ============================================================
-- CHALLENGE — try these yourself
-- ============================================================
-- 1. List only the first_name and score of all customers,
--    sorted from lowest to highest score.

-- 2. How many customers are there per country?
--    (Hint: COUNT(*) with GROUP BY)

-- 3. Show the two most recent orders from the orders table.

-- 4. Which countries have MORE THAN ONE customer?
--    (Hint: HAVING COUNT(*) > 1)

-- ============================================================
-- ANSWERS (scroll down only after you've tried!)
-- ============================================================




-- Challenge 1
SELECT first_name, score
FROM customers
ORDER BY score ASC;

-- Challenge 2
SELECT country, COUNT(*) AS num_customers
FROM customers
GROUP BY country;

-- Challenge 3
SELECT TOP 2 *
FROM orders
ORDER BY order_date DESC;

-- Challenge 4
SELECT country, COUNT(*) AS num_customers
FROM customers
GROUP BY country
HAVING COUNT(*) > 1;
