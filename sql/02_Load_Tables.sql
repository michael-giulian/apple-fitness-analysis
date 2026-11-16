/* Populate the final tables from staging.
   Explicit column lists map source values to destination columns
   by position and avoid relying on SELECT * column order. */

USE AppleFitness;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /* This script is for an initial load into empty final tables. */
    IF EXISTS (SELECT 1 FROM dbo.Workouts)
       OR EXISTS (SELECT 1 FROM dbo.WorkoutStatistics)
    BEGIN
        THROW 50001,
            'Load stopped: one or both final tables already contain data.',
            1;
    END;

/* Load workouts first because statistics reference their IDs.Copy workouts with the columns correctly matched. Leave WorkoutStatisticsID out of INSERT because
it generates it via IDENTITY(1,1)*/
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

   /*SELECT the following values to be copied from staging*/
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


/* SQL Server automatically generates WorkoutStatisticsID.Copy statistics with the columns correctly matched*/
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

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;

/* Compare staging and final row counts after a successful load. */
SELECT
    'Workouts' AS TableName,
    (SELECT COUNT(*) FROM dbo.Workouts_Staging) AS StagingRows,
    (SELECT COUNT(*) FROM dbo.Workouts) AS FinalRows

UNION ALL

SELECT
    'WorkoutStatistics',
    (SELECT COUNT(*) FROM dbo.WorkoutStatistics_Staging),
    (SELECT COUNT(*) FROM dbo.WorkoutStatistics);


/*Verify that the number or rows is correct for each table*/
USE AppleFitness;
GO

SELECT COUNT(*) AS TotalWorkouts
FROM dbo.Workouts;

SELECT COUNT(*) AS TotalStatistics
FROM dbo.WorkoutStatistics;