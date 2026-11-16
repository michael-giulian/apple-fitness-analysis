/*
File: 01_Create_Tables.sql
Project: Apple Fitness Workout Analysis
Author: Michael Giulian

Purpose:
Create the AppleFitness database and its two main tables.

Tables:
- Workouts: Stores one record per workout.
- WorkoutStatistics: Stores metrics associated with each workout.

This script creates the structure but does not load data.
Run it once when setting up a new database.
*/

-- =========================================================
-- CREATE THE DATABASE
-- =========================================================

CREATE DATABASE AppleFitness;
GO

USE AppleFitness;
GO

-- =========================================================
-- CREATE THE WORKOUTS TABLE
-- =========================================================

CREATE TABLE dbo.Workouts
(
    -- Workout IDs come from the cleaned source data.
    WorkoutID INT NOT NULL,

    WorkoutType NVARCHAR(100) NOT NULL,

    -- Up to 10 total digits: 8 before the decimal and 2 after.
    DurationMinutes DECIMAL(10,2) NOT NULL,

    DurationUnit NVARCHAR(50) NOT NULL,

    -- Stores a display label such as 01:30:00.
    DurationDisplay NVARCHAR(30) NOT NULL,

    SourceName NVARCHAR(50) NOT NULL,
    SourceVersion NVARCHAR(50) NOT NULL,

    -- DATETIME2(7) stores dates and times with
    -- up to seven digits of fractional-second precision.
    -- It does not store a time-zone offset.
    CreationTimestamp DATETIME2(7) NOT NULL,
    WorkoutStartTimestamp DATETIME2(7) NOT NULL,
    WorkoutEndTimestamp DATETIME2(7) NOT NULL,

    -- Uniquely identifies each workout.
    CONSTRAINT PK_Workouts
        PRIMARY KEY (WorkoutID)
);
GO

-- =========================================================
-- CREATE THE WORKOUT STATISTICS TABLE
-- =========================================================

CREATE TABLE dbo.WorkoutStatistics
(
    -- Automatically generates IDs starting at 1,
    -- with an increment of 1. Gaps can occur.
    WorkoutStatisticsID INT IDENTITY(1,1) NOT NULL,

    -- Identifies the workout associated with this metric.
    WorkoutID INT NOT NULL,

    MetricType NVARCHAR(100) NOT NULL,

    WorkoutStartTimestamp DATETIME2(7) NOT NULL,
    WorkoutEndTimestamp DATETIME2(7) NOT NULL,

    -- NULL allows missing or not-applicable measurements.
    -- A missing measurement is not the same as zero.
    MetricAverage DECIMAL(10,2) NULL,
    MetricMinimum DECIMAL(10,2) NULL,
    MetricMaximum DECIMAL(10,2) NULL,

    Unit NVARCHAR(50) NOT NULL,

    MetricTotal DECIMAL(10,2) NULL,

    -- Uniquely identifies each statistics record.
    CONSTRAINT PK_WorkoutStatistics
        PRIMARY KEY (WorkoutStatisticsID),

    -- Requires every statistics record to reference
    -- an existing workout.
    CONSTRAINT FK_WorkoutStatistics_Workouts
        FOREIGN KEY (WorkoutID)
        REFERENCES dbo.Workouts (WorkoutID)
);
GO