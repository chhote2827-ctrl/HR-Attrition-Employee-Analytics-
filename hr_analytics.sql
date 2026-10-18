-- =========================================================================
-- PROJECT: HR Analytics (Employee Attrition & Performance)
-- DATABASE: PostgreSQL
-- =========================================================================

DROP TABLE hr_analytics;

-- step 1: create table
CREATE TABLE hr_analytics (
    age INT,
    attrition VARCHAR(10),          -- 'Yes' or 'No'
    business_travel VARCHAR(50),
    daily_rate INT,
    department VARCHAR(50),
    distance_from_home INT,
    education INT,
    education_field VARCHAR(50),
    employee_count INT,
    employee_id INT PRIMARY KEY,    -- EmployeeNumber
    environment_satisfaction INT,
    gender VARCHAR(10),
    hourly_rate INT,
    job_involvement INT,
    job_level INT,
    job_role VARCHAR(50),
    job_satisfaction INT,           -- Scale 1 to 4
    marital_status VARCHAR(20),
    monthly_income INT,
    monthly_rate INT,
    num_companies_worked INT,
    over_18 VARCHAR(5),
    over_time VARCHAR(10),          -- 'Yes' or 'No'
    percent_salary_hike INT,
    performance_rating INT,
    relationship_satisfaction INT,
    standard_hours INT,
    stock_option_level INT,
    total_working_years INT,
    training_times_last_year INT,
    work_life_balance INT,
    years_at_company INT,
    years_in_current_role INT,
    years_since_last_promotion INT,
    years_with_curr_manager INT
);

-- =========================================================================
-- 2. ANALYTICAL QUERIES (Business Insights) 
-- Import file hr analysis csv 

COPY hr_analytics
FROM 'G:\kaggle dataset unzip file\WA_Fn-UseC_-HR-Employee-Attrition.csv'
WITH(
	FORMAT csv,
	HEADER TRUE,
	DELIMITER ','
);
-- =========================================================================

-- Q1. Overall Attrition Rate (Company mein total kitne percent log job chod rahe hain?)
SELECT 
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_employees,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS overall_attrition_rate_percentage
FROM hr_analytics;


-- Q2. Department-wise Attrition (Kis department mein sabse zyada employees chod rahe hain?)
SELECT 
    department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_employees,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS dept_attrition_rate
FROM hr_analytics
GROUP BY department
ORDER BY dept_attrition_rate DESC;

-- Check for Duplicates (Duplicate Rows Check)
SELECT employee_id, COUNT(*)
FROM hr_analytics
GROUP BY employee_id
HAVING COUNT(*) > 1;

--Handle NULL Values in Text Columns (UPDATE Strategy)
UPDATE hr_analytics
SET department = 'Unknown'
WHERE department IS NULL;

UPDATE hr_analytics
SET job_role = 'Unknown'
WHERE job_role IS NULL;

UPDATE hr_analytics
SET education_field = 'Unknown'
WHERE education_field IS NULL;


-- Drop Rows with Critical Missing Data (DELETE Strategy)
DELETE FROM hr_analytics
WHERE age IS NULL 
   OR monthly_income IS NULL 
   OR attrition IS NULL;


-- Quick Data Health Check (Verification)
-- Total employees aur Overall Attrition count check karne ke liye
SELECT 
    attrition, 
    COUNT(*) AS total_count
FROM hr_analytics
GROUP BY attrition;

-- Q3. Overtime Impact on Attrition (Kya overtime karne wale employees zyada resign kar rahe hain?)
SELECT 
    over_time,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_employees,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_percentage
FROM hr_analytics
GROUP BY over_time;


-- Q4. Salary Bracket vs Attrition (Kya kam salary wale log zyada job chod rahe hain?)
SELECT 
    CASE 
        WHEN monthly_income < 30000 THEN 'Low Income (<30k)'
        WHEN monthly_income BETWEEN 30000 AND 70000 THEN 'Medium Income (30k-70k)'
        ELSE 'High Income (>70k)'
    END AS income_bracket,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_employees,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM hr_analytics
GROUP BY income_bracket
ORDER BY attrition_rate DESC;


-- Q5. Job Satisfaction Level vs Attrition (Satisfaction level ka churn par asar)
SELECT 
    job_satisfaction,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_employees,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM hr_analytics
GROUP BY job_satisfaction
ORDER BY job_satisfaction ASC;


-- Q6. Distance From Home vs Attrition (Ghar ki duri aur job chodne ka relation)
SELECT 
    CASE 
        WHEN distance_from_home <= 5 THEN 'Short Distance (<=5 km)'
        WHEN distance_from_home BETWEEN 6 AND 15 THEN 'Medium Distance (6-15 km)'
        ELSE 'Long Distance (>15 km)'
    END AS distance_category,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_employees,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM hr_analytics
GROUP BY distance_category
ORDER BY attrition_rate DESC;

-- final table 
SELECT * FROM hr_analytics
LIMIT 10;
