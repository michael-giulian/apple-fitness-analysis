# Apple Fitness Workout Analysis

## Project Overview

I created this project to explore my Apple Fitness workout records from 2024–2025 while practicing data cleaning, SQL, and dashboard design.

I wanted to better understand my workout habits, including which activities I recorded most often, how long my workouts lasted, and how my activity changed over time. I used Excel Power Query to prepare the data, SQL Server to analyze it, and Tableau to present the results.

## Tools Used

| Tool | How I used it |
|---|---|
| Excel Power Query | Imported and cleaned the Apple Health export |
| SQL Server | Stored the cleaned data and queried workout records |
| Tableau | Created charts and dashboards |
| GitHub | Organized and shared my code and project documentation |

## Data Preparation

I started with an XML export from Apple Health and used Power Query to prepare the workout records and their related measurements.

My preparation included:

- Selecting the fields needed for the analysis.
- Renaming columns and making workout names easier to read.
- Setting data types for dates, durations, and measurements.
- Organizing workout details and statistics into separate tables.
- Using Workout ID to connect workouts to their statistics.
- Reviewing missing values and invalid records.

I kept missing measurements separate from zero values. For charts based on dates, I excluded entries that could not be assigned to a valid date.

After cleaning the data, I imported it into SQL Server for analysis.

## Analysis Questions

I focused on these questions:

- Which workout types did I perform most often, and what percentage did each represent?
- How much recorded workout time did I have each year?
- Which weekdays did I work out most often?
- How many workouts were short, medium, or long?
- How many workouts did I record each month?
- Which workouts lasted the longest?
- How did recorded active calories and average heart rate differ by workout type?
- Which workouts had the highest recorded active calories?

## Dashboards

### Workout Activity & Consistency

This dashboard shows monthly workout totals, workout frequency by weekday, and the distribution of workouts by activity.

![Workout Activity and Consistency dashboard](tableau-dashboard-screenshots/workout-activity-dashboard.png)

### Workout Duration

This dashboard shows recorded workout time by year, the number of workouts in each duration category, and the ten longest workouts.

The duration categories are:

| Category | Workout length |
|---|---|
| Short | Under 30 minutes |
| Medium | 30 to under 60 minutes |
| Long | 60 minutes or longer |

![Workout Duration dashboard](screenshots/workout-duration-dashboard.png)

### Calories & Heart Rate

This dashboard compares recorded active calories and average heart rate across workout types. It also includes the ten workouts with the highest recorded active calories.

![Calories and Heart Rate dashboard](screenshots/calories-heart-rate-dashboard.png)

## Findings

*I will add my main findings here after checking the final SQL results against the Tableau dashboards.*

## Limitations

- November and December 2025 data is unavailable, so the annual totals do not represent two complete years.
- Missing measurements are not treated as zero. Calorie and heart-rate summaries use the available measurements.
- These results describe my recorded workouts, which may not capture all of my physical activity.
- This project uses my personal data and is not intended to represent other people's workout habits.

## Project Files

| Folder | Contents |
|---|---|
| `sql` | Scripts for creating tables, loading data, and running the analysis |
| `power-query` | Power Query code used to prepare the data |
| `screenshots` | Images of the Tableau dashboards |
| `tableau` | Tableau workbook files |
| `data` | Any cleaned data included for sharing |

## How to Reproduce the Analysis

1. Export your data from Apple Health.
2. Use the code in `power-query` as a starting point to prepare the workout and workout-statistics tables. Update the source file path to match your computer.
3. Create an SQL Server database named `AppleFitness`.
4. Run `sql/01_Create_Tables.sql` to create the final tables.
5. Import the cleaned data into the staging tables expected by the loading script.
6. Run `sql/02_Load_Tables.sql` to populate the final tables.
7. Run the entire `sql/03_Analysis_Queries.sql` script in the same query window so its temporary tables remain available.
8. Open the Tableau workbook and update its data connections to match your files or database.

Using a different Apple Health export will produce different results. The preparation steps may also need adjustments to match the fields and activities in that export.
