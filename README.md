# HR Analytics – People, Attrition & Workforce Intelligence

An end-to-end HR analytics portfolio project using **SQL (MySQL)** and **Power BI** to examine employee attrition, workforce composition, organisational structure and employee experience.

> **Project scope:** descriptive analytics and decision support. The analysis identifies patterns and segments for HR investigation; it does not prove causation or claim that attrition has already been reduced.

## Project at a glance

| Item | Details |
|---|---|
| Dataset | `HR_Analytics.csv` |
| Raw size | 1,480 rows × 38 columns |
| Unique employees after employee-ID deduplication | 1,470 |
| Employee exits | 237 |
| Retained employees | 1,233 |
| Overall attrition rate | 16.12% |
| Retention share | 83.88% |
| Tools | MySQL, SQL, Power BI, Power Query, DAX |
| Dashboards | HR Executive Overview; Attrition & Retention Analysis; Workforce Demographics & Structure |

## Dashboard previews

### 1. HR Executive Overview
![HR Executive Overview](HR20%ANALYTICS20%DASHBOARD/HR20%EXECUTIVE20%DASHBOARD.png)

### 2. Attrition & Retention Analysis
![Attrition and Retention Analysis](HR20%ANALYTICS20%DASHBOARD/ATTRITION20%DASHBOARD.png)

### 3. Workforce Demographics & Structure
![Workforce Demographics and Structure](HR20%ANALYTICS20%DASHBOARD/WORKFORCE.png)

## Business problem

HR teams need a consistent view of workforce size, employee exits, attrition concentration and workforce composition. This project addresses questions such as:

- How many employees are in the dataset, how many left, and what is the overall attrition rate?
- Which departments and job roles have higher attrition rates?
- How does attrition differ by age, organisational tenure, professional experience and promotion-gap group?
- How does attrition compare between overtime and non-overtime groups?
- How is the workforce distributed across departments, job levels, education fields and age groups?
- What do average professional experience, organisational tenure and training participation tell us about the workforce profile?

## Dataset profile

The CSV contains **38 columns** covering:

| Category | Fields |
|---|---|
| Employee identity | EmpID, EmployeeNumber |
| Demographics | Age, AgeGroup, Gender, MaritalStatus |
| Organisation | Department, JobRole, JobLevel |
| Education | Education, EducationField |
| Compensation | MonthlyIncome, SalarySlab, PercentSalaryHike, StockOptionLevel |
| Experience and tenure | TotalWorkingYears, YearsAtCompany, YearsInCurrentRole, YearsSinceLastPromotion, YearsWithCurrManager |
| Satisfaction and engagement | JobSatisfaction, EnvironmentSatisfaction, RelationshipSatisfaction, WorkLifeBalance, JobInvolvement |
| Work conditions | OverTime, BusinessTravel, DistanceFromHome |
| Development | TrainingTimesLastYear |
| Other measures | DailyRate, HourlyRate, MonthlyRate, PerformanceRating, NumCompaniesWorked, StandardHours |

### Data quality notes

- Raw file: 1,480 rows and 38 columns.
- 10 repeated EmpID occurrences were found (10 duplicate IDs beyond the first record); 7 rows were fully duplicated.
- Three duplicated employee IDs have conflicting `YearsWithCurrManager` values. The reported dashboard calculations use one row per EmpID, retaining the first occurrence. Verify those records against the source before production use.
- `YearsWithCurrManager` has 57 missing values.
- Standardise inconsistent `BusinessTravel` category labels before analysing that field.
- Use employee-level deduplication consistently. `DISTINCTCOUNT(EmpID)` protects headcount measures but does not automatically remove duplicate-row effects from averages.

## Headline findings

- **16.12% overall attrition:** 237 of 1,470 unique employees are marked as having left.
- **83.88% retained:** 1,233 employees are marked as not having left.
- **Overtime comparison:** attrition is 30.53% for employees with overtime and 10.44% for employees without overtime.
- **Early-tenure pattern:** employees with 0–2 years at the company have 29.82% attrition (102 exits among 342 employees).
- **Role-level hotspot:** Sales Representatives show 39.76% attrition (33 of 83); Laboratory Technicians show 23.94% (62 of 259).
- **Department comparison:** Sales 20.63%; Human Resources 19.05%; Research & Development 13.84%.
- **Age pattern:** the 18–25 group has 35.77% attrition (44 of 123).
- **Workforce profile:** average age 36.92 years; average professional experience 11.28 years; average organisational tenure 7.01 years.
- **Workforce distribution:** Research & Development 961; Sales 446; Human Resources 63.

These are descriptive associations from a static employee snapshot. They do not establish that overtime, age, tenure, satisfaction or role causes attrition.

## Dashboard 1 – HR Executive Overview

**Purpose:** give management a high-level view of workforce size, exits, department attrition and role-level differences.

**Slicers:** Department, Gender, Age Group, Job Role.

**KPIs:** Total Employees, Active/Retained Employees, Attrition Count, Attrition Rate, Average Monthly Income, Average Employee Age.

**Visuals and business questions:**
1. Employee Attrition Breakdown – how many employees left versus stayed?
2. Department-wise Attrition Rate – which department has the highest attrition rate?
3. Job Role Attrition Ranking – which roles have higher turnover rates?
4. Employee Distribution by Department – where is headcount concentrated?
5. Workforce Composition by Age Group – which age bands make up the organisation?
6. Job Role-wise Attrition Summary – how do headcount, exits and rates compare by role?

## Dashboard 2 – Attrition & Retention Analysis

**Purpose:** investigate attrition patterns across employee segments and work conditions.

**Slicers:** Department, Job Role, Age Group, OverTime, Salary Slab.

**KPIs:** Employee Attrition Rate, Total Employee Exits, Overtime Employee Attrition Rate, Average Tenure at Exit, Average Job Satisfaction of Leavers, Early-Tenure Attrition Rate.

| Visual | Business question | Finding |
|---|---|---|
| Attrition Rate by Age Group | Which age groups have higher attrition? | 18–25: 35.77%; 26–35: 19.14%; 36–45: 9.19%; 46–55: 11.50%; 55+: 17.02%. |
| Overtime vs Non-Overtime | How does attrition differ by overtime status? | Actual group rates: Yes 30.53%; No 10.44%. |
| Promotion Gap vs Employee Attrition | How does attrition vary by time since last promotion? | 0 years 18.93%; 1 year 13.73%; 2–3 years 17.06%; 4–5 years 6.60%; 6+ years 16.28%. |
| Job Satisfaction vs Attrition | How does attrition vary by satisfaction level? | Levels 1–4: 22.84%, 16.43%, 16.52%, 11.33%. |
| Attrition by Experience Levels | How does attrition vary by professional experience? | 0–5 years 28.80%; 6–10 14.99%; 11–15 12.57%; 16–20 10.07%; 21+ 7.73%. |
| Employee Attrition by Tenure | At what company-tenure stages is attrition higher? | 0 years 36.36%; 1 year 34.50%; 2 years 21.26%; 3–4 16.39%; 5–7 11.33%; 8–10 12.41%; 11+ 8.13%. |

**Important chart interpretation:** the overtime donut in the screenshot shows the *share of all exits* (127 overtime exits = 53.59%; 110 non-overtime exits = 46.41%). It does not show the attrition rate within each overtime group. For an attrition-rate comparison, use 30.53% vs 10.44% in a bar chart, or rename the donut to “Share of Employee Exits by Overtime Status”.

## Dashboard 3 – Workforce Demographics & Structure

**Purpose:** describe the employee population, organisational structure, education profile and experience mix.

**Slicers:** Department, Gender, Job Level, Education Field, Age Group.

**KPIs:** Total Employees, Average Employee Age, Average Professional Experience, Average Organisational Tenure, Average Training Sessions (Last Year), Average Distance from Home.

**Visuals and findings:**
1. Workforce Distribution by Age Group – 26–35 is the largest band (606), followed by 36–45 (468).
2. Gender Diversity Composition – 882 male (60%) and 588 female (40%).
3. Workforce Distribution by Education Field – Life Sciences 606; Medical 464; Marketing 159; Technical Degree 132; Other 82; Human Resources 27.
4. Department-wise Workforce Distribution – Research & Development 961; Sales 446; Human Resources 63.
5. Total Workforce by Experience Band – 6–10 years is the largest group (607).
6. Department-wise Educational Qualification Analysis – shows how education fields are distributed across departments.

**Screenshot label corrections:**
- The top-right chart uses education-field categories, so rename it “Workforce Distribution by Education Field” rather than “Department-wise Workforce Distribution”.
- Rename “Avg Training Participation (Years)” to “Average Training Sessions (Last Year)”. `TrainingTimesLastYear` counts sessions, not years.
- The screenshot labels DistanceFromHome as kilometres. Confirm the source unit; this dataset field is commonly recorded in miles. Use “Miles” only after verification.
- Change the gender donut legend to “Gender” rather than “Overtime”.

## SQL examples

See [`SQL/HR_Analytics_Analysis.sql`](SQL/HR_Analytics_Analysis.sql) for example MySQL queries covering:
- Overall employee count, exits and attrition rate
- Department-wise attrition
- Overtime attrition comparison
- Job-role attrition
- Education-field distribution by department
- Average experience, tenure and training sessions

## Core DAX measures

```dax
Total Employees =
DISTINCTCOUNT(HR_Analytics[EmpID])

Employee Exits =
CALCULATE(
    [Total Employees],
    HR_Analytics[Attrition] = "Yes"
)

Retained Employees =
CALCULATE(
    [Total Employees],
    HR_Analytics[Attrition] = "No"
)

Attrition Rate =
DIVIDE([Employee Exits], [Total Employees], 0)

Retention Rate =
DIVIDE([Retained Employees], [Total Employees], 0)

Overtime Attrition Rate =
DIVIDE(
    CALCULATE([Employee Exits], HR_Analytics[OverTime] = "Yes"),
    CALCULATE([Total Employees], HR_Analytics[OverTime] = "Yes"),
    0
)

Early Tenure Attrition Rate =
DIVIDE(
    CALCULATE([Employee Exits], HR_Analytics[YearsAtCompany] <= 2),
    CALCULATE([Total Employees], HR_Analytics[YearsAtCompany] <= 2),
    0
)
```

### KPI reconciliation to complete before publishing

The Dashboard 2 screenshot shows average tenure at exit of **5.12** and average job satisfaction of leavers of **2.46**. These match the raw 238 exit rows. The deduplicated employee-level dataset has 237 unique leavers; on that consistent grain, the corresponding averages are approximately **5.13 years** and **2.47 satisfaction points**. Rebuild these two measures over the same deduplicated employee-level table used for headcount and exit counts. This avoids mixing raw-row averages with distinct-employee counts.

## What business value does this project provide?

The dashboards make several HR questions measurable and easier to investigate:
- Highlight employee segments with higher observed attrition.
- Compare attrition rates using the correct segment denominator.
- Show where employee headcount is concentrated.
- Describe education, age, gender, job-level and experience composition.
- Provide a starting point for targeted HR investigations and workforce planning.

**Do not claim a percentage of HR problems solved.** The project has no intervention or post-intervention outcome data, so it cannot demonstrate a reduction in attrition or quantify realised savings. It provides analytical visibility and evidence to guide further action.

## Limitations

- No hire or exit dates: no monthly or quarterly attrition trend.
- No exit reasons: no confirmed explanation for why employees left.
- No salary history: no salary growth over time.
- No recruitment data: no time-to-hire or cost-per-hire.
- No performance history: no longitudinal performance analysis.
- Cross-sectional relationships are descriptive, not causal.
- Duplicate employee IDs and missing manager-tenure values require validation.


## Conclusion

This project turns employee-level HR data into a three-page Power BI reporting solution supported by SQL analysis. It identifies an overall attrition rate of **16.12%**, highlights higher observed attrition in selected roles and early-tenure groups, and describes how employees are distributed across departments, education fields, age groups and experience bands. The dashboards give HR stakeholders a clearer evidence base for deciding where to investigate and what additional data would be needed for deeper workforce decisions.
