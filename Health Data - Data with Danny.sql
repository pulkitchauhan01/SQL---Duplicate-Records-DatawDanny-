Health Data - Data with Danny

1. Data Inspection

SELECT *
FROM health.user_logs
LIMIT 10;

2. Record Counts

SELECT COUNT(*)
FROM health.user_logs;

3. Unique Column Counts

SELECT COUNT(DISTINCT id)
FROM health.user_logs;

4. Single Column Frequency Counts

SELECT
  measure,
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER (),
    2
  ) AS percentage
FROM health.user_logs
GROUP BY measure
ORDER BY frequency DESC;

SELECT
  id,
  COUNT(*) AS frequency,
  ROUND(
    COUNT(*) / SUM(COUNT(*)) OVER (),
    2
  ) AS percentage
FROM health.user_logs
GROUP BY id
ORDER BY frequency DESC
LIMIT 10;

5. Individual Column Distributions

SELECT 
  measure_value,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY measure_value
ORDER BY frequency DESC
LIMIT 10;

SELECT 
  systolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY systolic
ORDER BY frequency DESC
LIMIT 10;

SELECT 
  diastolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY diastolic
ORDER BY frequency DESC
LIMIT 10;

5.4. Deeper Look Into Specific Values

SELECT 
  measure,
  COUNT(*)
FROM health.user_logs
WHERE measure_value = 0
GROUP BY measure;

SELECT *
FROM health.user_logs
WHERE measure_value = 0
AND measure = 'blood_pressure'
LIMIT 10;

SELECT *
FROM health.user_logs
WHERE measure_value != 0
AND measure = 'blood_pressure'
LIMIT 10;

SELECT 
  measure,
  COUNT(*)
FROM health.user_logs
WHERE systolic IS NULL
GROUP BY measure;

SELECT 
  measure,
  COUNT(*)
FROM health.user_logs
WHERE systolic IS NULL
GROUP BY measure;


How To Deal With Duplicates

1. Detecting Duplicate Records

SELECT COUNT(*)
FROM health.user_logs;

2. Remove All Duplicates

2.1. Subqueries

SELECT COUNT(*)
FROM (
  SELECT DISTINCT *
  FROM health.user_logs
) AS subquery
;

2.2. Common Table Expression

WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT COUNT(*)
FROM deduped_logs;

2.3. Temporary Tables

DROP TABLE IF EXISTS deduplicated_user_logs;

CREATE TEMP TABLE deduplicated_user_logs AS 
SELECT DISTINCT *
FROM health.user_logs;

SELECT COUNT(*)
FROM deduplicated_user_logs;


Identifying Duplicate Records

1. Group By Counts On All Columns

SELECT
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic
ORDER BY frequency DESC;

2. Having Clause For Unique Duplicates

DROP TABLE IF EXISTS unique_duplicate_records;

CREATE TEMPORARY TABLE unique_duplicate_records AS
SELECT *
FROM health.user_logs
GROUP BY
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic
HAVING COUNT(*) > 1;

SELECT *
FROM unique_duplicate_records
LIMIT 10;

3. Retaining Duplicate Counts

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT *
FROM groupby_counts
WHERE frequency > 1
ORDER BY frequency DESC
LIMIT 10;


Exercises

1. Which id value has the most number of duplicate records in the health.user_logs table?

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT 
  id,
  SUM(frequency) AS total_duplicate_rows
FROM groupby_counts
WHERE frequency > 1
GROUP BY id
ORDER BY total_duplicate_rows DESC
LIMIT 1;

2. Which log_date value had the most duplicate records after removing the max duplicate id value from question 1?

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  WHERE id != '054250c692e07a9fa9e62e345231df4b54ff435d'
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT 
  log_date,
  SUM(frequency) AS total_duplicate_rows
FROM groupby_counts
WHERE frequency > 1
GROUP BY log_date
ORDER BY total_duplicate_rows DESC
LIMIT 1;

3. Which measure_value had the most occurences in the health.user_logs value when measure = 'weight'?

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  WHERE measure = 'weight'
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT 
  measure_value,
  SUM(frequency) AS total_duplicate_rows
FROM groupby_counts
WHERE frequency > 1
GROUP BY measure_value
ORDER BY total_duplicate_rows DESC
LIMIT 1;


SELECT 
  measure_value,
  COUNT(*) AS frequency
FROM health.user_logs
WHERE measure = 'weight'
GROUP BY measure_value
ORDER BY frequency DESC
LIMIT 1;

4. How many single duplicated rows exist when measure = 'blood_pressure' in the health.user_logs? How about the total number of duplicate records in the same table?

METHOD 1

DROP TABLE IF EXISTS unique_duplicate_records_blood_press;

CREATE TEMPORARY TABLE unique_duplicate_records_blood_press AS
SELECT *,
COUNT(*) AS frequency
FROM health.user_logs
WHERE measure = 'blood_pressure'
GROUP BY
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic
HAVING COUNT(*) > 1;

SELECT 
COUNT(*) AS single_duplicate_rows,
SUM(frequency) AS total_duplicate_records
FROM unique_duplicate_records_blood_press;

METHOD 2

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  WHERE measure = 'blood_pressure'
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  COUNT(*) as single_duplicate_rows,
  SUM(frequency) as total_duplicate_records
FROM groupby_counts
WHERE frequency > 1;

5. What percentage of records measure_value = 0 when measure = 'blood_pressure' in the health.user_logs table? How many records are there also for this same condition?


WITH all_measure_values AS (

SELECT 
  measure_value,
  COUNT(*) AS total_records,
  SUM(COUNT(*)) OVER () AS overall_total
FROM health.user_logs
WHERE measure = 'blood_pressure'
GROUP BY measure_value

)
SELECT
  measure_value,
  total_records,
  overall_total,
  ROUND(total_records::NUMERIC / overall_total,2)
FROM all_measure_values
WHERE measure_value = 0;

6. What percentage of records are duplicates in the health.user_logs table?

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  ROUND(
    100 * SUM(CASE
        WHEN frequency > 1 THEN frequency - 1
        ELSE 0 END
    ):: NUMERIC / SUM(frequency),
    2
  ) AS duplicate_percentage
FROM groupby_counts;