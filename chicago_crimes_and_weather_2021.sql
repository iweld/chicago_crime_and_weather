

-- How many total crimes were reported in 2021?

SELECT count(crime_id) AS "total reported crimes"
FROM crimes;

-- Results:

Total Reported Crimes|
---------------------+
               202536|

-- What is the count of Homicides, Battery and Assaults reported?

SELECT 
	crime_type,
	count(*) AS n_crimes
FROM 
	crimes
WHERE 
	crime_type IN ('homicide', 'battery', 'assault')
group BY 
	crime_type
order BY 
	n_crimes DESC;

-- Results:

crime_type|n_crimes|
----------+--------+
battery   |   39988|
assault   |   20086|
homicide  |     803|

-- Create a temp table that joins data from all three tables

DROP TABLE IF EXISTS chicago_crimes;
CREATE TEMP TABLE chicago_crimes AS (
	SELECT
		cr.crime_id, 
		date_trunc('second', cr.crime_date) AS crime_date,
		cr.crime_type,
		cr.crime_description,
		cr.location_description,
		cr.street_name,
		co.community_name,
		co.population ,
		co.area_size,
		co.density,
		cr.arrest, 
		cr.domestic,
		w.temp_high, 
		w.temp_low, 
		w.precipitation
	FROM crimes AS cr
	JOIN community AS co
	ON cr.community_id = co.area_id
	JOIN weather AS w
	ON w.weather_date = date(cr.crime_date)
);

SELECT * FROM chicago_crimes LIMIT 10;

-- Results:

crime_id|crime_date             |crime_type       |crime_description      |location_description|street_name      |community_name|population|area_size|density |arrest|domestic|temp_high|temp_low|precipitation|
--------+-----------------------+-----------------+-----------------------+--------------------+-----------------+--------------+----------+---------+--------+------+--------+---------+--------+-------------+
       1|2021-01-03 13:23:00.000|battery          |domestic battery simple|apartment           | eggleston ave   |englewood     |     24369|     3.07| 7937.79|false |true    |       33|      26|         0.01|
       2|2021-01-03 06:59:00.000|theft            |$500 and under         |residence           | yale ave        |chatham       |     31710|     2.95|10749.15|false |false   |       33|      26|         0.01|
       3|2021-01-03 00:20:00.000|battery          |domestic battery simple|apartment           | washington blvd |austin        |     96557|     7.15|13504.48|false |true    |       33|      26|         0.01|
       4|2021-01-03 20:47:00.000|narcotics        |possess - cocaine      |street              | racine ave      |west englewood|     29647|     3.15| 9411.75|true  |false   |       33|      26|         0.01|
       5|2021-01-03 20:09:00.000|homicide         |first degree murder    |street              | stony island ave|south shore   |     53971|     2.93|18420.14|false |false   |       33|      26|         0.01|
       6|2021-01-03 08:54:00.000|assault          |simple                 |cha apartment       | yates ave       |south deering |     14105|     10.9| 1294.04|false |false   |       33|      26|         0.01|
       7|2021-01-03 16:30:00.000|theft            |$500 and under         |apartment           | taylor st       |near west side|     67881|     5.69|11929.88|true  |true    |       33|      26|         0.01|
       8|2021-01-03 23:47:00.000|weapons violation|unlawful use - handgun |street              | 69th st         |south shore   |     53971|     2.93|18420.14|false |false   |       33|      26|         0.01|
       9|2021-01-03 22:30:00.000|criminal damage  |to property            |residence - garage  | thome ave       |edgewater     |     56296|     1.74|32354.02|false |false   |       33|      26|         0.01|
      10|2021-01-03 01:00:00.000|criminal trespass|to vehicle             |street              | blackstone ave  |hyde park     |     29456|     1.61|18295.65|false |false   |       33|      26|         0.01|

-- What are the top ten communities that had the most crimes reported?
-- We will also add the current population to see if area density is also a factor.

SELECT 
	community_name AS community,
	population,
	density,
	count(*) AS reported_crimes
FROM chicago_crimes
group BY 
	community_name,
	population,
	density
ORDER BY reported_crimes DESC
LIMIT 10;

-- Results:

community             |population|density |reported_crimes|
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

SELECT 
	community_name AS community,
	population,
	density,
	count(*) AS reported_crimes
FROM chicago_crimes
group BY 
	community_name,
	population,
	density
ORDER BY reported_crimes
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
	to_char(CRIME_DATE::timestamp, 'Month') AS month,
	COUNT(*) AS n_crimes
FROM
	chicago_crimes
GROUP BY
	month
ORDER BY
	n_crimes DESC;

-- Results:

month    |n_crimes|
---------+--------+
October  |   19018|
September|   18987|
July     |   18966|
June     |   18566|
August   |   18255|
May      |   17539|
November |   16974|
January  |   16038|
March    |   15742|
April    |   15305|
December |   14258|
February |   12888|

-- What month had the most homicides and what was the average temperature?

SELECT
	to_char(CRIME_DATE::timestamp, 'Month') AS month,
	COUNT(*) AS n_homicides,
	round(avg(temp_high), 1) AS avg_high_temp
FROM
	chicago_crimes
WHERE crime_type = 'homicide'
GROUP BY
	month
ORDER BY
	n_homicides DESC;


-- Results:

month    |n_homicides|avg_high_temp|
---------+-----------+-------------+
July     |        112|         82.6|
September|         89|         80.8|
June     |         85|         83.5|
August   |         81|         85.3|
May      |         66|         73.9|
October  |         64|         67.9|
November |         62|         50.6|
January  |         55|         34.1|
April    |         54|         65.1|
December |         52|         48.6|
March    |         45|         54.7|
February |         38|         27.0|

-- What weekday were most crimes committed?

SELECT
	to_char(CRIME_DATE::timestamp, 'Day') AS day_of_week,
	COUNT(*) AS n_crimes
FROM
	chicago_crimes
GROUP BY
	day_of_week
ORDER BY
	n_crimes DESC;

-- Results:

day_of_week|n_crimes|
-----------+--------+
Saturday   |   29841|
Friday     |   29829|
Sunday     |   29569|
Monday     |   29194|
Wednesday  |   28143|
Tuesday    |   28135|
Thursday   |   27825|

-- What are the top ten city streets that have had the most reported crimes?

SELECT
	street_name,
	count(*) AS n_crimes
FROM
	chicago_crimes
GROUP BY
	street_name
ORDER BY
	count(*) DESC
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

-- What are the top ten city streets that have had the most homicides including ties?

 SELECT
 	street_name,
 	n_homicides
 from
	(SELECT
		street_name,
		count(*) AS n_homicides,
		rank() OVER (ORDER BY count(*) DESC) AS rnk
	FROM
		chicago_crimes
	WHERE
		crime_type = 'homicide'
	GROUP BY
		street_name
	ORDER BY
		count(*) DESC) AS tmp
WHERE 
	rnk <= 10;

-- Results:

street_name                 |n_homicides|
----------------------------+-----------+
 79th st                    |         14|
 madison st                 |         14|
 morgan st                  |         10|
 71st st                    |         10|
 michigan ave               |          9|
 cottage grove ave          |          9|
 van buren st               |          8|
 cicero ave                 |          7|
 dr martin luther king jr dr|          7|
 pulaski rd                 |          7|
 state st                   |          7|
 emerald ave                |          7|
 polk st                    |          7|

-- What are the top ten city streets that have had the most burglaries excluding ties?

SELECT
	street_name,
	count(*) AS n_burglaries
FROM
	chicago_crimes
WHERE
	crime_type = 'burglary'
group BY
	street_name
ORDER BY
	n_burglaries DESC
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
 
 -- What was the number of reported crimes on the hottest day of the year vs the coldest?

WITH hottest AS (
	SELECT
	  	temp_high,
	 	count(*) AS n_crimes
	FROM
	 	chicago_crimes
	WHERE
	 	temp_high = (SELECT max(temp_high) FROM chicago_crimes)
	GROUP BY temp_high
),
coldest AS (
	SELECT
	  	temp_high,
	 	count(*) AS n_crimes
	FROM
	 	chicago_crimes
	WHERE
	 	temp_high = (SELECT min(temp_high) FROM chicago_crimes)
	GROUP BY temp_high
)
 	
 
COPY chicago_crimes TO 'C:\Users\Jaime\Desktop\chicago_crimes.csv' DELIMITER ',' CSV HEADER;
