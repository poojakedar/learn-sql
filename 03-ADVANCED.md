# SQL ADVANCED - PostgreSQL Tutorial

Master advanced SQL techniques for professional database development.

---

## 1. WINDOW FUNCTIONS

Process data across sets of rows without collapsing them.

### Basic Window Function Syntax
```sql
SELECT 
    column,
    SUM(column) OVER (PARTITION BY category ORDER BY date) AS running_total
FROM table_name;
```

### ROW_NUMBER - Sequential numbering
```sql
SELECT 
    emp_name,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS rank_number
FROM employees;
```

### RANK and DENSE_RANK
```sql
-- RANK: skips numbers for ties
SELECT 
    emp_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS rank
FROM employees;

-- DENSE_RANK: no gaps for ties
SELECT 
    emp_name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank
FROM employees;
```

### PARTITION BY - Window frame
```sql
-- Rank within each department
SELECT 
    emp_name,
    dept_id,
    salary,
    RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank
FROM employees;
```

### LAG and LEAD - Previous and next row
```sql
-- Compare current salary with previous employee's
SELECT 
    emp_name,
    salary,
    LAG(salary) OVER (ORDER BY salary) AS prev_salary,
    salary - LAG(salary) OVER (ORDER BY salary) AS difference
FROM employees;

-- Get next employee's name
SELECT 
    emp_name,
    LEAD(emp_name) OVER (ORDER BY emp_id) AS next_employee
FROM employees;
```

### FIRST_VALUE and LAST_VALUE - Boundary values
```sql
SELECT 
    emp_name,
    salary,
    FIRST_VALUE(salary) OVER (ORDER BY salary) AS lowest_salary,
    LAST_VALUE(salary) OVER (
        ORDER BY salary 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS highest_salary
FROM employees;
```

### Running Total with SUM
```sql
SELECT 
    emp_name,
    salary,
    SUM(salary) OVER (ORDER BY emp_id) AS running_total
FROM employees;
```

### Percentile Functions
```sql
SELECT 
    emp_name,
    salary,
    PERCENT_RANK() OVER (ORDER BY salary) AS percentile_rank,
    NTILE(4) OVER (ORDER BY salary) AS quartile
FROM employees;
```

---

## 2. COMMON TABLE EXPRESSIONS (CTEs)

Write cleaner, more readable queries with named subqueries.

### Basic CTE with WITH
```sql
WITH high_earners AS (
    SELECT emp_id, emp_name, salary 
    FROM employees 
    WHERE salary > 70000
)
SELECT * FROM high_earners;
```

### Multiple CTEs
```sql
WITH sales_dept AS (
    SELECT emp_id, emp_name, salary 
    FROM employees 
    WHERE dept_id = 1
),
high_earners AS (
    SELECT * FROM sales_dept 
    WHERE salary > 50000
)
SELECT * FROM high_earners;
```

### Recursive CTE - Hierarchical data
```sql
-- Create employee hierarchy table
CREATE TABLE emp_hierarchy (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100),
    manager_id INTEGER
);

-- Recursive query to show management chain
WITH RECURSIVE emp_tree AS (
    -- Base case: top-level employees (no manager)
    SELECT 
        emp_id, 
        emp_name, 
        manager_id, 
        1 AS level
    FROM emp_hierarchy 
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees under each manager
    SELECT 
        e.emp_id, 
        e.emp_name, 
        e.manager_id, 
        et.level + 1
    FROM emp_hierarchy e
    JOIN emp_tree et ON e.manager_id = et.emp_id
)
SELECT 
    REPEAT('  ', level - 1) || emp_name AS emp_tree,
    level
FROM emp_tree
ORDER BY level, emp_id;
```

### CTE with Aggregate
```sql
WITH dept_stats AS (
    SELECT 
        dept_id,
        COUNT(*) AS emp_count,
        AVG(salary) AS avg_salary,
        MAX(salary) AS max_salary
    FROM employees
    GROUP BY dept_id
)
SELECT * FROM dept_stats 
WHERE emp_count > 2;
```

---

## 3. TRANSACTIONS AND ACID PROPERTIES

Ensure data consistency and reliability.

### Transaction Basics
```sql
BEGIN;

UPDATE employees SET salary = 80000 WHERE emp_id = 1;
UPDATE employees SET salary = 75000 WHERE emp_id = 2;

COMMIT;  -- Save changes
-- ROLLBACK;  -- Undo changes if error
```

### Savepoint - Partial rollback
```sql
BEGIN;

UPDATE employees SET salary = salary + 5000;

SAVEPOINT before_delete;

DELETE FROM employees WHERE salary < 40000;

-- Rollback only the delete
ROLLBACK TO before_delete;

COMMIT;
```

### ACID Properties
- **Atomicity**: All or nothing
- **Consistency**: Data integrity maintained
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed data persists

### Isolation Levels
```sql
-- Read Uncommitted (least strict)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Read Committed (default)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Repeatable Read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Serializable (strictest)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

---

## 4. STORED PROCEDURES AND FUNCTIONS

Reusable SQL code blocks.

### Create a Function
```sql
CREATE FUNCTION get_emp_by_dept(dept_id INTEGER)
RETURNS TABLE(emp_id INTEGER, emp_name VARCHAR, salary DECIMAL)
AS $$
BEGIN
    RETURN QUERY
    SELECT e.emp_id, e.emp_name, e.salary
    FROM employees e
    WHERE e.dept_id = dept_id;
END;
$$ LANGUAGE plpgsql;

-- Call function
SELECT * FROM get_emp_by_dept(1);
```

### Function with Parameters
```sql
CREATE FUNCTION give_raise(emp_id INTEGER, raise_amount DECIMAL)
RETURNS DECIMAL AS $$
DECLARE
    new_salary DECIMAL;
BEGIN
    UPDATE employees 
    SET salary = salary + raise_amount 
    WHERE emp_id = emp_id;
    
    SELECT salary INTO new_salary 
    FROM employees 
    WHERE emp_id = emp_id;
    
    RETURN new_salary;
END;
$$ LANGUAGE plpgsql;

-- Call function
SELECT give_raise(1, 5000);
```

### Stored Procedure
```sql
CREATE PROCEDURE transfer_employee(
    emp_id INTEGER, 
    new_dept_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees 
    SET dept_id = new_dept_id 
    WHERE emp_id = emp_id;
    
    RAISE NOTICE 'Employee transferred to department %', new_dept_id;
END;
$$;

-- Call procedure
CALL transfer_employee(1, 2);
```

### Drop Function/Procedure
```sql
DROP FUNCTION get_emp_by_dept(INTEGER);
DROP PROCEDURE transfer_employee(INTEGER, INTEGER);
```

---

## 5. TRIGGERS

Automatically execute code when table changes.

### Create a Trigger
```sql
-- Create audit table
CREATE TABLE employee_audit (
    audit_id SERIAL PRIMARY KEY,
    emp_id INTEGER,
    old_salary DECIMAL,
    new_salary DECIMAL,
    changed_at TIMESTAMP,
    operation VARCHAR(10)
);

-- Create trigger function
CREATE FUNCTION audit_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employee_audit (emp_id, old_salary, new_salary, changed_at, operation)
    VALUES (NEW.emp_id, OLD.salary, NEW.salary, NOW(), TG_OP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER emp_salary_audit_trigger
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION audit_salary_change();
```

### Trigger Types
```sql
-- BEFORE INSERT
CREATE TRIGGER check_salary_before_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < 0 THEN
        NEW.salary = 0;
    END IF;
END;

-- BEFORE DELETE
CREATE TRIGGER prevent_manager_delete
BEFORE DELETE ON departments
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM employees WHERE dept_id = OLD.dept_id) > 0 THEN
        RAISE EXCEPTION 'Cannot delete department with employees';
    END IF;
END;
```

### Drop Trigger
```sql
DROP TRIGGER emp_salary_audit_trigger ON employees;
```

---

## 6. JSON/JSONB OPERATIONS

Store and query semi-structured data.

### Create Table with JSON
```sql
CREATE TABLE users_with_data (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(100),
    metadata JSONB
);

INSERT INTO users_with_data (user_name, metadata) VALUES
('Alice', '{"age": 30, "city": "NYC", "hobbies": ["reading", "coding"]}'),
('Bob', '{"age": 25, "city": "LA", "hobbies": ["gaming"]}');
```

### Query JSON Data
```sql
-- Get age from JSON
SELECT 
    user_name,
    metadata->>'age' AS age,
    metadata->>'city' AS city
FROM users_with_data;

-- Get hobbies array
SELECT 
    user_name,
    metadata->'hobbies' AS hobbies
FROM users_with_data;
```

### JSON Functions
```sql
-- json_array_elements: Expand array
SELECT 
    user_name,
    hobby
FROM users_with_data,
LATERAL json_array_elements_text(metadata->'hobbies') AS hobby;

-- jsonb_set: Update JSON
UPDATE users_with_data 
SET metadata = jsonb_set(metadata, '{age}', '31')
WHERE user_id = 1;

-- jsonb_contains: Check if contains
SELECT * FROM users_with_data 
WHERE metadata @> '{"city": "NYC"}';
```

---

## 7. FULL-TEXT SEARCH

Search text efficiently.

### Create Full-Text Index
```sql
CREATE TABLE articles (
    article_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    content TEXT,
    tsv TSVECTOR
);

CREATE INDEX idx_articles_fts ON articles USING GIN(tsv);
```

### Insert with tsvector
```sql
INSERT INTO articles (title, content, tsv) VALUES
('PostgreSQL Guide', 'Learn PostgreSQL database', 
 to_tsvector('english', 'Learn PostgreSQL database')),
('SQL Basics', 'SQL is powerful', 
 to_tsvector('english', 'SQL is powerful'));
```

### Full-Text Search Query
```sql
-- Match query
SELECT * FROM articles 
WHERE tsv @@ to_tsquery('english', 'PostgreSQL');

-- Phrase search
SELECT * FROM articles 
WHERE tsv @@ to_tsquery('english', 'PostgreSQL & database');

-- Or search
SELECT * FROM articles 
WHERE tsv @@ to_tsquery('english', 'SQL | PostgreSQL');
```

---

## 8. QUERY OPTIMIZATION

Write faster queries.

### EXPLAIN - Execution Plan
```sql
EXPLAIN SELECT * FROM employees WHERE salary > 70000;

-- Detailed analysis
EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 70000;
```

### Index Strategy
```sql
-- Add index for frequently searched columns
CREATE INDEX idx_emp_salary ON employees(salary);
CREATE INDEX idx_emp_dept_salary ON employees(dept_id, salary);

-- Use LIKE with prefix for indexed search
SELECT * FROM employees WHERE emp_name LIKE 'John%';  -- Good
SELECT * FROM employees WHERE emp_name LIKE '%John';  -- Bad (full scan)
```

### Avoid Common Mistakes
```sql
-- Bad: Function on indexed column
SELECT * FROM employees WHERE EXTRACT(YEAR FROM hire_date) = 2024;

-- Better: Use range
SELECT * FROM employees 
WHERE hire_date >= '2024-01-01' AND hire_date < '2025-01-01';

-- Bad: OR with multiple indexed columns
SELECT * FROM employees WHERE dept_id = 1 OR dept_id = 2;

-- Better: Use IN
SELECT * FROM employees WHERE dept_id IN (1, 2);
```

### Query Hints
```sql
-- Force specific join
SELECT /*+ USE_HASH(e d) */ * FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;
```

---

## 9. PRACTICE EXERCISES

### Exercise 1: Window Functions
```sql
-- Rank employees by salary within each department
SELECT 
    emp_name,
    dept_id,
    salary,
    RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank
FROM employees;
```

### Exercise 2: CTE with Recursion
```sql
-- Find all reports under a specific manager (hierarchy)
WITH RECURSIVE manager_chain AS (
    SELECT emp_id, emp_name, manager_id, 1 AS level
    FROM emp_hierarchy
    WHERE emp_id = 1
    
    UNION ALL
    
    SELECT e.emp_id, e.emp_name, e.manager_id, mc.level + 1
    FROM emp_hierarchy e
    JOIN manager_chain mc ON e.manager_id = mc.emp_id
)
SELECT * FROM manager_chain;
```

### Exercise 3: Stored Procedure
```sql
-- Create procedure to give annual raises
CREATE PROCEDURE annual_raise(raise_percent DECIMAL)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees 
    SET salary = salary * (1 + raise_percent / 100);
    RAISE NOTICE 'All employees raised by %% %', raise_percent;
END;
$$;

CALL annual_raise(5);
```

### Exercise 4: Trigger
```sql
-- Create trigger to log salary changes
CREATE TRIGGER log_salary_change
AFTER UPDATE OF salary ON employees
FOR EACH ROW
EXECUTE FUNCTION audit_salary_change();
```

### Exercise 5: Full-Text Search
```sql
-- Search articles for keywords
SELECT * FROM articles 
WHERE tsv @@ to_tsquery('english', 'database & PostgreSQL');
```

---

**Congratulations!** You've mastered PostgreSQL from basics to advanced techniques. Continue practicing and exploring real-world database projects!
