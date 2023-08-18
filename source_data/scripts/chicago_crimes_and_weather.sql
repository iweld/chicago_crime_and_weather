

-- 1. List the total number of reported crimes between 2018 and 2022?

SELECT to_char(count(*), '9g999g999') AS "Total Reported Crimes"
FROM chicago.crimes;

-- Results:

Total Reported Crimes|
---------------------+
 1,189,780           |

-- 2. What is the count of Homicides, Battery and Assaults reported?

SELECT 
	initcap(crime_type) AS crime_type,
	count(*) AS n_crimes
FROM 
	chicago.crimes
WHERE 
	crime_type IN ('homicide', 'battery', 'assault')
GROUP BY 
	crime_type
ORDER BY 
	n_crimes DESC;

-- Results:

crime_type|n_crimes|
----------+--------+
Battery   |  222214|
Assault   |  100411|
Homicide  |    3440|

-- 3. What are the top ten communities that had the MOST amount of crimes reported?
-- Include the current population, density and order by the number of reported crimes.

SELECT 
	co.community_name AS community,
	co.population,
	co.density,
	count(*) AS reported_crimes
FROM 
	chicago.crimes AS cr
JOIN
	chicago.community AS co
ON 
	co.community_id = cr.community_id
GROUP BY 
	co.community_name,
	co.population,
	co.density
ORDER BY 
	reported_crimes DESC
LIMIT 10;

-- Results:

/*

community      |population|density |reported_crimes|
---------------+----------+--------+---------------+
austin         |     96557|13504.48|          66662|
near north side|    105481|38496.72|          51977|
near west side |     67881|11929.88|          41773|
south shore    |     53971|18420.14|          40984|
loop           |     42298|25635.15|          40245|
north lawndale |     34794|10839.25|          39115|
humboldt park  |     54165|15045.83|          34992|
auburn gresham |     44878|11903.98|          33680|
west town      |     87781|19166.16|          32812|
roseland       |     38816| 8053.11|          30836|

*/

-- 4. What are the top ten communities that had the LEAST amount of crimes reported?
-- Include the current population, density and order by the number of reported crimes.

SELECT 
	co.community_name AS community,
	co.population,
	co.density,
	count(*) AS reported_crimes
FROM 
	chicago.crimes AS cr
JOIN
	chicago.community AS co
ON 
	co.community_id = cr.community_id
GROUP BY 
	co.community_name,
	co.population,
	co.density
ORDER BY 
	reported_crimes 
LIMIT 10;

-- Results:

/*

community      |population|density |reported_crimes|
---------------+----------+--------+---------------+
edison park    |     11525|10199.12|           1336|
burnside       |      2527| 4142.62|           1787|
forest glen    |     19596| 6123.75|           2601|
mount greenwood|     18628|  6873.8|           2609|
hegewisch      |     10027| 1913.55|           2861|
montclare      |     14401|14546.46|           2905|
oakland        |      6799|11722.41|           3289|
fuller park    |      2567| 3615.49|           3616|
archer heights |     14196| 7062.69|           4011|
mckinley park  |     15923|11292.91|           4081|

*/

-- 5. What month had the most crimes reported and what was the average and median
-- temperature high in the last five years?

SELECT
	to_char(cr.reported_crime_date, 'Month') AS month,
	COUNT(*) AS n_crimes,
	round(avg(w.temp_high), 1) avg_high_temp,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY w.temp_high) AS median_high_temp
FROM
	chicago.crimes AS cr
JOIN 
	chicago.weather AS w
ON 
	cr.reported_crime_date = w.weather_date
GROUP BY
	month
ORDER BY
	n_crimes DESC;

-- Results:

/*

month    |n_crimes|avg_high_temp|median_high_temp|
---------+--------+-------------+----------------+
July     |  111328|         85.2|            86.0|
August   |  110659|         84.3|            85.0|
October  |  105563|         62.5|            62.0|
June     |  105163|         81.5|            81.0|
September|  105075|         77.2|            78.0|
May      |  103985|         71.8|            72.0|
December |   96505|         40.6|            41.0|
November |   95501|         47.6|            47.0|
March    |   92947|         48.0|            47.0|
January  |   92018|         32.3|            34.0|
April    |   88707|         56.7|            55.0|
February |   82329|         35.3|            35.0|

*/








