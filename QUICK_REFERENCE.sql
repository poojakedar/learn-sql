-- ============================================================================
-- QUICK REFERENCE - PostgreSQL SQL Cheat Sheet
-- ============================================================================

-- ============================================================================
-- CONNECTION & DATABASE
-- ============================================================================

-- Connect to database
\c database_name;

-- List databases
\l

-- List tables
\dt

-- Show table structure
\d table_name;

-- ============================================================================
-- CREATE
-- ============================================================================

CREATE DATABASE learn_sql;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INTEGER CHECK (age >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INSERT
-- ============================================================================

-- Single row
INSERT INTO users (name, email, age)
VALUES ('John Doe', 'john@example.com', 30);

-- Multiple rows
INSERT INTO users (name, email, age) VALUES
('Jane Smith', 'jane@example.com', 28),
('Bob Johnson', 'bob@example.com', 35);

-- ============================================================================
-- SELECT - THE MOST IMPORTANT!
-- ============================================================================

-- All columns, all rows
SELECT * FROM users;

-- Specific columns
SELECT name, email FROM users;

-- With alias
SELECT name AS full_name, email AS user_email FROM users;

-- DISTINCT (unique values)
SELECT DISTINCT age FROM users;

-- LIMIT
SELECT * FROM users LIMIT 10;

-- OFFSET and LIMIT
SELECT * FROM users LIMIT 10 OFFSET 5;

-- ORDER BY
SELECT * FROM users ORDER BY age ASC;
SELECT * FROM users ORDER BY age DESC;

-- ORDER BY multiple columns
SELECT * FROM users ORDER BY age DESC, name ASC;

-- ============================================================================
-- WHERE CLAUSE - FILTERING
-- ============================================================================

-- Comparison operators
SELECT * FROM users WHERE age = 30;
SELECT * FROM users WHERE age != 30;
SELECT * FROM users WHERE age > 30;
SELECT * FROM users WHERE age >= 30;
SELECT * FROM users WHERE age < 30;
SELECT * FROM users WHERE age <= 30;

-- Logical operators
SELECT * FROM users WHERE age > 25 AND age < 35;
SELECT * FROM users WHERE name = 'John' OR name = 'Jane';
SELECT * FROM users WHERE NOT age = 30;

-- IN operator
SELECT * FROM users WHERE age IN (25, 30, 35);

-- BETWEEN
SELECT * FROM users WHERE age BETWEEN 25 AND 35;

-- LIKE pattern matching
SELECT * FROM users WHERE name LIKE 'J%';      -- Starts with J
SELECT * FROM users WHERE name LIKE '%n';      -- Ends with n
SELECT * FROM users WHERE name LIKE '%oh%';    -- Contains oh
SELECT * FROM users WHERE name LIKE 'J_hn';    -- J_hn pattern

-- IS NULL / IS NOT NULL
SELECT * FROM users WHERE email IS NULL;
SELECT * FROM users WHERE email IS NOT NULL;

-- ============================================================================
-- UPDATE
-- ============================================================================

-- Update single column
UPDATE users SET age = 31 WHERE user_id = 1;

-- Update multiple columns
UPDATE users SET age = 32, email = 'new@example.com' WHERE user_id = 1;

-- Update with expression
UPDATE users SET age = age + 1 WHERE age < 30;

-- ============================================================================
-- DELETE
-- ============================================================================

DELETE FROM users WHERE user_id = 1;

DELETE FROM users WHERE age > 50;

-- Delete all (WARNING!)
DELETE FROM users;

-- ============================================================================
-- AGGREGATE FUNCTIONS
-- ============================================================================

SELECT COUNT(*) FROM users;                    -- Count all rows
SELECT COUNT(email) FROM users;                -- Count non-NULL emails
SELECT COUNT(DISTINCT age) FROM users;         -- Count distinct ages

SELECT SUM(age) FROM users;                    -- Total of ages

SELECT AVG(age) FROM users;                    -- Average age

SELECT MIN(age) FROM users;                    -- Minimum age
SELECT MAX(age) FROM users;                    -- Maximum age

SELECT STRING_AGG(name, ', ') FROM users;      -- Concatenate names

-- ============================================================================
-- GROUP BY
-- ============================================================================

SELECT age, COUNT(*) as count FROM users GROUP BY age;

SELECT age, COUNT(*) as count FROM users GROUP BY age ORDER BY count DESC;

-- Multiple columns
SELECT age, email, COUNT(*) FROM users GROUP BY age, email;

-- ============================================================================
-- HAVING - Filter groups
-- ============================================================================

SELECT age, COUNT(*) as count 
FROM users 
GROUP BY age 
HAVING COUNT(*) > 2;

-- ============================================================================
-- JOIN OPERATIONS
-- ============================================================================

-- INNER JOIN
SELECT e.name, d.dept_name 
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- LEFT JOIN
SELECT d.dept_name, COUNT(e.emp_id) 
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- RIGHT JOIN
SELECT d.dept_name, e.name 
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- FULL OUTER JOIN
SELECT d.dept_name, e.name 
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;

-- CROSS JOIN
SELECT e.name, d.dept_name 
FROM employees e
CROSS JOIN departments d;

-- Self join
SELECT e1.name, e2.name as manager 
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id;

-- Multiple joins
SELECT e.name, d.dept_name, p.project_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN project_assignments pa ON e.emp_id = pa.emp_id
JOIN projects p ON pa.project_id = p.project_id;

-- ============================================================================
-- SUBQUERIES
-- ============================================================================

-- In WHERE clause
SELECT * FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);

-- In FROM clause
SELECT * FROM (
    SELECT emp_id, salary FROM employees WHERE dept_id = 1
) as subq
WHERE salary > 50000;

-- IN with subquery
SELECT * FROM employees 
WHERE dept_id IN (
    SELECT dept_id FROM departments WHERE location = 'NYC'
);

-- EXISTS
SELECT * FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id
);

-- ============================================================================
-- UNION
-- ============================================================================

-- UNION (remove duplicates)
SELECT name FROM users
UNION
SELECT emp_name FROM employees;

-- UNION ALL (keep duplicates)
SELECT name FROM users
UNION ALL
SELECT emp_name FROM employees;

-- ============================================================================
-- WINDOW FUNCTIONS
-- ============================================================================

-- ROW_NUMBER
SELECT name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- RANK and DENSE_RANK
SELECT name, salary,
       RANK() OVER (ORDER BY salary DESC) as rank,
       DENSE_RANK() OVER (ORDER BY salary DESC) as dense_rank
FROM employees;

-- PARTITION BY
SELECT name, dept_id, salary,
       RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) as rank
FROM employees;

-- LAG and LEAD
SELECT name, salary,
       LAG(salary) OVER (ORDER BY salary) as prev_salary,
       LEAD(salary) OVER (ORDER BY salary) as next_salary
FROM employees;

-- Running total
SELECT name, salary,
       SUM(salary) OVER (ORDER BY emp_id) as running_total
FROM employees;

-- ============================================================================
-- COMMON TABLE EXPRESSIONS (CTEs)
-- ============================================================================

WITH high_earners AS (
    SELECT * FROM employees WHERE salary > 70000
)
SELECT * FROM high_earners;

-- Multiple CTEs
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) as avg_sal FROM employees GROUP BY dept_id
),
high_earners AS (
    SELECT * FROM employees WHERE salary > 70000
)
SELECT * FROM high_earners he
JOIN dept_avg da ON he.dept_id = da.dept_id;

-- Recursive CTE
WITH RECURSIVE numbers AS (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT * FROM numbers;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Create view
CREATE VIEW v_employee_summary AS
SELECT e.name, d.dept_name, e.salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Query view
SELECT * FROM v_employee_summary;

-- Drop view
DROP VIEW v_employee_summary;

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Create index
CREATE INDEX idx_email ON users(email);

-- Create composite index
CREATE INDEX idx_dept_salary ON employees(dept_id, salary);

-- Create unique index
CREATE UNIQUE INDEX idx_unique_email ON users(email);

-- Drop index
DROP INDEX idx_email;

-- ============================================================================
-- TRANSACTIONS
-- ============================================================================

BEGIN;
    UPDATE employees SET salary = salary + 1000 WHERE dept_id = 1;
    INSERT INTO employee_audit VALUES (...);
COMMIT;

-- Rollback
BEGIN;
    DELETE FROM employees WHERE emp_id = 1;
ROLLBACK;  -- Undo delete

-- Savepoint
BEGIN;
    UPDATE employees SET salary = 80000;
    SAVEPOINT sp1;
    DELETE FROM employees;
    ROLLBACK TO sp1;  -- Undo only the delete
COMMIT;

-- ============================================================================
-- USEFUL FUNCTIONS
-- ============================================================================

-- String functions
UPPER('hello')                              -- HELLO
LOWER('HELLO')                              -- hello
LENGTH('hello')                             -- 5
SUBSTRING('hello', 1, 3)                    -- hel
CONCAT('Hello', ' ', 'World')               -- Hello World
TRIM('  hello  ')                           -- hello

-- Date functions
CURRENT_DATE                                -- Today's date
CURRENT_TIMESTAMP                           -- Now
DATE_TRUNC('month', date_column)           -- Start of month
EXTRACT(YEAR FROM date_column)             -- Year
AGE(date1, date2)                          -- Difference in years/months/days

-- Math functions
ABS(-5)                                     -- 5
ROUND(3.14159, 2)                          -- 3.14
CEIL(3.2)                                   -- 4
FLOOR(3.8)                                  -- 3
RANDOM()                                    -- Random number 0-1

-- Type casting
CAST('123' AS INTEGER)                      -- 123
'123'::INTEGER                              -- 123
'2024-01-15'::DATE                          -- DATE type

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

-- PRIMARY KEY
CREATE TABLE users (user_id SERIAL PRIMARY KEY, ...);

-- NOT NULL
CREATE TABLE users (email VARCHAR(100) NOT NULL, ...);

-- UNIQUE
CREATE TABLE users (email VARCHAR(100) UNIQUE, ...);

-- DEFAULT
CREATE TABLE users (created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, ...);

-- CHECK
CREATE TABLE users (age INTEGER CHECK (age >= 18), ...);

-- FOREIGN KEY
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    dept_id INTEGER REFERENCES departments(dept_id)
);

-- ============================================================================
-- COMMON PATTERNS
-- ============================================================================

-- Get top N records
SELECT * FROM users ORDER BY age DESC LIMIT 10;

-- Get nth highest
SELECT * FROM users ORDER BY age DESC LIMIT 1 OFFSET 4;

-- Find duplicates
SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;

-- Get latest records
SELECT * FROM orders ORDER BY created_at DESC LIMIT 5;

-- Pagination
SELECT * FROM users LIMIT 20 OFFSET 0;        -- Page 1
SELECT * FROM users LIMIT 20 OFFSET 20;       -- Page 2
SELECT * FROM users LIMIT 20 OFFSET 40;       -- Page 3

-- ============================================================================
-- PERFORMANCE TIPS
-- ============================================================================

-- Always use WHERE to filter before expensive operations
SELECT * FROM large_table WHERE status = 'active';

-- Use EXPLAIN to see query plans
EXPLAIN SELECT * FROM users WHERE age > 30;

-- Index frequently searched columns
CREATE INDEX idx_status ON orders(status);

-- Avoid functions on indexed columns
SELECT * FROM users WHERE UPPER(name) = 'JOHN';  -- BAD
SELECT * FROM users WHERE name = 'John';         -- GOOD

-- Use LIMIT during development
SELECT * FROM huge_table LIMIT 100;

-- ============================================================================
-- HELP & INFO
-- ============================================================================

-- Get PostgreSQL version
SELECT VERSION();

-- Get current user
SELECT CURRENT_USER;

-- Get current database
SELECT CURRENT_DATABASE();

-- List all tables
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- List all columns in table
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'users';

-- ============================================================================
-- END OF QUICK REFERENCE
-- ============================================================================

\echo 'Quick Reference Guide loaded! Copy and paste commands to use them.'
