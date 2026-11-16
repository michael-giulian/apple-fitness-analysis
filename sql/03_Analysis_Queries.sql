/*
File: 03_Analysis_Queries.sql
Project: Apple Fitness Workout Analysis
Author: Michael Giulian

Purpose:
Analyze recorded workouts from 2024 and 2025 and
compare the results with the project's Tableau sheets.

Analysis includes:
- Workout counts and percentages by activity
- Total workout time by year and combined
- Workout frequency by weekday
- Workout counts by duration category
- Monthly workout totals
- Active calories burned by workout type
- Top 10 workouts by active calories, with average heart rate

Notes:
- Includes the nine workout types listed in the setup query.
- November and December 2025 data is unavailable.
- Missing measurements are not replaced with zero.
- Uses temporary tables; does not change the source tables.

Instructions:
Run the entire script in the same query window.
Requires the populated AppleFitness database.
*/

USE AppleFitness;
GO


USE AppleFitness;
GO;
-- =========================================================
-- SETUP: Select the workouts used throughout this analysis.
-- =========================================================

-- Remove temporary tables so the script can run again.
DROP TABLE IF EXISTS #workouts;
DROP TABLE IF EXISTS #activity_counts;
DROP TABLE IF EXISTS #yearly_totals;
DROP TABLE IF EXISTS #duration_categories;
DROP TABLE IF EXISTS #workout_months;
DROP TABLE IF EXISTS #monthly_counts;
DROP TABLE IF EXISTS #calories;
DROP TABLE IF EXISTS #heart_rate;

-- Use the same dates and activities for every query.
-- Use numeric minutes for calculations.
-- Keep the formatted duration for display.
SELECT
    WorkoutID,
    WorkoutType,
    WorkoutStartTimestamp,
    DurationMinutes,
    DurationDisplay
INTO #workouts
FROM dbo.Workouts
WHERE WorkoutStartTimestamp >= '20240101'
  AND WorkoutStartTimestamp < '20260101'
  AND WorkoutType IN
  (
      'Cooldown',
      'Cycling',
      'Elliptical',
      'Hiking',
      'Rowing',
      'Running',
      'Walking',
      'Weight Training',
      'Yoga'
  );

-- =========================================================
-- STEP 1: Which workout types did I perform most often,
-- and what percentage did each represent?
-- Tableau: Workout Distribution by Activity
-- =========================================================
SELECT
    WorkoutType,
    COUNT(DISTINCT WorkoutID) AS TotalWorkouts
INTO #activity_counts
FROM #workouts
GROUP BY WorkoutType;

SELECT
    WorkoutType,
    TotalWorkouts,
    CAST(
        TotalWorkouts * 100.0 /
        NULLIF(
            (SELECT SUM(TotalWorkouts) FROM #activity_counts),
            0
        )
        AS DECIMAL(5,2)
    ) AS PercentOfWorkouts
FROM #activity_counts
ORDER BY TotalWorkouts DESC, WorkoutType;

-- =========================================================
-- STEP 2: How much recorded workout time was there each year?
-- Tableau: Total Workout Time by Year
-- November and December 2025 are missing in this dataset. The values are NULL.
-- These totals describe available records.
-- =========================================================
-- Calculate each year's total.
SELECT
    CAST(YEAR(WorkoutStartTimestamp) AS VARCHAR(20))
        AS WorkoutYear,
    SUM(DurationMinutes) / 60.0 AS TotalHours,
    CAST(ROUND(SUM(DurationMinutes), 0) AS INT)
        AS RoundedMinutes,
    1 AS SortOrder
INTO #yearly_totals
FROM #workouts
GROUP BY YEAR(WorkoutStartTimestamp)
UNION ALL

-- Add the combined total.
SELECT
    'Combined Total',
    SUM(DurationMinutes) / 60.0,
    CAST(ROUND(SUM(DurationMinutes), 0) AS INT),
    2
FROM #workouts;

-- Display numeric hours and an hours:minutes label.
SELECT
    WorkoutYear,
    CAST(TotalHours AS DECIMAL(10,2)) AS TotalHours,
    CAST(RoundedMinutes / 60 AS VARCHAR(10))
        + ':'
        + RIGHT(
            '0' + CAST(RoundedMinutes % 60 AS VARCHAR(2)),
            2
        ) AS HoursAndMinutes
FROM #yearly_totals
ORDER BY SortOrder, WorkoutYear;

-- =========================================================
-- STEP 3: How many workouts did I record on each weekday?
-- Tableau: Frequency by Weekday
-- =========================================================

SET LANGUAGE us_english;
SET DATEFIRST 7; -- Sunday = 1; Saturday = 7.

SELECT
    DATEPART(WEEKDAY, WorkoutStartTimestamp) AS WeekdayNumber,
    DATENAME(WEEKDAY, WorkoutStartTimestamp) AS WeekdayName,
    COUNT(DISTINCT WorkoutID) AS TotalWorkouts
FROM #workouts
GROUP BY
    DATEPART(WEEKDAY, WorkoutStartTimestamp),
    DATENAME(WEEKDAY, WorkoutStartTimestamp)
ORDER BY WeekdayNumber;

-- =========================================================
-- STEP 4: How many workouts were short, medium, or long?
-- Tableau: Workouts by Duration
-- =========================================================

SELECT
    WorkoutID,
    CASE
        WHEN DurationMinutes IS NULL THEN NULL
        WHEN DurationMinutes < 30
            THEN 'Short: Less than 30 mins'
        WHEN DurationMinutes < 60
            THEN 'Medium: 30 to under 60 mins'
        ELSE 'Long: 60 minutes or longer'
    END AS DurationCategory,
    CASE
        WHEN DurationMinutes IS NULL THEN 4
        WHEN DurationMinutes < 30 THEN 1
        WHEN DurationMinutes < 60 THEN 2
        ELSE 3
    END AS CategoryOrder
INTO #duration_categories
FROM #workouts;

SELECT
    DurationCategory,
    COUNT(DISTINCT WorkoutID) AS TotalWorkouts
FROM #duration_categories
GROUP BY DurationCategory, CategoryOrder
ORDER BY CategoryOrder;


-- =========================================================
-- STEP 5: How many workouts did I record each month?
-- Tableau: Monthly Workout Totals
-- List every month in 2024 and 2025.
-- Months without records remain NULL, not zero.
-- =========================================================

CREATE TABLE #workout_months
(
    MonthStart DATE PRIMARY KEY
);

DECLARE @MonthStart DATE = '20240101';
WHILE @MonthStart < '20260101'
BEGIN
    INSERT INTO #workout_months (MonthStart)
    VALUES (@MonthStart);
    SET @MonthStart = DATEADD(MONTH, 1, @MonthStart);
END;

-- Count workouts in months that have records.
SELECT
    DATEFROMPARTS(
        YEAR(WorkoutStartTimestamp),
        MONTH(WorkoutStartTimestamp),
        1
    ) AS MonthStart,
    COUNT(DISTINCT WorkoutID) AS TotalWorkouts
INTO #monthly_counts
FROM #workouts
GROUP BY
    YEAR(WorkoutStartTimestamp),
    MONTH(WorkoutStartTimestamp);

-- Keep calendar months even when no records match.
SELECT
    m.MonthStart,
    c.TotalWorkouts
FROM #workout_months AS m
LEFT JOIN #monthly_counts AS c
    ON m.MonthStart = c.MonthStart
ORDER BY m.MonthStart;


-- =========================================================
-- STEP 6: Which workout types burned the most active calories?
-- Tableau: Calories Burned by Workout Type
-- =========================================================

-- Calculate active calories for each selected workout.
SELECT
    s.WorkoutID,
    SUM(s.MetricTotal) AS ActiveCalories
INTO #calories
FROM dbo.WorkoutStatistics AS s
INNER JOIN #workouts AS w
    ON s.WorkoutID = w.WorkoutID
WHERE s.MetricType = 'Active Energy Burned'
  AND s.Unit = 'kcal'
GROUP BY s.WorkoutID;

-- Keep workout types even if calorie values are missing.
SELECT
    w.WorkoutType,
    CAST(SUM(c.ActiveCalories) AS DECIMAL(12,2))
        AS TotalActiveCalories
FROM #workouts AS w
LEFT JOIN #calories AS c
    ON w.WorkoutID = c.WorkoutID
GROUP BY w.WorkoutType
ORDER BY w.WorkoutType;

-- =========================================================
-- STEP 7: Which 10 workouts burned the most active calories?
-- Tableau: Top 10 Workouts by Calories Burned
-- =========================================================

-- Calculate one heart-rate average for each selected workout.
-- Confirm that these Heart Rate records use BPM.
-- If multiple summary rows exist, each receives equal weight.
SELECT
    s.WorkoutID,
    AVG(s.MetricAverage) AS AverageHeartRate
INTO #heart_rate
FROM dbo.WorkoutStatistics AS s
INNER JOIN #workouts AS w
    ON s.WorkoutID = w.WorkoutID
WHERE s.MetricType = 'Heart Rate'
  AND s.MetricAverage IS NOT NULL
GROUP BY s.WorkoutID;

-- Rank workouts with recorded calories.
-- Retain a workout even if its heart rate is missing.
SELECT TOP (10)
    w.WorkoutID,
    w.WorkoutStartTimestamp,
    w.WorkoutType,
    w.DurationDisplay AS WorkoutDuration,
    CAST(c.ActiveCalories AS DECIMAL(12,2))
        AS ActiveCalories_kcal,
    CAST(h.AverageHeartRate AS DECIMAL(10,2))
        AS AverageHeartRate_BPM
FROM #workouts AS w
INNER JOIN #calories AS c
    ON w.WorkoutID = c.WorkoutID
LEFT JOIN #heart_rate AS h
    ON w.WorkoutID = h.WorkoutID
WHERE c.ActiveCalories IS NOT NULL
ORDER BY c.ActiveCalories DESC, w.WorkoutID;




