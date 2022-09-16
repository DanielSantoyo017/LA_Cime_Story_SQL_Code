
----2019 FBI Data, California cities crime trends (Dash board #1)

--A.Fidning top 10 crime categories in california (with crime per 100000 (A.2))
SELECT TOP 10 City, Violent_Crime, ROUND((Violent_Crime/Population)*100000,0) AS Violent_Crimes_Per_100000
FROM FBI_2019_Ca_Data
ORDER BY Violent_Crime DESC

--B. Findnig the perecent that LA makes up of the top 10 cities in CA with highest crime rate 

WITH FBI_2019_Crime (City, Population, Violent_Crime) AS (
SELECT TOP 10 City, Population, Violent_Crime
FROM FBI_2019_Ca_Data
GROUP BY City, Violent_Crime, Population
ORDER BY Violent_Crime DESC
)
SELECT City, ROUND((Violent_Crime/Sum(Violent_Crime) OVER ())*100,0) AS Crime_Percentage
FROM FBI_2019_Crime
GROUP BY City, Violent_Crime
ORDER BY Violent_Crime DESC

--C. Findnig the perecent that LA makes up of the cities in CA with highest crime rate (ALl crime)
SELECT City,ROUND((Violent_Crime/Sum(Violent_Crime) OVER ())*100,3) AS Crime_Percentage
FROM FBI_2019_Ca_Data
GROUP BY City, Violent_Crime, Population
ORDER BY Violent_Crime DESC


----LA Crime Trends (Dashboard #2)

--1.) Crime in 2019 by quarter and month, Shows Monthly AVG and Yearly total 

SELECT Year, 
	Quarter, 
	Month, 
	COUNT(Crime_Description) AS Crime_Per_Month,
	AVG(COUNT(Crime_Description)) OVER () AS AVG_Crime_Per_Month,
	SUM(COUNT(Crime_Description)) OVER (Partition BY year) AS Total_Crime_Instances
FROM CrimeFact
	INNER JOIN DimDate ON CrimeFact.Date_ID = DimDate.Date_ID
WHERE Year = '2019'
GROUP BY Year, Quarter, Month
ORDER BY Quarter, Month

--2.) Finding the top 10 crimes in 2019

SELECT TOP 10 Crime_Description, 
	COUNT(Crime_Description) AS Total_Instances
FROM dbo.CrimeFact
	INNER JOIN dbo.DimDate ON dbo.CrimeFact.Date_ID = dbo.DimDate.Date_ID
WHERE Date_Occurred BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY Crime_Description
ORDER BY Total_Instances DESC


----Battery trends in 2019 (Dahsboard #3)

--1.) Yearly total and Monthly Avergage Battery crimes in LA 2019 
SELECT TOP 12  
	Year,Quarter, 
	Month, 
	COUNT(Crime_Description) AS Total_Instances,
	AVG(COUNT(Crime_Description)) OVER () AS AVG_Crime_Per_Month,
	SUM(COUNT(Crime_Description)) OVER (Partition BY year) AS Total_Crime_Instances
FROM dbo.CrimeFact
	INNER JOIN dbo.DimDate ON dbo.CrimeFact.Date_ID = dbo.DimDate.Date_ID
WHERE Date_Occurred BETWEEN '2019-01-01' AND '2019-12-31' 
	AND Crime_Description = 'Battery - Simple Assault'
GROUP BY Crime_Description, Month, Quarter, Year
ORDER BY Quarter, Month 

--2.) Daily Average and highest days of  Battery crimes in LA 2019

SELECT Crime_Description,
	Year, 
	Month,
	Day,
	COUNT(Crime_Description) AS Total_Instances,
	AVG(COUNT(Crime_Description)) OVER () AS AVG_Daily_Crime
FROM dbo.CrimeFact
	INNER JOIN dbo.DimDate ON dbo.CrimeFact.Date_ID = dbo.DimDate.Date_ID
WHERE Date_Occurred BETWEEN '2019-01-01' AND '2019-12-31' 
	AND Crime_Description = 'Battery - Simple Assault'
GROUP BY Crime_Description, Day, Month, Year
ORDER BY Total_Instances DESC


--Dashboard # 5 Sunburst Battery Victums

--1 Findig which victim demographics are most aflicated by Battery-simple assault in 2019 

SELECT Victim_Sex, Victim_Descent, Victim_Age, COUNT(Victim_Sex) AS Total_Victims
FROM dbo.CrimeFact
	INNER JOIN dbo.DimVictim ON dbo.CrimeFact.Victim_ID = dbo.DimVictim.Victim_ID
	INNER JOIN dbo.DimDate ON dbo.CrimeFact.Date_ID = dbo.DimDate.Date_ID
WHERE Date_Occurred BETWEEN '2019-01-01' AND '2019-12-31' AND Crime_Description LIKE 'Battery - Simple Assault%' AND Victim_Sex != 'NULL' AND Victim_Sex = 'Female'
GROUP BY Victim_Descent, Victim_Age, Crime_Description, Victim_Sex
ORDER BY Total_Victims DESC

SELECT Victim_Sex, Victim_Descent, Victim_Age, COUNT(Victim_Sex) AS Total_Victims
FROM dbo.CrimeFact
	INNER JOIN dbo.DimVictim ON dbo.CrimeFact.Victim_ID = dbo.DimVictim.Victim_ID
	INNER JOIN dbo.DimDate ON dbo.CrimeFact.Date_ID = dbo.DimDate.Date_ID
WHERE Date_Occurred BETWEEN '2019-01-01' AND '2019-12-31' AND Crime_Description LIKE 'Battery - Simple Assault%' AND Victim_Sex != 'NULL' AND Victim_Sex = 'Male'
GROUP BY Victim_Descent, Victim_Age, Crime_Description, Victim_Sex
ORDER BY Total_Victims DESC


--2.) Find three most common weapons used (if any) for the top five crimes committed in LA 

SELECT TOP 5 Weapon_description,  
	COUNT(Crime_Description) AS Total_Instances
FROM dbo.CrimeFact
	INNER JOIN dbo.DimDate ON dbo.CrimeFact.Date_ID = dbo.DimDate.Date_ID
	INNER JOIN dbo.DimWeapons ON dbo.CrimeFact.Weapon_ID = dbo.DimWeapons.Weapon_ID
WHERE Date_Occurred BETWEEN '2019-01-01' AND '2019-12-31'
	AND Crime_Description = 'Battery - Simple Assault'
GROUP BY Weapon_description, Crime_Description
ORDER BY Total_Instances DESC


--3.) finding the status of these crimes, Intimate Partner - Simple Assault is diffrent all others are Invest cont 

SELECT TOP 5 Status_Description, 
	COUNT(Crime_Description) AS Total_Instances
FROM dbo.CrimeFact
	INNER JOIN dbo.DimDate ON dbo.CrimeFact.Date_ID = dbo.DimDate.Date_ID
	INNER JOIN dbo.DimStatus ON dbo.CrimeFact.Status_ID = dbo.DimStatus.Status_ID
WHERE Date_Occurred BETWEEN '2019-01-01' AND '2019-12-31'
	AND Crime_Description = 'Battery - Simple Assault'
GROUP BY Status_Description, Crime_Description
ORDER BY Total_Instances DESC


--Locaiton Info (Dashboard #6)

--1.) Finding Yearly AREA info on Batery (Geo Map)

SELECT Area_Description, COUNT(Crime_Description) AS Total_Instances
FROM CrimeFact
	INNER JOIN DimLocation ON  CrimeFact.Location_ID =  DimLocation.Location_ID
	INNER JOIN DimArea ON DimArea.Area_ID = DimLocation.Area_ID
	INNER JOIN DimDate ON CrimeFact.Date_ID = DimDate.Date_ID
WHERE YEAR = '2019' AND Crime_Description = 'Battery - Simple Assault'
GROUP BY Year, Area_Description
ORDER BY Total_Instances DESC

--Premis Info, yearly Battery crimes 

SELECT TOP 10 Premis_Description, COUNT(Crime_Description) AS Total_Instances
FROM CrimeFact
INNER JOIN DimPremis ON CrimeFact.Premis_ID = DimPremis.Premis_ID
INNER JOIN DimDate ON CrimeFact.Date_ID = DimDate.Date_ID
WHERE  YEAR = '2019' AND Crime_Description = 'Battery - Simple Assault'
GROUP BY Premis_Description, Year, Crime_Description
ORDER BY Total_Instances DESC


--Central Foucs (Dashboard #7)

--Top 10 Locations in Centeral where batteries happen?

SELECT TOP 10 Area_Description, Location_Description, COUNT(Crime_Description) AS Total_Instances
FROM CrimeFact
	INNER JOIN DimLocation ON  CrimeFact.Location_ID =  DimLocation.Location_ID
	INNER JOIN DimArea ON DimArea.Area_ID = DimLocation.Area_ID
	INNER JOIN DimDate ON CrimeFact.Date_ID = DimDate.Date_ID
WHERE YEAR = '2019' AND 
	Crime_Description = 'Battery - Simple Assault' AND
	Area_Description = 'Central'
GROUP BY Location_Description, Crime_Description, Year, Area_Description
ORDER BY Total_Instances DESC

--Fidning what top 5 premis is most Batteries happening in Central LA in 2019

SELECT TOP 5 Premis_Description, COUNT(Crime_Description) AS Total_Instances
FROM CrimeFact
	INNER JOIN DimLocation ON  CrimeFact.Location_ID =  DimLocation.Location_ID
	INNER JOIN DimArea ON DimArea.Area_ID = DimLocation.Area_ID
	INNER JOIN DimDate ON CrimeFact.Date_ID = DimDate.Date_ID
	INNER JOIN DimPremis ON CrimeFact.Premis_ID = DimPremis.Premis_ID
WHERE YEAR = '2019' AND 
	Crime_Description = 'Battery - Simple Assault' AND
	Area_Description = 'Central'
GROUP BY Year, Area_Description, Crime_Description, Premis_Description
ORDER BY Total_Instances DESC
