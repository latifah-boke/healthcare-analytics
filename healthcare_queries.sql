-- Healthcare Analytics: SQL business questions
-- Author: Latifah Boke
-- Tool: SQLite (sqliteonline.com)
-- Table: Patients (54,860 cleaned rows)
-- Some column names were shortened on import:
--   medical_conditio, date_of_admissio, insurance_provid
-- Note: the dataset is synthetic, so results are very similar across groups.


-- Q1. Average bill by medical condition
-- Result: Obesity highest (£25,859.22), Cancer lowest (£25,205.92).
-- Less than 3% difference, so condition doesn't explain cost.
SELECT medical_conditio,
       ROUND(AVG(billing_amount), 2) AS avg_bill
FROM Patients
GROUP BY medical_conditio
ORDER BY avg_bill DESC;


-- Q2. Average length of stay by admission type
-- Result: Emergency 15.6, Elective 15.5, Urgent 15.4 days.
SELECT admission_type,
       ROUND(AVG(length_of_stay), 1) AS avg_stay
FROM Patients
GROUP BY admission_type
ORDER BY avg_stay DESC;


-- Q3. Average length of stay by medical condition
-- Result: Asthma highest (15.7 days); Obesity, Hypertension and Diabetes lowest (15.4).
SELECT medical_conditio,
       ROUND(AVG(length_of_stay), 1) AS avg_stay
FROM Patients
GROUP BY medical_conditio
ORDER BY avg_stay DESC;


-- Q4. Patients, total bill and average bill by insurance provider
-- Result: Cigna has the highest total (£284.3m, 11,115 patients) but only the
-- 4th highest average. Medicare has the highest average (£25,678.09).
-- Lesson: totals and averages can tell different stories.
SELECT insurance_provid,
       COUNT(*) AS patients,
       ROUND(SUM(billing_amount), 2) AS total_bill,
       ROUND(AVG(billing_amount), 2) AS avg_bill
FROM Patients
GROUP BY insurance_provid
ORDER BY total_bill DESC;


-- Q5. Admissions per year
-- Result: 2019: 7,280 / 2020: 11,157 / 2021: 10,795 / 2022: 10,891 /
-- 2023: 10,918 / 2024: 3,819. Data runs 8 May 2019 to 7 May 2024,
-- so 2019 and 2024 are incomplete years, not quieter ones.
SELECT SUBSTR(date_of_admissio, -4) AS year,
       COUNT(*) AS admissions
FROM Patients
GROUP BY year
ORDER BY year;


-- Q6. Patients and average bill by age group (10-year groups)
-- Result: ages 13 to 89. 11-20 has the highest average (£26,029.52) but only
-- 2,415 patients; the other groups range from £25,422 to £25,706.
SELECT CASE
         WHEN age BETWEEN 11 AND 20 THEN '11-20'
         WHEN age BETWEEN 21 AND 30 THEN '21-30'
         WHEN age BETWEEN 31 AND 40 THEN '31-40'
         WHEN age BETWEEN 41 AND 50 THEN '41-50'
         WHEN age BETWEEN 51 AND 60 THEN '51-60'
         WHEN age BETWEEN 61 AND 70 THEN '61-70'
         WHEN age BETWEEN 71 AND 80 THEN '71-80'
         ELSE '81-90'
       END AS age_group,
       COUNT(*) AS patients,
       ROUND(AVG(billing_amount), 2) AS avg_bill
FROM Patients
GROUP BY age_group
ORDER BY age_group;


-- Q7. Average bill by length of stay
-- Result: 01-07 days £25,721.88 / 08-14 £25,614.91 / 15-21 £25,488.52 /
-- 22-30 £25,561.59. Longer stays don't cost more, the clearest sign the
-- billing amounts are random (synthetic data).
SELECT CASE
         WHEN length_of_stay BETWEEN 1 AND 7 THEN '01-07'
         WHEN length_of_stay BETWEEN 8 AND 14 THEN '08-14'
         WHEN length_of_stay BETWEEN 15 AND 21 THEN '15-21'
         ELSE '22-30'
       END AS stay_group,
       ROUND(AVG(billing_amount), 2) AS avg_bill
FROM Patients
GROUP BY stay_group
ORDER BY stay_group;


-- departments: a small practice table mapping each condition to a department
-- (department, condition), including Dermatology, which has no patients.

-- Q8. Patients per department (INNER JOIN)
-- Result: Endocrinology 18,324 (Diabetes + Obesity), Rheumatology 9,207,
-- Cardiology 9,131, Oncology 9,121, Respiratory 9,077.
-- An INNER JOIN drops Dermatology because it has no matching patients.
SELECT departments.department,
       COUNT(*) AS patients
FROM departments
INNER JOIN Patients
  ON departments.condition = Patients.medical_conditio
GROUP BY departments.department
ORDER BY patients DESC;


-- Q9. Patients, average bill and average stay for every department, busiest first
-- Result: Endocrinology first (18,324). Dermatology shows 0 patients and NULL averages.
-- COUNT(name) instead of COUNT(*) so a department with no patients counts as 0.
SELECT department,
       COUNT(name) AS patients,
       ROUND(AVG(billing_amount), 2) AS avg_bill,
       ROUND(AVG(length_of_stay), 1) AS avg_stay
FROM departments
LEFT JOIN Patients
  ON departments.condition = Patients.medical_conditio
GROUP BY department
ORDER BY patients DESC;


-- Q10. Departments with more than 9,100 patients, longest average stay first
-- Result: Rheumatology 15.5, Oncology 15.5, Endocrinology 15.4, Cardiology 15.4.
-- Respiratory (9,077) is left out.
SELECT department,
       COUNT(name) AS patients,
       ROUND(AVG(length_of_stay), 1) AS avg_stay
FROM departments
LEFT JOIN Patients
  ON departments.condition = Patients.medical_conditio
GROUP BY department
HAVING COUNT(name) > 9100
ORDER BY avg_stay DESC, patients DESC;


-- Q11. Conditions with an average bill above the overall average
-- The subquery works out the overall average itself.
-- HAVING (not WHERE) because the filter is on a group average.
SELECT medical_conditio,
       ROUND(AVG(billing_amount), 2) AS avg_bill
FROM Patients
GROUP BY medical_conditio
HAVING AVG(billing_amount) > (SELECT AVG(billing_amount) FROM Patients)
ORDER BY avg_bill DESC;
