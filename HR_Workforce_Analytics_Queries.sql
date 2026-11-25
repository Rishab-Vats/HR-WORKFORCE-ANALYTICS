-- ============================================================================
-- HR WORKFORCE ANALYTICS - MYSQL PROJECT QUERIES
-- Dataset: HR_Analytics_DATA.csv (1,480 raw rows | 1,470 unique employees)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION: DATABASE & TABLE SETUP
-- ----------------------------------------------------------------------------

-- SETUP 1: Create the database and raw table matching all 38 columns of HR_Analytics_DATA.csv
CREATE DATABASE IF NOT EXISTS hr_workforce_analytics;
USE hr_workforce_analytics;

CREATE TABLE hr_analytics_raw (
    EmpID VARCHAR(20) NOT NULL,
    Age INT,
    AgeGroup VARCHAR(20),
    Attrition VARCHAR(10),
    BusinessTravel VARCHAR(30),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(15),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome INT,
    SalarySlab VARCHAR(20),
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 CHAR(1),
    OverTime VARCHAR(10),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT NULL
);

-- SETUP 2: Create a deduplicated employee-level view (1,470 unique EmpIDs) and standardise BusinessTravel labels
CREATE OR REPLACE VIEW hr_analytics_clean AS
WITH ranked_employees AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY EmpID ORDER BY EmployeeNumber) AS rn
    FROM hr_analytics_raw
)
SELECT
    EmpID, Age, AgeGroup, Attrition,
    CASE
        WHEN BusinessTravel = 'TravelRarely' THEN 'Travel_Rarely'
        ELSE BusinessTravel
    END AS BusinessTravel,
    DailyRate, Department, DistanceFromHome, Education, EducationField,
    EmployeeCount, EmployeeNumber, EnvironmentSatisfaction, Gender, HourlyRate,
    JobInvolvement, JobLevel, JobRole, JobSatisfaction, MaritalStatus,
    MonthlyIncome, SalarySlab, MonthlyRate, NumCompaniesWorked, Over18,
    OverTime, PercentSalaryHike, PerformanceRating, RelationshipSatisfaction,
    StandardHours, StockOptionLevel, TotalWorkingYears, TrainingTimesLastYear,
    WorkLifeBalance, YearsAtCompany, YearsInCurrentRole,
    YearsSinceLastPromotion, YearsWithCurrManager
FROM ranked_employees
WHERE rn = 1;

-- ----------------------------------------------------------------------------
-- SECTION: DATA QUALITY & PROFILING
-- ----------------------------------------------------------------------------

-- Q1: How many raw rows vs. unique employees exist, and which EmpIDs are duplicated?
SELECT
    COUNT(*) AS raw_records,
    COUNT(DISTINCT EmpID) AS unique_employees,
    COUNT(*) - COUNT(DISTINCT EmpID) AS duplicate_occurrences
FROM hr_analytics_raw;

SELECT EmpID, COUNT(*) AS occurrences
FROM hr_analytics_raw
GROUP BY EmpID
HAVING COUNT(*) > 1;

-- Q2: Which duplicated EmpIDs have conflicting YearsWithCurrManager values, and how many rows have missing values?
SELECT EmpID, COUNT(DISTINCT YearsWithCurrManager) AS distinct_manager_tenure_vals
FROM hr_analytics_raw
GROUP BY EmpID
HAVING COUNT(*) > 1 AND COUNT(DISTINCT YearsWithCurrManager) > 1;

SELECT COUNT(*) AS missing_manager_tenure_rows
FROM hr_analytics_raw
WHERE YearsWithCurrManager IS NULL;

-- Q3: Are there inconsistent labels in BusinessTravel?
SELECT BusinessTravel, COUNT(*) AS record_count
FROM hr_analytics_raw
GROUP BY BusinessTravel;

-- ----------------------------------------------------------------------------
-- SECTION: HR EXECUTIVE OVERVIEW (PAGE 1)
-- ----------------------------------------------------------------------------

-- Q4: What are the headline workforce KPIs (total employees, retained, exits, attrition rate, average monthly income, and average age)?
SELECT
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) AS retained_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employee_exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 2) AS avg_monthly_income,
    ROUND(AVG(Age), 2) AS avg_employee_age
FROM hr_analytics_clean;

-- Q5: What is the department-wise headcount, exit count, workforce share, and attrition rate?
SELECT
    Department,
    COUNT(EmpID) AS total_employees,
    ROUND(COUNT(EmpID) * 100.0 / SUM(COUNT(EmpID)) OVER (), 2) AS workforce_share_pct,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- Q6: Which job roles have the highest and lowest attrition rates?
SELECT
    JobRole,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY JobRole
ORDER BY attrition_rate_pct DESC;

-- ----------------------------------------------------------------------------
-- SECTION: ATTRITION & RETENTION ANALYSIS (PAGE 2)
-- ----------------------------------------------------------------------------

-- Q7: How does attrition vary across age groups?
SELECT
    AgeGroup,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY AgeGroup
ORDER BY attrition_rate_pct DESC;

-- Q8: How does overtime impact attrition rate and share of total exits?
SELECT
    OverTime,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS group_attrition_rate_pct,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        SUM(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)) OVER (), 2
    ) AS share_of_all_exits_pct
FROM hr_analytics_clean
GROUP BY OverTime;

-- Q9: What is the early-tenure (0-2 years) attrition rate, and how does attrition trend across company tenure bands?
SELECT
    COUNT(EmpID) AS early_tenure_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS early_tenure_exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS early_tenure_attrition_pct
FROM hr_analytics_clean
WHERE YearsAtCompany <= 2;

SELECT
    CASE
        WHEN YearsAtCompany = 0 THEN '0 Years'
        WHEN YearsAtCompany = 1 THEN '1 Year'
        WHEN YearsAtCompany = 2 THEN '2 Years'
        WHEN YearsAtCompany BETWEEN 3 AND 4 THEN '3-4 Years'
        WHEN YearsAtCompany BETWEEN 5 AND 7 THEN '5-7 Years'
        WHEN YearsAtCompany BETWEEN 8 AND 10 THEN '8-10 Years'
        ELSE '11+ Years'
    END AS tenure_band,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY tenure_band
ORDER BY MIN(YearsAtCompany);

-- Q10: How does attrition vary across professional experience bands (TotalWorkingYears)?
SELECT
    CASE
        WHEN TotalWorkingYears BETWEEN 0 AND 5 THEN '0-5 Years'
        WHEN TotalWorkingYears BETWEEN 6 AND 10 THEN '6-10 Years'
        WHEN TotalWorkingYears BETWEEN 11 AND 15 THEN '11-15 Years'
        WHEN TotalWorkingYears BETWEEN 16 AND 20 THEN '16-20 Years'
        ELSE '21+ Years'
    END AS experience_band,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY experience_band
ORDER BY MIN(TotalWorkingYears);

-- Q11: How do Job Satisfaction, Environment Satisfaction, and Work-Life Balance relate to attrition?
SELECT
    JobSatisfaction,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;

SELECT
    EnvironmentSatisfaction,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY EnvironmentSatisfaction
ORDER BY EnvironmentSatisfaction;

SELECT
    WorkLifeBalance,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;

-- Q12: How does promotion gap (YearsSinceLastPromotion) compare with employee attrition?
SELECT
    CASE
        WHEN YearsSinceLastPromotion = 0 THEN 'No Promotion Gap'
        WHEN YearsSinceLastPromotion = 1 THEN '1 Year'
        WHEN YearsSinceLastPromotion BETWEEN 2 AND 3 THEN '2-3 Years'
        WHEN YearsSinceLastPromotion BETWEEN 4 AND 5 THEN '4-5 Years'
        ELSE '6+ Years'
    END AS promotion_gap_band,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY promotion_gap_band
ORDER BY attrition_rate_pct DESC;

-- Q13: What is the average tenure at exit and average job satisfaction among leavers?
SELECT
    COUNT(EmpID) AS total_leavers,
    ROUND(AVG(YearsAtCompany), 2) AS avg_tenure_at_exit_years,
    ROUND(AVG(JobSatisfaction), 2) AS avg_job_satisfaction_leavers
FROM hr_analytics_clean
WHERE Attrition = 'Yes';

-- ----------------------------------------------------------------------------
-- SECTION: WORKFORCE DEMOGRAPHICS & STRUCTURE (PAGE 3)
-- ----------------------------------------------------------------------------

-- Q14: What are the overall workforce structure averages (experience, tenure, training sessions, and distance from home)?
SELECT
    COUNT(EmpID) AS total_employees,
    ROUND(AVG(Age), 2) AS avg_age,
    ROUND(AVG(TotalWorkingYears), 2) AS avg_professional_experience,
    ROUND(AVG(YearsAtCompany), 2) AS avg_organisational_tenure,
    ROUND(AVG(TrainingTimesLastYear), 2) AS avg_training_sessions_last_year,
    ROUND(AVG(DistanceFromHome), 2) AS avg_distance_from_home
FROM hr_analytics_clean;

-- Q15: What is the gender diversity composition of the workforce?
SELECT
    Gender,
    COUNT(EmpID) AS total_employees,
    ROUND(COUNT(EmpID) * 100.0 / SUM(COUNT(EmpID)) OVER (), 2) AS workforce_share_pct
FROM hr_analytics_clean
GROUP BY Gender;

-- Q16: How is the workforce distributed across education fields and departments (Department x Education matrix)?
SELECT
    EducationField,
    SUM(CASE WHEN Department = 'Human Resources' THEN 1 ELSE 0 END) AS human_resources,
    SUM(CASE WHEN Department = 'Research & Development' THEN 1 ELSE 0 END) AS research_and_development,
    SUM(CASE WHEN Department = 'Sales' THEN 1 ELSE 0 END) AS sales,
    COUNT(EmpID) AS total_employees,
    ROUND(COUNT(EmpID) * 100.0 / SUM(COUNT(EmpID)) OVER (), 2) AS share_pct
FROM hr_analytics_clean
GROUP BY EducationField
ORDER BY total_employees DESC;

-- Q17: How is the workforce distributed across salary slabs and what is the attrition rate in each slab?
SELECT
    SalarySlab,
    COUNT(EmpID) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS exits,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmpID), 2) AS attrition_rate_pct
FROM hr_analytics_clean
GROUP BY SalarySlab
ORDER BY attrition_rate_pct DESC;

