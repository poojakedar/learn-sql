# SQL INTERMEDIATE - PostgreSQL Tutorial

Build on your SQL basics by mastering queries, joins, aggregations, and more.

---

## 1. JOIN OPERATIONS

Joins combine data from multiple tables based on related columns.

### Table Setup for Examples
```sql
-- Create tables for demonstration
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    dept_id INTEGER,
    salary DECIMAL(10, 2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Insert sample data
INSERT INTO departments (dept_name) VALUES 
('Sales'), ('Engineering'), ('HR');

INSERT INTO employees (emp_name, dept_id, salary) VALUES
('Alice', 1, 50000),
('Bob', 1, 55000),
('Charlie', 2, 75000),
('Diana', 2, 80000),
('Eve', 3, 45000),
('Frank', NULL, 40000);  -- No department assigned
```

### INNER JOIN
Returns rows that have matches in both tables.

```sql
SELECT 
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
```

**Result**: Only employees with assigned departments appear.

### LEFT JOIN (LEFT OUTER JOIN)
Returns all rows from the left table, matched rows from the right table.

```sql
SELECT 
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

**Result**: All employees appear, including Frank (with NULL department).

### RIGHT JOIN (RIGHT OUTER JOIN)
Returns all rows from the right table, matched rows from the left table.

```sql
SELECT 
    d.dept_name,
    e.emp_name,
    e.salary
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
```

**Result**: All departments appear, even if no employees.

### FULL OUTER JOIN
Returns all rows from both tables.

```sql
SELECT 
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;
```

**Result**: All employees and departments appear.

### CROSS JOIN
Combines every row from the first table with every row from the second.

```sql
SELECT 
    e.emp_name,
    d.dept_name
FROM employees e
CROSS JOIN departments d;
```

**Result**: Cartesian product (6 employees × 3 departments = 18 rows).

### Self Join
Join a table to itself.

```sql
CREATE TABLE employees_with_manager (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100),
    manager_id INTEGER
);

-- Get employee names with their manager's name
SELECT 
    e.emp_name AS "Employee",
    m.emp_name AS "Manager"
FROM employees_with_manager e
LEFT JOIN employees_with_manager m ON e.manager_id = m.emp_id;
```

---

## 2. AGGREGATE FUNCTIONS

Perform calculations on sets of rows.

### COUNT - Count rows
```sql
SELECT COUNT(*) FROM employees;                    -- All rows
SELECT COUNT(dept_id) FROM employees;              -- Non-NULL values
SELECT COUNT(DISTINCT dept_id) FROM employees;     -- Unique departments
```

### SUM - Total values
```sql
SELECT SUM(salary) FROM employees;
```

### AVG - Average value
```sql
SELECT AVG(salary) FROM employees;
```

### MIN - Minimum value
```sql
SELECT MIN(salary) FROM employees;
```

### MAX - Maximum value
```sql
SELECT MAX(salary) FROM employees;
```

### STDDEV - Standard deviation
```sql
SELECT STDDEV(salary) FROM employees;
```

---

## 3. GROUP BY AND HAVING

Group rows and perform aggregations.

### GROUP BY
```sql
-- Get total salary by department
SELECT 
    d.dept_name,
    COUNT(*) AS employee_count,
    SUM(e.salary) AS total_salary,
    AVG(e.salary) AS avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;
```

### HAVING - Filter grouped results
```sql
-- Get departments with total salary > 100000
SELECT 
    d.dept_name,
    SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING SUM(e.salary) > 100000;
```

**Difference**: WHERE filters rows before grouping; HAVING filters groups after aggregation.

```sql
-- Employees > 50000 salary, then group by department, then get depts with avg > 60000
SELECT 
    d.dept_name,
    AVG(e.salary) AS avg_salary
FROM employees e
WHERE e.salary > 50000                           -- WHERE: before grouping
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 60000;                    -- HAVING: after grouping
```

---

## 4. SUBQUERIES (Derived Tables)

Query within a query.

### Subquery in WHERE Clause
```sql
-- Get employees with above-average salary
SELECT * FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);
```

### Subquery in FROM Clause
```sql
-- Get average salary per department
SELECT 
    dept_id,
    AVG(salary) as avg_salary
FROM employees
GROUP BY dept_id;

-- Use above query as subquery
SELECT 
    subq.dept_id,
    subq.avg_salary
FROM (
    SELECT 
        dept_id,
        AVG(salary) as avg_salary
    FROM employees
    GROUP BY dept_id
) subq
WHERE subq.avg_salary > 60000;
```

### IN with Subquery
```sql
-- Get employees in departments with more than 2 employees
SELECT * FROM employees 
WHERE dept_id IN (
    SELECT dept_id 
    FROM employees 
    GROUP BY dept_id 
    HAVING COUNT(*) > 2
);
```

### EXISTS with Subquery
```sql
-- Get departments that have employees
SELECT d.* FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e 
    WHERE e.dept_id = d.dept_id
);
```

---

## 5. UNION AND SET OPERATIONS

Combine results from multiple queries.

### UNION (Remove duplicates)
```sql
SELECT first_name FROM users
UNION
SELECT emp_name FROM employees;
```

### UNION ALL (Keep duplicates)
```sql
SELECT first_name FROM users
UNION ALL
SELECT emp_name FROM employees;
```

### INTERSECT (Common rows)
```sql
SELECT first_name FROM users
INTERSECT
SELECT emp_name FROM employees;
```

### EXCEPT (In first, not in second)
```sql
SELECT first_name FROM users
EXCEPT
SELECT emp_name FROM employees;
```

---

## 6. VIEWS

Virtual tables based on SQL queries.

### Create a View
```sql
CREATE VIEW employee_summary AS
SELECT 
    d.dept_name,
    COUNT(*) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;
```

### Query a View
```sql
SELECT * FROM employee_summary;
```

### Drop a View
```sql
DROP VIEW employee_summary;
DROP VIEW IF EXISTS employee_summary;  -- No error if doesn't exist
```

### Updatable Views
```sql
CREATE VIEW sales_employees AS
SELECT * FROM employees 
WHERE dept_id = 1;

-- Can insert/update/delete through this view
UPDATE sales_employees SET salary = 60000 WHERE emp_id = 1;
```

---

## 7. INDEXING FOR PERFORMANCE

Create indexes to speed up queries.

### Create an Index
```sql
CREATE INDEX idx_emp_dept ON employees(dept_id);
CREATE INDEX idx_emp_salary ON employees(salary);
```

### Composite Index
```sql
CREATE INDEX idx_emp_dept_salary ON employees(dept_id, salary);
```

### Unique Index
```sql
CREATE UNIQUE INDEX idx_emp_email ON employees(email);
```

### Full Text Search Index
```sql
CREATE INDEX idx_emp_name_fts ON employees 
USING GIN(to_tsvector('english', emp_name));
```

### Drop an Index
```sql
DROP INDEX idx_emp_dept;
```

### View Query Execution Plan
```sql
EXPLAIN SELECT * FROM employees WHERE dept_id = 2;
EXPLAIN ANALYZE SELECT * FROM employees WHERE dept_id = 2;
```

---

## 8. PRACTICE EXERCISES

### Exercise 1: INNER JOIN
```sql
-- Get employee names and their department names
SELECT e.emp_name, d.dept_name 
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
```

### Exercise 2: LEFT JOIN with COUNT
```sql
-- Count employees per department (including empty depts)
SELECT 
    d.dept_name, 
    COUNT(e.emp_id) AS emp_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;
```

### Exercise 3: GROUP BY with HAVING
```sql
-- Find departments with total salary above 100000
SELECT 
    d.dept_name,
    SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING SUM(e.salary) > 100000;
```

### Exercise 4: Subquery
```sql
-- Get employees earning more than their department's average
SELECT 
    e.emp_name, 
    e.salary,
    (SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id) as dept_avg
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id
);
```

### Exercise 5: Create and Query a View
```sql
CREATE VIEW high_earners AS
SELECT * FROM employees WHERE salary > 70000;

SELECT * FROM high_earners;
```

---

**Next**: Move to [03-ADVANCED.md](./03-ADVANCED.md) to master advanced SQL techniques!
