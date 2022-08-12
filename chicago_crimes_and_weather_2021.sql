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

SELECT COUNT(CRIME_ID) AS "Total Reported Crimes"
FROM CRIMES;

-- Results:

Total Reported Crimes|
---------------------+
               202536|

-- What is the count of Homicides, Battery and Assaults reported?

SELECT
	CRIME_TYPE,
	COUNT(*) AS n_crimes
FROM
	CRIMES
WHERE
	CRIME_TYPE IN ('homicide', 'battery', 'assault')
GROUP BY
	CRIME_TYPE
ORDER BY
	COUNT(*) DESC;

-- Results:

crime_type|n_crimes|
----------+--------+
battery   |   39988|
assault   |   20086|
homicide  |     803|

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

-- Results:

community             |population|density |Reported Crimes|
----------------------+----------+--------+---------------+
austin                |     96557|13504.48|          11341|
near north side       |    105481|38496.72|           8126|
south shore           |     53971|18420.14|           7272|
near west side        |     67881|11929.88|           6743|
north lawndale        |     34794|10839.25|           6161|
auburn gresham        |     44878|11903.98|           5873|
humboldt park         |     54165|15045.83|           5767|
greater grand crossing|     31471| 8865.07|           5545|
west town             |     87781|19166.16|           5486|
loop                  |     42298|25635.15|           5446|

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

-- Results:

community      |population|density |Reported Crimes|
---------------+----------+--------+---------------+
edison park    |     11525|10199.12|            238|
burnside       |      2527| 4142.62|            321|
forest glen    |     19596| 6123.75|            460|
mount greenwood|     18628| 6873.80|            492|
montclare      |     14401|14546.46|            508|
fuller park    |      2567| 3615.49|            541|
oakland        |      6799|11722.41|            581|
hegewisch      |     10027| 1913.55|            598|
archer heights |     14196| 7062.69|            653|
north park     |     17559| 6967.86|            679|


-- What month had the most crimes reported?

SELECT
	EXTRACT(MONTH FROM CRIME_DATE)::int AS month_number,
	COUNT(*) AS n_crimes
FROM
	CRIMES
GROUP BY
	EXTRACT(MONTH
FROM
	CRIME_DATE)
ORDER BY
	COUNT(*) DESC;

-- Results:

month_number|n_crimes|
------------+--------+
          10|   19018|
           9|   18987|
           7|   18966|
           6|   18566|
           8|   18255|
           5|   17539|
          11|   16974|
           1|   16038|
           3|   15742|
           4|   15305|
          12|   14258|
           2|   12888|

-- What month had the most homicides?

SELECT
	EXTRACT(MONTH FROM CRIME_DATE)::int AS month_number,
	COUNT(*) AS n_homicides
FROM
	CRIMES
WHERE
	CRIME_TYPE = 'homicide'
GROUP BY
	EXTRACT(MONTH
FROM
	CRIME_DATE)
ORDER BY
	COUNT(*) DESC;

-- Results:

month_number|n_homicides|
------------+-----------+
           7|        112|
           9|         89|
           6|         85|
           8|         81|
           5|         66|
          10|         64|
          11|         62|
           1|         55|
           4|         54|
          12|         52|
           3|         45|
           2|         38|

-- What weekday were most crimes committed?

SELECT
	WEEKDAY,
	COUNT(*) AS n_crimes
FROM
	WEATHER
INNER JOIN CRIMES ON
	DATE(CRIMES.CRIME_DATE) = DATE(WEATHER.WEATHER_DATE)
GROUP BY
	WEEKDAY
ORDER BY
	COUNT(*) DESC;

-- Results:

weekday  |n_crimes|
---------+--------+
Saturday |   29841|
Friday   |   29829|
Sunday   |   29569|
Monday   |   29194|
Wednesday|   28143|
Tuesday  |   28135|
Thursday |   27825|

-- What are the top ten city streets that have had the most reported crimes?

SELECT
	STREET_NAME,
	COUNT(*) AS n_crimes
FROM
	CRIMES
GROUP BY
	STREET_NAME
ORDER BY
	COUNT(*) DESC
LIMIT 10;

-- Results:

street_name                 |n_crimes|
----------------------------+--------+
 michigan ave               |    3257|
 state st                   |    2858|
 halsted st                 |    2329|
 ashland ave                |    2276|
 clark st                   |    2036|
 western ave                |    1987|
 dr martin luther king jr dr|    1814|
 pulaski rd                 |    1686|
 kedzie ave                 |    1606|
 madison st                 |    1584|

-- What are the top ten city streets that have had the most homicides?

SELECT
	STREET_NAME,
	COUNT(*) AS n_homicides
FROM
	CRIMES
WHERE
	crime_type = 'homicide'
GROUP BY
	STREET_NAME	
ORDER BY
	COUNT(*) DESC
LIMIT 10;

-- Results:

street_name                 |n_homicides|
----------------------------+-----------+
 madison st                 |         14|
 79th st                    |         14|
 morgan st                  |         10|
 71st st                    |         10|
 michigan ave               |          9|
 cottage grove ave          |          9|
 van buren st               |          8|
 emerald ave                |          7|
 cicero ave                 |          7|
 dr martin luther king jr dr|          7|

-- What are the top ten city streets that have had the most burglaries?

SELECT
	STREET_NAME,
	COUNT(*) AS n_burglaries
FROM
	CRIMES
WHERE
	crime_type = 'burglary'
GROUP BY
	STREET_NAME	
ORDER BY
	COUNT(*) DESC
LIMIT 10;

-- Results:

street_name                 |n_burglaries|
----------------------------+------------+
 ashland ave                |         104|
 halsted st                 |         103|
 michigan ave               |          92|
 western ave                |          79|
 kedzie ave                 |          67|
 north ave                  |          62|
 chicago ave                |          50|
 dr martin luther king jr dr|          50|
 79th st                    |          48|
 sheridan rd                |          45|
 

