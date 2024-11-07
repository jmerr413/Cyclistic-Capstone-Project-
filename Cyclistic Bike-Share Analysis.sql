-- Here are my recorded SQL scripts for my Cyclistic capstone project. I used Microsoft SQL Server for data cleaning, data transformation and analysis.


-- Merge all tables into single table
SELECT *
INTO MergeData_2023
FROM (
	SELECT *
	FROM Cyclistic_bikeshare.dbo.January_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.February_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.March_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.April_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.May_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.June_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.July_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.August_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.September_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.October_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.November_2023
	UNION ALL
	SELECT *
	FROM Cyclistic_bikeshare.dbo.December_2023
) AS MergeData;


-- Selecting created new table
SELECT *
FROM Cyclistic_bikeshare.dbo.MergeData_2023


-- Detecting Duplicate Values --
SELECT
	ride_id,
	COUNT(*) AS number_rows
FROM Cyclistic_bikeshare.dbo.MergeData_2023
GROUP BY
	ride_id
having COUNT(*) > 1


-- NO. of nulls per columns --
SELECT 
    COUNT(*) - COUNT(ride_id) AS ride_id_nulls,
    COUNT(*) - COUNT(rideable_type) AS rideable_type_nulls,
	COUNT(*) - COUNT(started_at) AS started_at_nulls,
	COUNT(*) - COUNT(ended_at) AS ended_at_nulls,
    COUNT(*) - COUNT(start_station_name) AS start_station_name_nulls,
	COUNT(*) - COUNT(start_station_id) AS start_station_id_nulls,
    COUNT(*) - COUNT(end_station_name) AS end_station_name_nulls,
	COUNT(*) - COUNT(end_station_id) AS end_station_id_nulls,
	COUNT(*) - COUNT(start_lat) AS start_lat_nulls,
	COUNT(*) - COUNT(start_lng) AS start_lng_nulls,
	COUNT(*) - COUNT(end_lat) AS end_lat_nulls,
	COUNT(*) - COUNT(end_lng) AS end_lng_nulls,
	COUNT(*) - COUNT(member_casual) AS member_casual_nulls
FROM Cyclistic_bikeshare.dbo.MergeData_2023;


-- Removing Columns --
ALTER TABLE Cyclistic_bikeshare.dbo.MergeData_2023
DROP COLUMN end_station_name,
DROP COLUMN start_station_id,
DROP COLUMN end_station_id,
DROP COLUMN start_lat,
DROP COLUMN start_lng,
DROP COLUMN end_lat,
DROP COLUMN end_lng;


-- Checking of no. of start_station_name that IS NULL --
SELECT count(ride_id)
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
WHERE start_station_name IS NULL 


-- Query for deleting rows of start_station_name that IS NULL --
DELETE
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
WHERE start_station_name IS NULL 


-- Checking number of rows left after deleting nulls --
SELECT COUNT(start_station_name) 
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]


-- Add new column (ride_length and ride_length_seconds) --
ALTER TABLE Cyclistic_bikeshare.dbo.MergeData_2023
ADD ride_length TIME,
ADD ride_length_seconds DECIMAL;


-- Calculating ride_length by subtracting started_at and ended_at columns --
SELECT 
    started_at,
    ended_at,
    -- Calculate the difference and return it as a TIME
    CAST(DATEADD(SECOND, DATEDIFF(SECOND, started_at, ended_at), 0) AS TIME) AS ride_length,
	-- Calculate the difference and formatted in seconds
	DATEDIFF(SECOND, started_at, ended_at) AS ride_length_seconds
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
ORDER BY ride_length_seconds


-- Inputing computed values to created ride_length columns --
UPDATE MergeData_2023
SET
    ride_length = CAST(DATEADD(SECOND, DATEDIFF(SECOND, started_at, ended_at), 0) AS TIME),
    ride_length_seconds = DATEDIFF(SECOND, started_at, ended_at)


-- Checking outliers from ride_length_seconds --  
SELECT started_at, ended_at, ride_length, ride_length_seconds
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
WHERE ride_length_seconds < 60 OR
ride_length_seconds > 86400


-- Deleting outliers
DELETE
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
WHERE ride_length_seconds < 60 OR
ride_length_seconds > 86400


-- Adding new column Hour, Weekday, Month --
ALTER TABLE Cyclistic_bikeshare.dbo.MergeData_2023
ADD Hour INT,
ADD Weekday NVARCHAR(15),
ADD Month NVARCHAR(15);


-- CHecking: Extracting the Hour, Weekday, Month from the Stated_at then using CASE statement-- 
SELECT started_at,
       DATEPART(HOUR, started_at) AS HOUR,
	   DATEPART(WEEKDAY, started_at) AS WEEKDAY,
       DATEPART(MONTH, started_at) AS MONTH,
       CASE
           WHEN DATEPART(WEEKDAY, started_at) = 1 THEN 'Sunday'
           WHEN DATEPART(WEEKDAY, started_at) = 2 THEN 'Monday'
           WHEN DATEPART(WEEKDAY, started_at) = 3 THEN 'Tuesday'
           WHEN DATEPART(WEEKDAY, started_at) = 4 THEN 'Wednesday'
           WHEN DATEPART(WEEKDAY, started_at) = 5 THEN 'Thursday'
           WHEN DATEPART(WEEKDAY, started_at) = 6 THEN 'Friday'
           ELSE 'Saturday'
       END AS Weekday,
       CASE
           WHEN DATEPART(MONTH, started_at) = 1 THEN 'January'
           WHEN DATEPART(MONTH, started_at) = 2 THEN 'February'
           WHEN DATEPART(MONTH, started_at) = 3 THEN 'March'
           WHEN DATEPART(MONTH, started_at) = 4 THEN 'April'
           WHEN DATEPART(MONTH, started_at) = 5 THEN 'May'
           WHEN DATEPART(MONTH, started_at) = 6 THEN 'June'
           WHEN DATEPART(MONTH, started_at) = 7 THEN 'July'
           WHEN DATEPART(MONTH, started_at) = 8 THEN 'August'
           WHEN DATEPART(MONTH, started_at) = 9 THEN 'September'
           WHEN DATEPART(MONTH, started_at) = 10 THEN 'October'
           WHEN DATEPART(MONTH, started_at) = 11 THEN 'November'
           ELSE 'December'
       END AS Month
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023];


-- Updating: Extracting the Hour, Weekday, Month from the Stated_at then using CASE statement-- 
UPDATE [Cyclistic_bikeshare].[dbo].[MergeData_2023]
SET
    Hour =
	       DATEPART(HOUR, started_at),
	Weekday =
       CASE
           WHEN DATEPART(WEEKDAY, started_at) = 1 THEN 'Sunday'
           WHEN DATEPART(WEEKDAY, started_at) = 2 THEN 'Monday'
           WHEN DATEPART(WEEKDAY, started_at) = 3 THEN 'Tuesday'
           WHEN DATEPART(WEEKDAY, started_at) = 4 THEN 'Wednesday'
           WHEN DATEPART(WEEKDAY, started_at) = 5 THEN 'Thursday'
           WHEN DATEPART(WEEKDAY, started_at) = 6 THEN 'Friday'
           ELSE 'Saturday'
       END,
	Month =
       CASE
           WHEN DATEPART(MONTH, started_at) = 1 THEN 'January'
           WHEN DATEPART(MONTH, started_at) = 2 THEN 'February'
           WHEN DATEPART(MONTH, started_at) = 3 THEN 'March'
           WHEN DATEPART(MONTH, started_at) = 4 THEN 'April'
           WHEN DATEPART(MONTH, started_at) = 5 THEN 'May'
           WHEN DATEPART(MONTH, started_at) = 6 THEN 'June'
           WHEN DATEPART(MONTH, started_at) = 7 THEN 'July'
           WHEN DATEPART(MONTH, started_at) = 8 THEN 'August'
           WHEN DATEPART(MONTH, started_at) = 9 THEN 'September'
           WHEN DATEPART(MONTH, started_at) = 10 THEN 'October'
           WHEN DATEPART(MONTH, started_at) = 11 THEN 'November'
           ELSE 'December'
       END;


-- Adding new column for season --
ALTER TABLE Cyclistic_bikeshare.dbo.MergeData_2023
ADD Season NVARCHAR(15);


-- Checking: Using the Month column, figure-out what season in that corresponding month --
SELECT Month,
       CASE
           WHEN Month IN ('December', 'January', 'February') THEN 'Winter'
           WHEN Month IN ('March', 'April', 'May') THEN 'Spring'
           WHEN Month IN ('June', 'July', 'August') THEN 'Summer'
           WHEN Month IN ('September', 'October', 'November') THEN 'Fall'
       END AS Season
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023];


-- Updating the Season column with the corresponding season in that month --
UPDATE [Cyclistic_bikeshare].[dbo].[MergeData_2023]
SET
	Season =
       CASE
           WHEN Month IN ('December', 'January', 'February') THEN 'Winter'
           WHEN Month IN ('March', 'April', 'May') THEN 'Spring'
           WHEN Month IN ('June', 'July', 'August') THEN 'Summer'
           WHEN Month IN ('September', 'October', 'November') THEN 'Fall'
       END;


-- Reformatting the values in proper case --
UPDATE [Cyclistic_bikeshare].[dbo].[MergeData_2023]
SET
	rideable_type =
		CASE
			WHEN rideable_type = 'classic_bike' THEN 'Classic Bike'
			WHEN rideable_type = 'electric_bike' THEN 'Electric Bike'
			WHEN rideable_type = 'docked_bike' THEN 'Docked Bike'
		END,
	member_casual =
		CASE
			WHEN member_casual = 'member' THEN 'Member'
			WHEN member_casual = 'casual' THEN 'Casual'
		END;


-- Finding average trip duration by member type -- 
SELECT member_casual, AVG(ride_length_seconds)/60 as trip_duration
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
GROUP BY member_casual



-- Total rides and average rides by rider type --
SELECT member_casual,
COUNT(*) AS Total_rides, 
AVG(ride_length_seconds)/60 AS average_ride_length
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
GROUP BY member_casual;

--Total no. per bicycle types by rider type--
SELECT 
    rideable_type,
    COUNT(rideable_type) AS Total_bicycle_type,
    member_casual
FROM 
    [Cyclistic_bikeshare].[dbo].[MergeData_2023]
GROUP BY 
    rideable_type, 
    member_casual
ORDER BY 
    member_casual, 
    Total_bicycle_type DESC;

--Rides taken by hour--
SELECT member_casual, hour,
COUNT(*) AS Rides
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
GROUP BY 
member_casual, hour
ORDER BY Rides DESC

--Rides taken by day of week--
SELECT member_casual, Weekday,
COUNT(*) AS Rides
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
GROUP BY 
member_casual, Weekday
ORDER BY member_casual, Rides DESC

--Rides taken by month--
SELECT member_casual, Month,
COUNT(*) AS Rides
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
GROUP BY 
member_casual, Month
ORDER BY member_casual, Rides DESC

--Rides taken by seasonal weather--
SELECT Season,
COUNT(Season) AS Rides,
(COUNT(Season)*100.0)/4732459 AS Percentage_rides
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
GROUP BY 
Season
ORDER BY Rides DESC

--Top 10 started station of Casual riders--
SELECT TOP 10 member_casual, start_station_name, 
COUNT(start_station_name) AS Total_rides_station
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
WHERE 
    member_casual = 'casual'
GROUP BY 
    member_casual, start_station_name 
ORDER BY 
    member_casual, Total_rides_station DESC;

--Top 10 started station of Member riders--
SELECT TOP 10 member_casual, start_station_name, 
COUNT(start_station_name) AS Total_rides_station
FROM [Cyclistic_bikeshare].[dbo].[MergeData_2023]
WHERE 
    member_casual = 'member'
GROUP BY 
    member_casual, start_station_name
ORDER BY 
    member_casual, Total_rides_station DESC;



