/*Create database*/
CREATE DATABASE AppleFitness;
GO
USE AppleFitness;
GO

/*Both queries will create the tables but it will not populate them.*/

USE AppleFitness;
GO
/*Create the Workouts table*/
CREATE TABLE dbo.Workouts
(
WorkoutID INT NOT NULL, /*NOT NULL doesn't allow missing values */
WorkoutType NVARCHAR(100) NOT NULL,
DurationMinutes DECIMAL(10,2) NOT NULL, /* Store up to 10 total digits: 8 before the decimal and 2 after.*/
DurationUnit NVARCHAR(50) NOT NULL,
DurationDisplay NVARCHAR(30) NOT NULL,
SourceName NVARCHAR(50) NOT NULL,
SourceVersion NVARCHAR(50) NOT NULL,
CreationTimestamp DATETIME2(7) NOT NULL, /*CreationTimestamp will be stored */
WorkoutStartTimestamp DATETIME2(7) NOT NULL, /*DATETIME2(7) format is YYYY-MM-DD hh:mm:ss.fffffff 7 digits of fractions of seconds*/
WorkoutEndTimestamp DATETIME2(7) NOT NULL,

/*Create the Primary Key*/
CONSTRAINT PK_Workouts /* primary key name */
PRIMARY KEY (WorkoutID) /*Uniquely identifies each workout*/
);

/* Create the WorkoutStatistics table */
CREATE TABLE dbo.WorkoutStatistics
(
    WorkoutStatisticsID INT IDENTITY(1,1) NOT NULL, /* IDENTITY(1,1) tells Server to generate ID's: Starts at 1 and increases by 1 for each new value. */
    MetricType NVARCHAR(100) NOT NULL,
    WorkoutStartTimestamp DATETIME2(7) NOT NULL,
    WorkoutEndTimestamp DATETIME2(7) NOT NULL,
    MetricAverage DECIMAL(10,2) NULL, /*NULL allows missing values. NULL is missing values, unkown values, or Not Applicable data. It doesn't equal zero*/
    MetricMinimum DECIMAL(10,2) NULL,
    MetricMaximum DECIMAL(10,2) NULL,
    Unit NVARCHAR(50) NOT NULL,
    MetricTotal DECIMAL(10,2) NULL,

    CONSTRAINT PK_WorkoutStatistics
        PRIMARY KEY (WorkoutStatisticsID),

/* connect the tables using a foreign key */
    CONSTRAINT FK_WorkoutStatistics_Workouts
        FOREIGN KEY (WorkoutID) 
        REFERENCES dbo.Workouts (WorkoutID)
);
