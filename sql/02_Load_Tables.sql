/*
File: 02_Load_Tables.sql
Project: Apple Fitness Workout Analysis
Author: Michael Giulian

Purpose:
Copy cleaned data from staging into the final tables.

Before running:
- Create the database and final tables.
- Import the cleaned data into both staging tables.
- Confirm that both final tables are empty.

Notes:
- Explicit column lists match source and destination
  values by position.
- Workouts load before their related statistics.
- If either insert fails, the transaction is rolled back.
- This script does not clear or replace existing data.
*/

USE AppleFitness;
GO

-- Roll back the transaction for qualifying runtime errors.
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Stop if either final table already contains data.
    IF EXISTS (SELECT 1 FROM dbo.Workouts)
       OR EXISTS (SELECT 1 FROM dbo.WorkoutStatistics)
    BEGIN
        THROW 50001,
            'Load stopped: one or both final tables already contain data.',
            1;
    END;

    -- =====================================================
    -- LOAD WORKOUTS
    -- =====================================================

    -- Load workouts first because statistics reference
    -- their WorkoutID values.
    INSERT INTO dbo.Workouts
    (
        WorkoutID,
        WorkoutType,
        DurationMinutes,
        DurationUnit,
        DurationDisplay,
        SourceName,
        SourceVersion,
        CreationTimestamp,
        WorkoutStartTimestamp,
        WorkoutEndTimestamp
    )
    SELECT
        WorkoutID,
        WorkoutType,
        DurationMinutes,
        DurationUnit,
        DurationDisplay,
        SourceName,
        SourceVersion,
        CreationTimestamp,
        WorkoutStartTimestamp,
        WorkoutEndTimestamp
    FROM dbo.Workouts_Staging;

    -- =====================================================
    -- LOAD WORKOUT STATISTICS
    -- =====================================================

    -- Omit WorkoutStatisticsID because SQL Server
    -- generates it automatically using IDENTITY(1,1).
    INSERT INTO dbo.WorkoutStatistics
    (
        WorkoutID,
        MetricType,
        WorkoutStartTimestamp,
        WorkoutEndTimestamp,
        MetricAverage,
        MetricMinimum,
        MetricMaximum,
        Unit,
        MetricTotal
    )
    SELECT
        WorkoutID,
        MetricType,
        WorkoutStartTimestamp,
        WorkoutEndTimestamp,
        MetricAverage,
        MetricMinimum,
        MetricMaximum,
        Unit,
        MetricTotal
    FROM dbo.WorkoutStatistics_Staging;

    -- Save both inserts when they finish successfully.
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Undo the load if a transaction is still active.
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    -- Display the original error.
    THROW;
END CATCH;

-- =========================================================
-- COMPARE ROW COUNTS
-- =========================================================

-- Each staging count should match its final-table count.
SELECT
    'Workouts' AS TableName,
    (SELECT COUNT(*) FROM dbo.Workouts_Staging) AS StagingRows,
    (SELECT COUNT(*) FROM dbo.Workouts) AS FinalRows

UNION ALL

SELECT
    'WorkoutStatistics',
    (SELECT COUNT(*) FROM dbo.WorkoutStatistics_Staging),
    (SELECT COUNT(*) FROM dbo.WorkoutStatistics);