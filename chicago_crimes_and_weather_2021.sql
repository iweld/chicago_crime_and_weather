-- Create the three tables we are going to import of csv data into.

CREATE TABLE CRIMES (
	CRIME_ID serial, 
	CRIME_DATE TIMESTAMP,
	STREET_NAME VARCHAR(100),
	CRIME_TYPE VARCHAR(150),
	CRIME_DESCRIPTION VARCHAR(250),
	LOCATION_DESCRIPTION VARCHAR(150),
	ARREST boolean, 
	DOMESTIC boolean, 
	COMMUNITY_ID int, 
	LATITUDE numeric, 
	LONGITUDE numeric, 
	PRIMARY KEY (CRIME_ID));


CREATE TABLE COMMUNITY (
	AREA_ID int, 
	COMMUNITY_NAME VARCHAR(250),
	POPULATION int, 
	AREA_SIZE numeric, 
	DENSITY numeric, 
	PRIMARY KEY (AREA_ID));


CREATE TABLE WEATHER (
	WEATHER_DATE TIMESTAMP,
	WEEKDAY VARCHAR(20),
	TEMP_HIGH int, 
	TEMP_LOW int, 
	PRECIPITATION numeric, 
	PRIMARY KEY (WEATHER_DATE));
	
-- Copy and insert data from csv files to tables.

COPY CRIMES (
	CRIME_DATE,
	STREET_NAME,
	CRIME_TYPE,
	CRIME_DESCRIPTION,
	LOCATION_DESCRIPTION,
	ARREST,
	DOMESTIC,
	COMMUNITY_ID,
	LATITUDE,
	LONGITUDE)
FROM '* path to * \csv\chicago_crimes_2021.csv'
DELIMITER ',' CSV HEADER;

COPY COMMUNITY (
	AREA_ID, 
	COMMUNITY_NAME,
	POPULATION, 
	AREA_SIZE, 
	DENSITY)
FROM '* path to * \csv\chicago_areas.csv'
DELIMITER ',' CSV HEADER;

COPY WEATHER (
	WEATHER_DATE,
	WEEKDAY,
	TEMP_HIGH, 
	TEMP_LOW, 
	PRECIPITATION)
FROM '* path to * \csv\chicago_temps_2021.csv'
DELIMITER ',' CSV HEADER;

-- How many total crimes were reported in 2021?

SELECT COUNT(CRIME_ID) AS "Total Crimes"
FROM CRIMES;

-- What is the count of Homicides, Battery and Assaults reported?

SELECT CRIME_TYPE,
	COUNT(*)
FROM CRIMES
WHERE CRIME_TYPE in ('homicide', 'battery','assault')
GROUP BY CRIME_TYPE
ORDER BY COUNT(*) DESC;

-- What are the top ten communities that had the most crimes reported?
-- We will also add the current population to see if area density is also a factor.

SELECT CO.COMMUNITY_NAME AS COMMUNITY,
	CO.POPULATION,
	CO.DENSITY,
	COUNT(*) AS "Reported Crimes"
FROM COMMUNITY AS CO
INNER JOIN CRIMES AS CR ON CR.COMMUNITY_ID = CO.AREA_ID
GROUP BY CO.COMMUNITY_NAME,
	CO.POPULATION,
	CO.DENSITY
ORDER BY COUNT(*) DESC
LIMIT 10;

-- What are the top ten communities that had the least amount of crimes reported?
-- We will also add the current population to see if area density is also a factor.

SELECT COMMUNITY_NAME AS COMMUNITY,
	CO.POPULATION,
	CO.DENSITY,
	COUNT(*) AS "Reported Crimes"
FROM COMMUNITY AS CO
INNER JOIN CRIMES AS CR ON CR.COMMUNITY_ID = CO.AREA_ID
GROUP BY COMMUNITY_NAME,
	CO.POPULATION,
	CO.DENSITY
ORDER BY COUNT(*)
LIMIT 10;

-- What month had the most crimes reported?

SELECT EXTRACT(MONTH FROM CRIME_DATE), COUNT(*)
FROM CRIMES
GROUP BY EXTRACT(MONTH FROM CRIME_DATE)
ORDER BY COUNT(*) DESC;

-- What month had the most homicides?

SELECT EXTRACT(MONTH FROM CRIME_DATE), COUNT(*)
FROM CRIMES
WHERE CRIME_TYPE = 'homicide'
GROUP BY EXTRACT(MONTH FROM CRIME_DATE)
ORDER BY COUNT(*) DESC;

-- What weekday were most crimes committed?

SELECT WEEKDAY, COUNT(*)
FROM WEATHER
INNER JOIN CRIMES ON DATE(CRIMES.CRIME_DATE) = DATE(WEATHER.WEATHER_DATE)
GROUP BY WEEKDAY
ORDER BY COUNT(*) DESC;

-- What are the top ten city streets that have had the most reported crimes?

SELECT STREET_NAME, COUNT(*)
FROM CRIMES
GROUP BY STREET_NAME
ORDER BY COUNT(*) DESC
LIMIT 10

-- What are the top ten city streets that have had the most homicides?

SELECT STREET_NAME, COUNT(*)
FROM CRIMES
where crime_type = 'homicide'
GROUP BY STREET_NAME
ORDER BY COUNT(*) DESC
LIMIT 10


