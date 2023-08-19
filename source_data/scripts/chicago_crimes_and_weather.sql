

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
	initcap(co.community_name) AS community,
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
Austin         |     96557|13504.48|          66662|
Near North Side|    105481|38496.72|          51977|
Near West Side |     67881|11929.88|          41773|
South Shore    |     53971|18420.14|          40984|
Loop           |     42298|25635.15|          40245|
North Lawndale |     34794|10839.25|          39115|
Humboldt Park  |     54165|15045.83|          34992|
Auburn Gresham |     44878|11903.98|          33680|
West Town      |     87781|19166.16|          32812|
Roseland       |     38816| 8053.11|          30836|

*/

-- 4. What are the top ten communities that had the LEAST amount of crimes reported?
-- Include the current population, density and order by the number of reported crimes.

SELECT 
	initcap(co.community_name) AS community,
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
Edison Park    |     11525|10199.12|           1336|
Burnside       |      2527| 4142.62|           1787|
Forest Glen    |     19596| 6123.75|           2601|
Mount Greenwood|     18628|  6873.8|           2609|
Hegewisch      |     10027| 1913.55|           2861|
Montclare      |     14401|14546.46|           2905|
Oakland        |      6799|11722.41|           3289|
Fuller Park    |      2567| 3615.49|           3616|
Archer Heights |     14196| 7062.69|           4011|
Mckinley Park  |     15923|11292.91|           4081|

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

-- 6. What month had the most homicides reported and what was the average and median
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
WHERE
	cr.crime_type = 'homicide'
GROUP BY
	month
ORDER BY
	n_crimes DESC;

-- Results:

/*

month    |n_crimes|avg_high_temp|median_high_temp|
---------+--------+-------------+----------------+
July     |     398|         85.3|            86.0|
June     |     360|         82.5|            82.0|
September|     356|         78.1|            79.0|
August   |     330|         84.6|            85.0|
May      |     326|         72.7|            73.0|
October  |     296|         63.8|            64.0|
April    |     275|         59.3|            58.0|
November |     263|         49.8|            48.0|
December |     249|         41.4|            42.0|
January  |     212|         32.9|            33.0|
February |     190|         35.0|            37.0|
March    |     185|         49.3|            48.0|

*/

-- 7. List the most violent year and the number of arrests with percentage.  Order by the number of crimes in decending order.  
-- Determine the most violent year by the number of reported Homicides, Assaults and Battery for that year.

WITH get_arrest_percentage AS (
	SELECT
		EXTRACT('year' FROM cr.reported_crime_date) AS most_violent_year,
		count(*) AS reported_violent_crimes,
		sum(
			CASE
				WHEN arrest = TRUE THEN 1
				ELSE 0
			END 
		) AS number_of_arrests
	FROM
		chicago.crimes AS cr
	WHERE 
		crime_type IN ('homicide', 'battery', 'assault')
	GROUP BY
		most_violent_year
	ORDER BY
		reported_violent_crimes DESC
)
SELECT
	most_violent_year,
	reported_violent_crimes,
	number_of_arrests || ' (' || 100 * number_of_arrests  / reported_violent_crimes|| '%)' AS number_of_arrests
FROM
	get_arrest_percentage;

-- Results:

/*

most_violent_year|reported_violent_crimes|number_of_arrests|
-----------------+-----------------------+-----------------+
             2018|                  70835|13907 (19%)      |
             2019|                  70645|14334 (20%)      |
             2022|                  62412|8165 (13%)       |
             2021|                  61611|7855 (12%)       |
             2020|                  60562|9577 (15%)       |

*/

-- 8. List the day of the week, year, average precipitation and highest number of reported crimes for days with precipitation.

WITH get_weekday_values AS (
	SELECT
		EXTRACT('year' FROM cr.reported_crime_date) AS crime_year,
		to_char(cr.reported_crime_date, 'Day') AS day_of_week,
		round(avg(w.precipitation)::NUMERIC, 2) AS avg_precipitation,
		COUNT(*) AS n_crimes,
		DENSE_RANK() OVER(PARTITION BY EXTRACT('year' FROM cr.reported_crime_date) ORDER BY count(*) DESC) AS rnk
	FROM
		chicago.crimes AS cr
	JOIN 
		chicago.weather AS w
	ON
		cr.reported_crime_date = w.weather_date
	WHERE
		w.precipitation > 0
	GROUP BY
		crime_year,
		day_of_week
	ORDER BY
		n_crimes DESC
)
SELECT
	crime_year,
	day_of_week,
	avg_precipitation,
	n_crimes
FROM
	get_weekday_values
WHERE
	rnk = 1
ORDER BY
	crime_year;

-- Results:

/*

crime_year|day_of_week|avg_precipitation|n_crimes|
----------+-----------+-----------------+--------+
      2018|Monday     |             0.57|   16455|
      2019|Wednesday  |             0.31|   19411|
      2020|Wednesday  |             0.29|   11394|
      2021|Sunday     |             0.30|   10889|
      2022|Friday     |             0.21|   13029|	

*/

-- 9. List the days with the most reported crimes when there is zero precipitation and
-- the day when precipitation is greater than .5".  Include the day of the week, high temperature,
-- amount and precipitation and the total number of reported crimes for that day. 

WITH no_precipitation AS (
	SELECT
		cr.reported_crime_date,
		to_char(cr.reported_crime_date, 'Day') AS day_of_week,
		w.temp_high,
		w.precipitation,
		count(*) AS reported_crimes
	FROM
		chicago.crimes AS cr
	JOIN
		chicago.weather AS w
	ON
		cr.reported_crime_date = w.weather_date
	WHERE
		w.precipitation = 0
	GROUP BY 
		day_of_week,
		w.precipitation,
		temp_high,
		cr.reported_crime_date
	ORDER BY
		reported_crimes DESC
	LIMIT 
		1
),
yes_precipitation AS (
	SELECT
		cr.reported_crime_date,
		to_char(cr.reported_crime_date, 'Day') AS day_of_week,
		w.temp_high,
		w.precipitation,
		count(*) AS reported_crimes
	FROM
		chicago.crimes AS cr
	JOIN
		chicago.weather AS w
	ON
		cr.reported_crime_date = w.weather_date
	WHERE
		w.precipitation > .5
	GROUP BY 
		day_of_week,
		temp_high,
		w.precipitation,
		cr.reported_crime_date
	ORDER BY
		reported_crimes DESC
	LIMIT 
		1
)
SELECT
	*
FROM no_precipitation
UNION
SELECT
	*
FROM yes_precipitation
ORDER BY
	reported_crimes DESC;

-- Results:

/*

reported_crime_date|day_of_week|temp_high|precipitation|reported_crimes|
-------------------+-----------+---------+-------------+---------------+
         2020-05-31|Sunday     |       69|          0.0|           1899|
         2018-10-01|Monday     |       72|         1.56|            926|	

*/


-- 10. List the most consecutive days where a homicide occured and the timeframe.


WITH get_homicide_dates AS (
	-- Get only one date per homicide
	SELECT 
		DISTINCT ON (reported_crime_date) reported_crime_date AS homicide_dates
	FROM
		chicago.crimes
	WHERE
		crime_type = 'homicide'
),
get_rn_diff AS (
	SELECT 
		homicide_dates,
		homicide_dates - row_number() OVER ()::int AS diff
	FROM
		get_homicide_dates
),		
get_diff_count AS (
	SELECT
		homicide_dates,
		count(*) OVER(PARTITION BY diff) AS diff_count
	FROM
		get_rn_diff
	GROUP BY
		homicide_dates,
		diff
)
SELECT
	max(diff_count) AS most_consecutive_days,
	min(homicide_dates) || ' to ' || max(homicide_dates) AS consecutive_days_timeframe
FROM
	get_diff_count
WHERE 
	diff_count = (SELECT max(diff_count) FROM get_diff_count);	

-- Results:

/*

most_consecutive_days|consecutive_days_timeframe|
---------------------+--------------------------+
                   47|2020-06-13 to 2020-07-29  |	

*/



















