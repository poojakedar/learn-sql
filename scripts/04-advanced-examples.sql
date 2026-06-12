-- ============================================================================
-- 04-advanced-examples.sql - Advanced Concepts Examples
-- ============================================================================
-- Demonstrations of advanced PostgreSQL features

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- Create a procedure to give raises
CREATE OR REPLACE PROCEDURE raise_salary(
    p_emp_id INTEGER,
    p_raise_amount DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_salary DECIMAL;
    v_new_salary DECIMAL;
BEGIN
    -- Get old salary
    SELECT salary INTO v_old_salary FROM employees WHERE emp_id = p_emp_id;
    
    -- Update salary
    UPDATE employees 
    SET salary = salary + p_raise_amount 
    WHERE emp_id = p_emp_id;
    
    -- Get new salary
    SELECT salary INTO v_new_salary FROM employees WHERE emp_id = p_emp_id;
    
    -- Log change
    INSERT INTO employee_audit (emp_id, old_salary, new_salary, operation)
    VALUES (p_emp_id, v_old_salary, v_new_salary, 'RAISE');
    
    RAISE NOTICE 'Salary updated for employee % from % to %', p_emp_id, v_old_salary, v_new_salary;
END;
$$;

-- Call procedure
-- CALL raise_salary(1, 5000);

-- ============================================================================
-- STORED FUNCTIONS
-- ============================================================================

-- Function to calculate years of service
CREATE OR REPLACE FUNCTION years_of_service(p_emp_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_years INTEGER;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date))::INTEGER
    INTO v_years
    FROM employees
    WHERE emp_id = p_emp_id;
    
    RETURN COALESCE(v_years, 0);
END;
$$ LANGUAGE plpgsql;

-- Use function
SELECT 
    emp_name,
    hire_date,
    years_of_service(emp_id) as years_employed
FROM employees
ORDER BY hire_date;

-- Function to get department budget vs salary expense
CREATE OR REPLACE FUNCTION dept_budget_report(p_dept_id INTEGER)
RETURNS TABLE (
    dept_name VARCHAR,
    total_budget DECIMAL,
    salary_expense DECIMAL,
    remaining_budget DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.dept_name,
        d.budget,
        COALESCE(SUM(e.salary), 0),
        d.budget - COALESCE(SUM(e.salary), 0)
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.dept_id
    WHERE d.dept_id = p_dept_id
    GROUP BY d.dept_id, d.dept_name, d.budget;
END;
$$ LANGUAGE plpgsql;

-- Use function
SELECT * FROM dept_budget_report(1);
SELECT * FROM dept_budget_report(2);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Create trigger function to log salary changes
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salary <> OLD.salary THEN
        INSERT INTO employee_audit (emp_id, old_salary, new_salary, operation)
        VALUES (NEW.emp_id, OLD.salary, NEW.salary, 'UPDATE');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER salary_update_trigger
AFTER UPDATE OF salary ON employees
FOR EACH ROW
EXECUTE FUNCTION log_salary_change();

-- Create trigger function to prevent department deletion with employees
CREATE OR REPLACE FUNCTION check_department_before_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM employees WHERE dept_id = OLD.dept_id) > 0 THEN
        RAISE EXCEPTION 'Cannot delete department with employees assigned';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER department_delete_check
BEFORE DELETE ON departments
FOR EACH ROW
EXECUTE FUNCTION check_department_before_delete();

-- ============================================================================
-- TRANSACTIONS
-- ============================================================================

-- Transfer employee with transaction
BEGIN;
    -- Move employee to new department
    UPDATE employees SET dept_id = 2 WHERE emp_id = 1;
    
    -- Give them a raise
    CALL raise_salary(1, 5000);
    
    -- All changes commit together
COMMIT;

-- Rollback example (commented out - would undo all changes)
-- BEGIN;
--     DELETE FROM project_assignments WHERE emp_id = 1;
--     DELETE FROM employees WHERE emp_id = 1;
-- ROLLBACK;  -- All changes undone

-- ============================================================================
-- WINDOW FUNCTIONS EXAMPLES
-- ============================================================================

-- Rank employees and show salary percentile
SELECT 
    emp_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as rank,
    DENSE_RANK() OVER (ORDER BY salary DESC) as dense_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY salary)::NUMERIC * 100, 2) as percentile,
    NTILE(4) OVER (ORDER BY salary) as quartile
FROM employees
ORDER BY salary DESC;

-- Running total of salaries by hire date
SELECT 
    emp_name,
    hire_date,
    salary,
    SUM(salary) OVER (ORDER BY hire_date) as running_total,
    AVG(salary) OVER (ORDER BY hire_date) as running_avg
FROM employees
ORDER BY hire_date;

-- Compare each employee's salary to department average
SELECT 
    emp_name,
    salary,
    FIRST_VALUE(salary) OVER (ORDER BY salary) as lowest_salary,
    LAST_VALUE(salary) OVER (ORDER BY salary 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as highest_salary,
    ROUND((salary - AVG(salary) OVER ())::NUMERIC / 1000, 2) as deviation_k
FROM employees;

-- ============================================================================
-- JSON OPERATIONS
-- ============================================================================

-- Update JSON field
UPDATE users_with_data 
SET metadata = jsonb_set(metadata, '{age}', '"31"')
WHERE user_id = 1;

-- Add new field to JSON
UPDATE users_with_data 
SET metadata = metadata || '{"status": "active"}'::jsonb
WHERE user_id = 1;

-- Extract array from JSON
SELECT 
    user_name,
    hobby
FROM users_with_data,
LATERAL jsonb_array_elements_text(metadata->'hobbies') AS hobby;

-- Filter by JSON field
SELECT user_name, metadata->>'city' as city
FROM users_with_data
WHERE metadata @> '{"city": "NYC"}';

-- ============================================================================
-- RECURSIVE CTEs FOR HIERARCHIES
-- ============================================================================

-- Show complete employee hierarchy with indentation
WITH RECURSIVE emp_hierarchy AS (
    -- Start with top-level employees
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        1 as level,
        emp_name as path
    FROM emp_hierarchy 
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursively add subordinates
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        eh.level + 1,
        eh.path || ' -> ' || e.emp_name
    FROM emp_hierarchy e
    JOIN emp_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT 
    REPEAT('  ', level - 1) || emp_name as org_chart,
    level,
    path
FROM emp_hierarchy
ORDER BY path;

-- Find all employees under a specific manager (3 levels deep)
WITH RECURSIVE manager_reports AS (
    -- Start with a specific manager
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        1 as depth
    FROM emp_hierarchy 
    WHERE emp_name = 'VP Engineering - Diana Wilson'
    
    UNION ALL
    
    -- Get direct and indirect reports
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        mr.depth + 1
    FROM emp_hierarchy e
    JOIN manager_reports mr ON e.manager_id = mr.emp_id
    WHERE mr.depth < 3  -- Limit recursion to 3 levels
)
SELECT * FROM manager_reports
ORDER BY depth, emp_name;

-- ============================================================================
-- COMMON TABLE EXPRESSIONS (CTEs)
-- ============================================================================

-- Multiple CTEs with complex analysis
WITH 
-- First CTE: Department statistics
dept_stats AS (
    SELECT 
        d.dept_id,
        d.dept_name,
        COUNT(e.emp_id) as emp_count,
        AVG(e.salary) as avg_salary,
        SUM(e.salary) as total_salary
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.dept_id
    GROUP BY d.dept_id, d.dept_name
),

-- Second CTE: High earners per department
high_earners AS (
    SELECT 
        e.emp_id,
        e.emp_name,
        e.salary,
        e.dept_id
    FROM employees e
    JOIN dept_stats ds ON e.dept_id = ds.dept_id
    WHERE e.salary > ds.avg_salary
),

-- Third CTE: Project participation
project_participation AS (
    SELECT 
        e.emp_id,
        e.emp_name,
        COUNT(DISTINCT pa.project_id) as project_count,
        STRING_AGG(DISTINCT p.project_name, ', ') as projects
    FROM employees e
    LEFT JOIN project_assignments pa ON e.emp_id = pa.emp_id
    LEFT JOIN projects p ON pa.project_id = p.project_id
    GROUP BY e.emp_id, e.emp_name
)

-- Final query combining all CTEs
SELECT 
    he.emp_name,
    he.salary,
    ds.avg_salary as dept_avg,
    ROUND((he.salary - ds.avg_salary)::NUMERIC, 2) as salary_above_avg,
    ds.emp_count as dept_size,
    pp.project_count,
    pp.projects
FROM high_earners he
JOIN dept_stats ds ON he.dept_id = ds.dept_id
LEFT JOIN project_participation pp ON he.emp_id = pp.emp_id
ORDER BY he.salary DESC;

-- ============================================================================
-- PERFORMANCE ANALYSIS
-- ============================================================================

-- Analyze query performance
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM employees WHERE salary > 60000;

-- Compare execution plans
EXPLAIN 
SELECT * FROM employees WHERE dept_id IN (1, 2, 3);

EXPLAIN 
SELECT * FROM employees WHERE dept_id = 1 
UNION ALL 
SELECT * FROM employees WHERE dept_id = 2 
UNION ALL 
SELECT * FROM employees WHERE dept_id = 3;

-- ============================================================================
-- SUMMARY VIEWS
-- ============================================================================

-- Create materialized view for company dashboard
CREATE MATERIALIZED VIEW v_company_dashboard AS
SELECT 
    (SELECT COUNT(*) FROM employees) as total_employees,
    (SELECT AVG(salary) FROM employees)::NUMERIC(10,2) as avg_salary,
    (SELECT MAX(salary) FROM employees)::NUMERIC(10,2) as max_salary,
    (SELECT COUNT(DISTINCT dept_id) FROM employees) as dept_count,
    (SELECT COUNT(*) FROM projects) as total_projects,
    (SELECT COUNT(*) FROM project_assignments) as total_assignments;

-- Query materialized view
SELECT * FROM v_company_dashboard;

-- Refresh materialized view when data changes
-- REFRESH MATERIALIZED VIEW v_company_dashboard;

-- ============================================================================
-- END OF ADVANCED EXAMPLES
-- ============================================================================

\echo 'Advanced examples complete! Review the procedures, functions, and CTEs above.'
