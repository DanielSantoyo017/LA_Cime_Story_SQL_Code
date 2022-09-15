--Creating Crime Stage Table to use in ETL process

CREATE TABLE Crime_Stage_Table
(
Stage_Key INT IDENTITY (1,1) NOT NULL,
Case_Number FLOAT NULL,
Date_ID INT NULL,
Quarter INT NULL,
YEAR INT NULL,
MONTH INT NULL,
DAY INT NULL,
Date_Occurred DATETIME NULL,
Time_Occurred DATETIME NULL,
Area_ID FLOAT NULL,
Area_Description NVARCHAR(255) NULL,
Crime_ID INT NULL,
Crime_Code FLOAT NULL,
Crime_Description NVARCHAR(255) NULL,
Victim_ID INT NULL,
Victim_Age NVARCHAR(255) NULL,
Victim_Sex NVARCHAR(255) NULL,
Victim_Descent NVARCHAR(255) NULL,
Premis_ID INT NULL,
Premis_Description NVARCHAR(255) NULL,
Weapon_ID INT NULL,
Weapon_Code FLOAT NULL,
Weapon_Description NVARCHAR(255) NULL,
Status_ID INT NULL,
Status_Code NVARCHAR(255) NULL,
Status_Description NVARCHAR(255) NULL,
Location_ID INT NULL,
Location_Description NVARCHAR(255) NULL,
Lattitude FLOAT NULL,
Longitude FLOAT NULL
);


--Creating Dimension Tables (Hierarchically)

--AREA ETL

--Creating Area Dimension table (Distinct) Due to Hierarchy Area table comes before Location Table

CREATE TABLE DimArea
(
Area_ID FLOAT NOT NULL,
Area_Description NVARCHAR(255) NULL,
);

----SQL Command for Connection manager to import distinct values from stage table to DimLocation

SELECT DISTINCT dbo.Crime_Stage_Table.Area_ID, dbo.Crime_Stage_Table.Area_Description
FROM Crime_Stage_Table
WHERE Area_Description IS NOT NULL
ORDER BY Area_ID



--Creating Location Dimension table (Distinct) When transfering data pull Area ID From Stage table?

CREATE TABLE DimLocation
(
Location_ID int IDENTITY(4000000,1) NOT NULL,
Location_Description NVARCHAR(255) NULL,
Area_ID FLOAT NULL,
);

----SQL Command for Connection manager to import distinct values from stage table to DimLocation

SELECT DISTINCT dbo.Crime_Stage_Table.Location_Description,
	dbo.Crime_Stage_Table.Area_Id
FROM Crime_Stage_Table
WHERE Location_Description IS NOT NULL
ORDER BY Area_ID

--Creating Update statment to Join Location ID to Stage Table (To then load into CrimeFact)

UPDATE dbo.Crime_Stage_Table
SET dbo.Crime_Stage_Table.Location_ID = dbo.DimLocation.Location_ID
FROM dbo.Crime_Stage_Table
INNER JOIN dbo.DimLocation ON dbo.Crime_Stage_Table.Location_Description = dbo.DimLocation.Location_Description AND dbo.Crime_Stage_Table.Area_ID = dbo.DimLocation.Area_ID



--Creating crime weapons Dimension table (Distinct Values)

CREATE TABLE DimWeapons
(
Weapon_ID INT IDENTITY(1000000,1) NOT NULL,
Weapon_Code FLOAT NULL,
Weapon_Description NVARCHAR(255) NULL);


--SQL Command for Connection manager to import distinct values from stage table to DimWeapons

SELECT DISTINCT dbo.Crime_Stage_Table.Weapon_Code, dbo.Crime_Stage_Table.Weapon_Description
FROM Crime_Stage_Table
WHERE Weapon_Code IS NOT NULL
ORDER BY Weapon_Code

--Creating Update statment to Join weapons ID to Stage Table (To then load into CrimeFact)

UPDATE dbo.Crime_Stage_Table
SET dbo.Crime_Stage_Table.Weapon_ID = dbo.DimWeapons.Weapon_ID
FROM dbo.Crime_Stage_Table
INNER JOIN dbo.DimWeapons ON dbo.Crime_Stage_Table.Weapon_Description = dbo.DimWeapons.Weapon_Description



--Creating crime status Dimension table (Distinct Values)

CREATE TABLE DimStatus
(
Status_ID INT IDENTITY(2000000,1) NOT NULL,
Status_Code NVARCHAR(255) NULL,
Status_Description NVARCHAR(255) NULL,
);

--SQL Command for Connection manager to import distinct values from stage table to DimStatus (NO NULLS)

SELECT DISTINCT dbo.Crime_Stage_Table.Status_Code, dbo.Crime_Stage_Table.Status_Description
FROM Crime_Stage_Table
WHERE Status_Code != 'NULL'
ORDER BY Status_Code


--Creating Update statment to Join status ID to Stage Table (To then load into CrimeFact)

UPDATE dbo.Crime_Stage_Table
SET dbo.Crime_Stage_Table.Status_ID = dbo.DimStatus.Status_ID
FROM dbo.Crime_Stage_Table
INNER JOIN dbo.DimStatus ON dbo.Crime_Stage_Table.Status_Description = dbo.DimStatus.Status_Description




--Creating Premis Dimension table 

CREATE TABLE DimPremis
(
Premis_ID INT IDENTITY(5000000,1) NOT NULL,
Premis_Description NVARCHAR(255) NULL,
);

--SQL Command for Connection manager to import distinct values from stage table to DimPremis (NO NULLS)

SELECT DISTINCT dbo.Crime_Stage_Table.Premis_Description
FROM Crime_Stage_Table
WHERE Premis_Description != 'NULL'
ORDER BY Premis_Description

--Creating Update statment to Join Premises ID to Stage Table (To then load into CrimeFact)

UPDATE dbo.Crime_Stage_Table
SET dbo.Crime_Stage_Table.Premis_ID = dbo.DimPremis.Premis_ID
FROM dbo.Crime_Stage_Table
INNER JOIN dbo.DimPremis ON dbo.Crime_Stage_Table.Premis_Description = dbo.DimPremis.Premis_Description



--Creating Victum Dimension table 

CREATE TABLE DimVictim
(
Victim_ID INT IDENTITY(6000000,1) NOT NULL,
Victim_Age NVARCHAR(255) NULL,
Victim_Sex NVARCHAR(255) NULL,
Victim_Descent NVARCHAR(255) NULL,
);


----Creating Update statment to Join Victim ID to Stage Table (To then load into CrimeFact)

UPDATE dbo.Crime_Stage_Table
SET dbo.Crime_Stage_Table.Victim_ID = dbo.DimVictim.Victim_ID
FROM dbo.Crime_Stage_Table
INNER JOIN dbo.DimVictim ON dbo.Crime_Stage_Table.Victim_Descent = dbo.DimVictim.Victim_Descent


--Creating Time Dimension table 

CREATE TABLE DimDate
(
Date_ID INT IDENTITY(7000000,1) NOT NULL,
Quarter INT NULL,
Year INT NULL,
Month INT NULL,
Day INT NULL,
Date_Occurred DATETIME NULL,
Time_Occurred TIME NULL,
);


--Create Date INSERT INTO SQL command statment to Separate Dates into more granular forms (Not distinct)
--INSERT INTO statment is needed due to derived fields in DimDate

INSERT INTO dbo.DimDate(Quarter,Year,Month,Day,Date_Occurred,Time_Occurred)
SELECT DATEPART(QUARTER,  Date_Occurred), 
	DATEPART(YEAR,  Date_Occurred), 
	DATEPART(MONTH,  Date_Occurred),
	DATEPART(DAY,  Date_Occurred), 
	Date_Occurred, 
	Time_Occurred
FROM Crime_Stage_Table
ORDER BY Date_Occurred

--Creating Update statment to Join Date ID to Stage Table (To then load into CrimeFact)
UPDATE dbo.Crime_Stage_Table
SET dbo.Crime_Stage_Table.Date_ID = dbo.DimDate.Date_ID
FROM dbo.Crime_Stage_Table
INNER JOIN dbo.DimDate ON dbo.Crime_Stage_Table.Date_Occurred = dbo.DimDate.Date_Occurred AND dbo.Crime_Stage_Table.Time_Occurred = dbo.DimDate.Time_Occurred 


--Creating CRIME Fact table 

CREATE TABLE CrimeFact
(
Crime_ID int IDENTITY(800000,1) NOT NULL,
Crime_Code FLOAT NULL,
Crime_Description NVARCHAR(255) NULL,
Case_Number FLOAT NULL,
Location_ID INT NULL,
Premis_ID INT NULL, 
Weapon_ID INT NULL,
Victim_ID INT NULL,
Status_ID INT NULL,
Date_ID INT NULL,
Lattitude FLOAT NULL,
Longitude FLOAT NULL
);


--Designation of Forgien Keys in CrimeFact Table

ALTER TABLE CrimeFact
ADD CONSTRAINT FK_Location_ID
FOREIGN KEY(Location_ID)
REFERENCES DimLocation(Location_ID)


ALTER TABLE CrimeFact
ADD CONSTRAINT FK_Premis_ID
FOREIGN KEY(Premis_ID)
REFERENCES DimPremis(Premis_ID)


ALTER TABLE CrimeFact
ADD CONSTRAINT FK_Weapon_ID
FOREIGN KEY(Weapon_ID)
REFERENCES DimWeapons(Weapon_ID)


ALTER TABLE CrimeFact
ADD CONSTRAINT FK_Victim_ID
FOREIGN KEY(Victim_ID)
REFERENCES DimVictim(Victim_ID)


ALTER TABLE CrimeFact
ADD CONSTRAINT FK_Status_ID
FOREIGN KEY(Status_ID)
REFERENCES DimStatus(status_ID)


ALTER TABLE CrimeFact
ADD CONSTRAINT FK_Date_ID
FOREIGN KEY(Date_ID)
REFERENCES DimDate(Date_ID)


ALTER TABLE DimLocation
ADD CONSTRAINT FK_Area_ID
FOREIGN KEY(Area_ID)
REFERENCES DimArea(Area_ID)


----Cleaning Errors Fixed

--UPDATE to NULL where Unknown is apart of location name
UPDATE Crime_Stage_Table
SET Location_Description = 'NULL'
WHERE Location_Description = '%Unknown%'


SELECT Distinct Location_Description, COUNT(Location_Description) AS Total_Instances
FROM Crime_Stage_Table
WHERE Location_Description = '%Unknown%'
GROUP BY Location_Description
ORDER BY Location_Description

--Changing Data Types
ALTER Table [dbo].[Crime_Stage_Table]
ALTER COLUMN Time_Occurred TIME;


ALTER TABLE DimArea
ALTER COLUMN Area_ID FLOAT NOT NULL

