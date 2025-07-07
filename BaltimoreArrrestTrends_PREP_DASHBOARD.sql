/*Origina Dataset */
SELECT TOP (1000) [RowID]
      ,[CCNumber]
      ,[CrimeDateTime]
      ,[CrimeCode]
      ,[Description]
      ,[Inside_Outside]
      ,[Weapon]
      ,[Post]
      ,[Gender]
      ,[Age]
      ,[Race]
      ,[Ethnicity]
      ,[Location]
      ,[Old_District]
      ,[New_District]
      ,[Neighborhood]
      ,[Latitude]
      ,[Longitude]
      ,[GeoLocation]
      ,[PremiseType]
      ,[Total_Incidents]
      ,[x]
      ,[y]
  FROM [BaltimoreArrests].[dbo].[CRIME_DATASET]

   /* Step 1: Clean the dataset and make a seperate table */

	  SELECT DISTINCT
		[RowID],
		LTRIM(RTRIM([CCNumber])) AS CCNumber,
		TRY_CONVERT(DATETIME, LTRIM(RTRIM([CrimeDateTime]))) AS CrimeDateFormat,
		[CrimeDateTime],
		LTRIM(RTRIM([CrimeCode])) AS CrimeCode,
		LTRIM(RTRIM([Description])) AS Description,
		LTRIM(RTRIM([Inside_Outside])) AS Inside_Outside,
		LTRIM(RTRIM([Weapon])) AS Weapon,
		LTRIM(RTRIM([Post])) AS Post,
		LTRIM(RTRIM([Gender])) AS Gender,
		[Age], -- Assuming this is a numeric column
		LTRIM(RTRIM([Race])) AS Race,
		LTRIM(RTRIM([Ethnicity])) AS Ethnicity,
		LTRIM(RTRIM([Old_District])) AS Old_District,
		LTRIM(RTRIM([New_District])) AS New_District,
		LTRIM(RTRIM([Neighborhood])) AS Neighborhood,
		LTRIM(RTRIM([PremiseType])) AS PremiseType,
		[Total_Incidents] -- Assuming this is numeric
	INTO [BaltimoreArrests].[dbo].[CRIME_DATASET_CLEANED]
	FROM [BaltimoreArrests].[dbo].[CRIME_DATASET] -- Replace with the actual name of your source table
	WHERE 
		[RowID] IS NOT NULL;



-- STEP 2: Add New Helper Columns

	ALTER TABLE CRIME_DATASET_CLEANED
	ADD 
		ArrestDate DATETIME,
		ArrestYear INT,
		ArrestMonth VARCHAR(7),
		ArrestHour INT,
		TimeOfDay VARCHAR(20),
		AgeGroup VARCHAR(20),
		OffenseCategory VARCHAR(50);

	-- Convert and Normalize ArrestDate
	UPDATE CRIME_DATASET_CLEANED
	SET ArrestDate = TRY_CONVERT(DATETIME, CrimeDateTime);

	-- Extract ArrestYear and ArrestMonth
	UPDATE CRIME_DATASET_CLEANED
	SET 
		ArrestYear = YEAR(ArrestDate),
		ArrestMonth = FORMAT(ArrestDate, 'MM-yyyy');

	-- Extract ArrestHour
	UPDATE CRIME_DATASET_CLEANED
	SET ArrestHour = DATEPART(HOUR, ArrestDate);

	-- Categorize TimeOfDay
	UPDATE CRIME_DATASET_CLEANED
	SET TimeOfDay = CASE 
		WHEN ArrestHour < 6 THEN 'Overnight'
		WHEN ArrestHour < 12 THEN 'Morning'
		WHEN ArrestHour < 18 THEN 'Afternoon'
		ELSE 'Evening'
	END;

	-- Group Ages
	UPDATE CRIME_DATASET_CLEANED
	SET AgeGroup = CASE 
		WHEN Age < 18 THEN '<18 Juvenile'
		WHEN Age < 25 THEN '18-24'
		WHEN Age < 35 THEN '25-34'
		WHEN Age < 45 THEN '35-44'
		ELSE '45+'
	END;

	-- Step 3: Normalize Values
	UPDATE CRIME_DATASET_CLEANED
SET Race = 
    CASE 
        WHEN Race IS NULL OR UPPER(Race) = 'UNKNOWN' THEN 'Unknown'

        WHEN UPPER(Race) = 'BLACK_OR_AFRICAN_AMERICAN' THEN 'Black African American'
        WHEN UPPER(Race) = 'ASIAN' THEN 'Asian'
        WHEN UPPER(Race) = 'AMERICAN_INDIAN_OR_ALASKA_NATIVE' THEN 'American Indian Alaska Native'
        WHEN UPPER(Race) = 'WHITE' THEN 'White'
        WHEN UPPER(Race) = 'NATIVE_HAWAIIAN_OR_OTHER_PACIFIC_ISLANDER' THEN 'Native Hawaiian Other Pacific Islander'

        ELSE 'Unknown'
    END;

		UPDATE CRIME_DATASET_CLEANED
	SET OffenseCategory = CASE 
		WHEN OffenseCategory IS NULL THEN 'Non-Violent'
		WHEN UPPER(OffenseCategory) = 'PROPERTY' THEN 'Non-Violent'
		WHEN UPPER(OffenseCategory) = 'VIOLENT' THEN 'Violent'
		ELSE OffenseCategory
	END;


	UPDATE CRIME_DATASET_CLEANED
	SET Gender = CASE 
		WHEN UPPER(Gender) = 'F' THEN 'Female'
		WHEN UPPER(Gender) = 'M' THEN 'Male'
		ELSE 'Unknown'
	END;


	UPDATE CRIME_DATASET_CLEANED
	SET Ethnicity = CASE
		WHEN Ethnicity IS NULL OR UPPER(Ethnicity) = 'UNKNOWN' THEN 'Unknown'
		WHEN UPPER(Ethnicity) = 'HISPANIC_OR_LATINO' THEN 'Hispanic'
		WHEN UPPER(Ethnicity) = 'NOT_HISPANIC_OR_LATINO' THEN 'Non Hispanic'
		WHEN UPPER(Ethnicity) = 'EAST_ASIAN' THEN 'East Asian'
		WHEN UPPER(Ethnicity) = 'SOUTH_ASIAN' THEN 'South Asian'
		WHEN UPPER(Ethnicity) = 'MIDDLE_EASTERN' THEN 'Middle Eastern'
		ELSE 'Unknown'  -- fallback if unexpected value
	END;



-- Step 4: Statistical analysis / Advanced window functions to get reduce unecessary data

WITH YearlyCounts AS (
    SELECT 
        ArrestYear, 
        COUNT(total_incidents) AS Count_Incidents
    FROM CRIME_DATASET_CLEANED_BACKUP
    GROUP BY ArrestYear
),
Totals AS (
    SELECT 
        ArrestYear,
        Count_Incidents,
        CAST(Count_Incidents * 1.0 / SUM(Count_Incidents) OVER () AS DECIMAL(10,4)) AS Percent_Of_Total
    FROM YearlyCounts
)
SELECT 
    ArrestYear,
    Count_Incidents,
    Percent_Of_Total,
    CAST(SUM(Percent_Of_Total) OVER (ORDER BY ArrestYear) AS DECIMAL(10,4)) AS Cumulative_Percent,
    SUM(Count_Incidents) OVER (ORDER BY ArrestYear) AS Cumulative_Incidents
FROM Totals
ORDER BY ArrestYear;


/* Seeing that 92% of incidents occuring happens between 2011 & 2024
we can remove the following years of data */

DELETE FROM CRIME_DATASET_CLEANED
WHERE ArrestYear IS NULL
   OR ArrestYear IN (
        1900, 1920, 1922, 1928, 1930,
        1963, 1966, 1969, 1970, 1973,
        1975, 1976, 1977, 1978, 1979,
        1980, 1981, 1982, 1983, 1984,
        1985, 1987, 1988, 1989, 1993,
        1994, 1995, 1996, 1997, 1998,
        1999, 2000, 2001, 2002, 2003,
        2004, 2005, 2006, 2007, 2008,
        2009, 2010
   );