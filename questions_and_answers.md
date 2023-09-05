# Chicago Crime & Weather
## Questions and Answers

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:


**1.**  List the total number of reported crimes between 2018 and 2022?

````sql
SELECT 
	to_char(count(*), '9g999g999') AS "Total Reported Crimes"
FROM 
	chicago.crimes;
````

**Results:**

Total Reported Crimes|
---------------------|
1,189,780           |

**2.** List the total amount of Homicides, Batteries and Assaults reported between 2018 and 2022.

````sql
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
````

**Results:**

crime_type|n_crimes|
----------|--------|
Battery   |  222214|
Assault   |  100411|
Homicide  |    3440|

**3.** Which are the 3 most common crimes reported and what percentage amount are they from the total amount of reported crimes?

```sql
WITH get_top_crime AS (
	SELECT 
		initcap(crime_type) AS crime_type,
		count(*) AS n_crimes
	FROM 
		chicago.crimes
	GROUP BY 
		crime_type
	ORDER BY 
		n_crimes DESC
)
SELECT
	crime_type,
	n_crimes,
	round(100 * n_crimes::NUMERIC / sum(n_crimes) OVER (), 2) AS total_percentage
FROM
	get_top_crime
LIMIT 3;
```

**Results:**

crime_type     |n_crimes|total_percentage|
---------------|--------|----------------|
Theft          |  264701|           22.25|
Battery        |  222214|           18.68|
Criminal Damage|  131716|           11.07|

**4.** What are the top ten communities that had the MOST amount of crimes reported?  Include the current population, density and order by the number of reported crimes.

````sql
SELECT 
	initcap(t2.community_name) AS community,
	t2.population,
	t2.density,
	count(*) AS reported_crimes
FROM 
	chicago.crimes AS t1
JOIN
	chicago.community AS t2
ON 
	t2.community_id = t1.community_id
GROUP BY 
	t2.community_name,
	t2.population,
	t2.density
ORDER BY 
	reported_crimes DESC
LIMIT 10;
````

**Results:**

community      |population|density |reported_crimes|
---------------|----------|--------|---------------|
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

**5.** What are the top ten communities that had the LEAST amount of crimes reported?  Include the current population, density and order by the number of reported crimes.

````sql
SELECT 
	initcap(t2.community_name) AS community,
	t2.population,
	t2.density,
	count(*) AS reported_crimes
FROM 
	chicago.crimes AS t1
JOIN
	chicago.community AS t2
ON 
	t2.community_id = t1.community_id
GROUP BY 
	t2.community_name,
	t2.population,
	t2.density
ORDER BY 
	reported_crimes
LIMIT 10;
````

**Results:**

community      |population|density |reported_crimes|
---------------|----------|--------|---------------|
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

**6.** What month had the most crimes reported and what was the average and median temperature high in the last five years?

````sql
ELECT
	to_char(t1.reported_crime_date, 'Month') AS month,
	COUNT(*) AS n_crimes,
	round(avg(t2.temp_high), 1) avg_high_temp,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY t2.temp_high) AS median_high_temp
FROM
	chicago.crimes AS t1
JOIN 
	chicago.weather AS t2
ON 
	t1.reported_crime_date = t2.weather_date
GROUP BY
	month
ORDER BY
	n_crimes DESC;
````

**Results:**

month    |n_crimes|avg_high_temp|median_high_temp|
---------|--------|-------------|----------------|
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

**7.** What month had the most homicides reported and what was the average and median temperature high in the last five years?

````sql
SELECT
	to_char(t1.reported_crime_date, 'Month') AS month,
	COUNT(*) AS n_crimes,
	round(avg(t2.temp_high), 1) avg_high_temp,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY t2.temp_high) AS median_high_temp
FROM
	chicago.crimes AS t1
JOIN 
	chicago.weather AS t2
ON 
	t1.reported_crime_date = t2.weather_date
WHERE
	t1.crime_type = 'homicide'
GROUP BY
	month
ORDER BY
	n_crimes DESC;
````

**Results:**

month    |n_crimes|avg_high_temp|median_high_temp|
---------|--------|-------------|----------------|
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

**8.** List the most violent year and the number of arrests with percentage.  Order by the number of crimes in decending order.  Determine the most violent year by the number of reported Homicides, Assaults and Battery for that year.

````sql
WITH get_arrest_percentage AS (
	SELECT
		EXTRACT('year' FROM t1.reported_crime_date) AS most_violent_year,
		count(*) AS reported_violent_crimes,
		sum(
			CASE
				WHEN arrest = TRUE THEN 1
				ELSE 0
			END 
		) AS number_of_arrests
	FROM
		chicago.crimes AS t1
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
	number_of_arrests || ' (' || round(100 * number_of_arrests::NUMERIC / reported_violent_crimes, 2) || '%)' AS number_of_arrests
FROM
	get_arrest_percentage;
````

**Results:**

most_violent_year|reported_violent_crimes|number_of_arrests|
-----------------|-----------------------|-----------------|
2018|                  70835|13907 (19.63%)   |
2019|                  70645|14334 (20.29%)   |
2022|                  62412|8165 (13.08%)    |
2021|                  61611|7855 (12.75%)    |
2020|                  60562|9577 (15.81%)    |

**9.** List the day of the week, year, average precipitation, average high temperature and the highest number of reported crimes for days with and without precipitation.

````sql
DROP TABLE IF EXISTS weekday_precipitation_values;
CREATE TEMP TABLE weekday_precipitation_values AS (
	SELECT
		EXTRACT('year' FROM t1.reported_crime_date) AS crime_year,
		to_char(t1.reported_crime_date, 'Day') AS day_of_week,
		round(avg(t2.precipitation)::NUMERIC, 2) AS avg_precipitation,
		round(avg(t2.temp_high)::NUMERIC, 2) AS avg_temp_high,
		COUNT(*) AS n_crimes,
		DENSE_RANK() OVER(PARTITION BY EXTRACT('year' FROM t1.reported_crime_date) ORDER BY count(*) DESC) AS rnk
	FROM
		chicago.crimes AS t1
	JOIN 
		chicago.weather AS t2
	ON
		t1.reported_crime_date = t2.weather_date
	WHERE
		t2.precipitation > 0
	GROUP BY
		crime_year,
		day_of_week
	ORDER BY
		n_crimes DESC
);

DROP TABLE IF EXISTS weekday_values;
CREATE TEMP TABLE weekday_values AS (
	SELECT
		EXTRACT('year' FROM t1.reported_crime_date) AS crime_year,
		to_char(t1.reported_crime_date, 'Day') AS day_of_week,
		round(avg(t2.precipitation)::NUMERIC, 2) AS avg_precipitation,
		round(avg(t2.temp_high)::NUMERIC, 2) AS avg_temp_high,
		COUNT(*) AS n_crimes,
		DENSE_RANK() OVER(PARTITION BY EXTRACT('year' FROM t1.reported_crime_date) ORDER BY count(*) DESC) AS rnk
	FROM
		chicago.crimes AS t1
	JOIN 
		chicago.weather AS t2
	ON
		t1.reported_crime_date = t2.weather_date
	WHERE
		t2.precipitation = 0
	GROUP BY
		crime_year,
		day_of_week
	ORDER BY
		n_crimes DESC
);

SELECT
	t1.crime_year,
	t1.day_of_week,
	t1.avg_precipitation,
	t1.avg_temp_high,
	t1.n_crimes,
	t2.day_of_week,
	t2.avg_temp_high,
	t2.n_crimes,
	t2.n_crimes - t1.n_crimes AS n_crime_difference
FROM
	weekday_precipitation_values AS t1
JOIN
	weekday_values AS t2
ON
	t1.crime_year = t2.crime_year
WHERE
	t1.rnk = 1
AND
	t2.rnk = 1
ORDER BY
	t1.crime_year;
````

**Results:**

crime_year|day_of_week|avg_precipitation|avg_temp_high|n_crimes|day_of_week|avg_temp_high|n_crimes|n_crime_difference|
----------|-----------|-----------------|-------------|--------|-----------|-------------|--------|------------------|
2018|Monday     |             0.57|        60.23|   16455|Friday     |        60.24|   25667|              9212|
2019|Wednesday  |             0.31|        64.00|   19411|Friday     |        57.09|   27042|              7631|
2020|Wednesday  |             0.29|        63.54|   11394|Sunday     |        61.51|   23477|             12083|
2021|Sunday     |             0.30|        57.12|   10889|Monday     |        65.31|   22840|             11951|
2022|Friday     |             0.21|        51.44|   13029|Monday     |        59.95|   26026|             12997|

**10.** List the days with the most reported crimes when there is zero precipitation and the day when precipitation is greater than .5".  Include the day of the week, high temperature, amount and precipitation and the total number of reported crimes for that day.

````sql
WITH precipitation_false AS (
	SELECT
		t1.reported_crime_date,
		to_char(t1.reported_crime_date, 'Day') AS day_of_week,
		t2.temp_high,
		t2.precipitation,
		count(*) AS reported_crimes
	FROM
		chicago.crimes AS t1
	JOIN
		chicago.weather AS t2
	ON
		t1.reported_crime_date = t2.weather_date
	WHERE
		t2.precipitation = 0
	GROUP BY 
		day_of_week,
		t2.precipitation,
		temp_high,
		t1.reported_crime_date
	ORDER BY
		reported_crimes DESC
	LIMIT 
		1
),
precipitation_true AS (
	SELECT
		t1.reported_crime_date,
		to_char(t1.reported_crime_date, 'Day') AS day_of_week,
		t2.temp_high,
		t2.precipitation,
		count(*) AS reported_crimes
	FROM
		chicago.crimes AS t1
	JOIN
		chicago.weather AS t2
	ON
		t1.reported_crime_date = t2.weather_date
	WHERE
		t2.precipitation > .5
	GROUP BY 
		day_of_week,
		temp_high,
		t2.precipitation,
		t1.reported_crime_date
	ORDER BY
		reported_crimes DESC
	LIMIT 
		1
)
SELECT
	*
FROM 
	precipitation_false
UNION
SELECT
	*
FROM 
	precipitation_true
ORDER BY
	reported_crimes DESC;
````

**Results:**

reported_crime_date|day_of_week|temp_high|precipitation|reported_crimes|
-------------------|-----------|---------|-------------|---------------|
2020-05-31|Sunday     |       69|          0.0|           1899|
2018-10-01|Monday     |       72|         1.56|            926|

**11.** List the most consecutive days where a homicide occured between 2018-2022 and the timeframe.

```sql
DROP TABLE IF EXISTS homicide_dates;
CREATE TEMP TABLE get_homicide_dates AS (
	SELECT 
		DISTINCT ON (reported_crime_date) reported_crime_date AS homicide_dates
	FROM
		chicago.crimes
	WHERE
		crime_type = 'homicide'
);

WITH get_rn_diff AS (
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
```

**Results:**

most_consecutive_days|consecutive_days_timeframe|
---------------------|--------------------------|
47|2020-06-13 to 2020-07-29  |

**12.** What are the top 10 most common locations for reported crimes and the number of reported crime (add percentage) depending on the temperature?

```sql
WITH get_totals AS (
	SELECT
		initcap(t1.location_description) AS location_description,
		count(*) AS location_description_count,
		sum(
			CASE
				WHEN t2.temp_high >= 60 AND t2.temp_high < 90 THEN 1
				ELSE 0
			END) AS warm_weather,
		sum(
			CASE
				WHEN t2.temp_high >= 90 THEN 1
				ELSE 0
			END) AS hot_weather,
		sum(
			CASE
				WHEN t2.temp_high < 60 AND t2.temp_high >= 32 THEN 1
				ELSE 0
			END) AS cold_weather,
		sum(
			CASE
				WHEN t2.temp_high < 32 THEN 1
				ELSE 0
			END) AS freezing_weather
	FROM
		chicago.crimes AS t1
	JOIN
		chicago.weather AS t2
	ON
		t1.reported_crime_date = t2.weather_date
	WHERE
		t1.location_description IS NOT NULL
	GROUP BY
		t1.location_description
	ORDER BY 
		location_description_count DESC
	LIMIT 10
)
SELECT
	location_description,
	location_description_count,
	warm_weather || ' (' || round(100 * (warm_weather / location_description_count::float)::NUMERIC, 2) || ')' AS warm_weather_perc,
	hot_weather || ' (' || round(100 * (hot_weather / location_description_count::float)::NUMERIC, 2) || ')' AS hot_weather_perc,
	cold_weather || ' (' || round(100 * (cold_weather / location_description_count::float)::NUMERIC, 2) || ')' AS cold_weather_perc,
	freezing_weather || ' (' || round(100 * (freezing_weather / location_description_count::float)::NUMERIC, 2) || ')' AS freezing_weather_perc
FROM
	get_totals;
```

**Results:**

location_description                  |location_description_count|warm_weather_perc|hot_weather_perc|cold_weather_perc|freezing_weather_perc|
--------------------------------------|--------------------------|-----------------|----------------|-----------------|---------------------|
Street                                |                    285785|140046 (49.00)   |19056 (6.67)    |106638 (37.31)   |20045 (7.01)         |
Apartment                             |                    196352|89500 (45.58)    |12261 (6.24)    |78170 (39.81)    |16421 (8.36)         |
Residence                             |                    190224|86110 (45.27)    |12178 (6.40)    |76640 (40.29)    |15296 (8.04)         |
Sidewalk                              |                     79100|41721 (52.74)    |6042 (7.64)     |26933 (34.05)    |4404 (5.57)          |
Small Retail Store                    |                     32251|14926 (46.28)    |2017 (6.25)     |12665 (39.27)    |2643 (8.20)          |
Restaurant                            |                     26437|11791 (44.60)    |1620 (6.13)     |10695 (40.45)    |2331 (8.82)          |
Alley                                 |                     24754|12850 (51.91)    |1747 (7.06)     |8733 (35.28)     |1424 (5.75)          |
Other                                 |                     22728|9647 (42.45)     |1251 (5.50)     |9587 (42.18)     |2243 (9.87)          |
Parking Lot / Garage (Non Residential)|                     20601|10901 (52.91)    |1389 (6.74)     |7085 (34.39)     |1226 (5.95)          |
Vehicle Non-Commercial                |                     19114|8978 (46.97)     |1283 (6.71)     |7371 (38.56)     |1482 (7.75)          |

**13.** Calculate the year over year growth in the number of reported crimes.

```sql
WITH get_year_count AS (
	SELECT
		EXTRACT('year' FROM t1.reported_crime_date) AS reported_crime_year,
		count(*) AS num_of_crimes
	FROM
		chicago.crimes AS t1
	GROUP BY
		reported_crime_year
)
SELECT 
	reported_crime_year,
	num_of_crimes,
	LAG(num_of_crimes) OVER (ORDER BY reported_crime_year) AS prev_year_count,
	round (100 * (num_of_crimes - LAG(num_of_crimes) OVER (ORDER BY reported_crime_year)) / LAG(num_of_crimes) OVER (ORDER BY reported_crime_year)::NUMERIC, 2) AS year_over_year
FROM
	get_year_count;
```

**Results:**

reported_crime_year|num_of_crimes|prev_year_count|year_over_year|
-------------------|-------------|---------------|--------------|
2018|       268816|               |              |
2019|       261293|         268816|         -2.80|
2020|       212176|         261293|        -18.80|
2021|       208759|         212176|         -1.61|
2022|       238736|         208759|         14.36|

**14.** Calculate the year over year growth in the number of reported domestic violence crimes.

```sql
WITH get_year_count AS (
	SELECT
		EXTRACT('year' FROM t1.reported_crime_date) AS domestic_crime_year,
		count(*) AS num_of_crimes
	FROM
		chicago.crimes AS t1
	WHERE
		t1.domestic = TRUE
	GROUP BY
		domestic_crime_year
)
SELECT 
	domestic_crime_year,
	num_of_crimes,
	LAG(num_of_crimes) OVER (ORDER BY domestic_crime_year) AS prev_year_count,
	round (100 * (num_of_crimes - LAG(num_of_crimes) OVER (ORDER BY domestic_crime_year)) / LAG(num_of_crimes) OVER (ORDER BY domestic_crime_year)::NUMERIC, 2) AS domestic_yoy
FROM
	get_year_count;
```

**Results:**

domestic_crime_year|num_of_crimes|prev_year_count|domestic_yoy|
-------------------|-------------|---------------|------------|
2018|        44099|               |            |
2019|        43344|          44099|       -1.71|
2020|        39983|          43344|       -7.75|
2021|        45018|          39983|       12.59|
2022|        42530|          45018|       -5.53|

**15.** Calculate the year over year growth in the number of reported domestic violence crimes.

```sql
WITH get_totals AS (
	SELECT
		to_char(t1.reported_crime_date, 'Month') AS total_month,
		COUNT(*) AS n_crimes,
		round(avg(t2.temp_high), 1) AS avg_high_temp
	FROM
		chicago.crimes AS t1
	JOIN 
		chicago.weather AS t2
	ON 
		t1.reported_crime_date = t2.weather_date
	GROUP BY
		total_month
)
SELECT
	total_month,
	n_crimes,
	LAG(n_crimes) OVER (ORDER BY TO_DATE(total_month, 'Month')) AS prev_month_count,
	avg_high_temp,
	avg_high_temp - LAG(avg_high_temp) OVER (ORDER BY TO_DATE(total_month, 'Month')) AS avg_temp_diff,
	round (100 * (n_crimes - LAG(n_crimes) OVER (ORDER BY TO_DATE(total_month, 'Month'))) / LAG(n_crimes) OVER (ORDER BY TO_DATE(total_month, 'Month'))::NUMERIC, 2) AS total_crime_growth
FROM
	get_totals;
```

**Results:**

total_month|n_crimes|prev_month_count|avg_high_temp|avg_temp_diff|total_crime_growth|
-----------|--------|----------------|-------------|-------------|------------------|
January    |   92018|                |         32.3|             |                  |
February   |   82329|           92018|         35.3|          3.0|            -10.53|
March      |   92947|           82329|         48.0|         12.7|             12.90|
April      |   88707|           92947|         56.7|          8.7|             -4.56|
May        |  103985|           88707|         71.8|         15.1|             17.22|
June       |  105163|          103985|         81.5|          9.7|              1.13|
July       |  111328|          105163|         85.2|          3.7|              5.86|
August     |  110659|          111328|         84.3|         -0.9|             -0.60|
September  |  105075|          110659|         77.2|         -7.1|             -5.05|
October    |  105563|          105075|         62.5|        -14.7|              0.46|
November   |   95501|          105563|         47.6|        -14.9|             -9.53|
December   |   96505|           95501|         40.6|         -7.0|              1.05|

**16.** List the number of crimes reported and seasonal growth for each astronomical season and what was the average temperature for each season in 2020?  Use a conditional statement to display either a Gain/Loss for the season and the season over season growth.

```sql
DROP TABLE IF EXISTS yearly_seasonal_data;
CREATE TEMP TABLE yearly_seasonal_data AS (
	WITH get_season_count AS (
		SELECT
			EXTRACT('year' FROM t1.reported_crime_date) AS crime_year,
			CASE
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('01', '02', '12') THEN '1'
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('03', '04', '05') THEN '2'
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('06', '07', '08') THEN '3'
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('09', '10', '11') THEN '4'
			END AS season,
			CASE
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('01', '02', '12') THEN count(*)
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('03', '04', '05') THEN count(*)
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('06', '07', '08') THEN count(*)
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('09', '10', '11') THEN count(*)
			END AS n_crimes,
			CASE
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('01', '02', '12') THEN avg(t2.temp_high)
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('03', '04', '05') THEN avg(t2.temp_high)
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('06', '07', '08') THEN avg(t2.temp_high)
				WHEN EXTRACT('month' FROM t1.reported_crime_date) IN ('09', '10', '11') THEN avg(t2.temp_high)
			END AS avg_temp	
		FROM
			chicago.crimes AS t1
		JOIN
			chicago.weather AS t2
		ON
			t1.reported_crime_date = t2.weather_date
		GROUP BY
			reported_crime_date,
			crime_year
	)
	SELECT
		crime_year,
		season,
		round(avg(avg_temp)::NUMERIC) AS avg_temp,
		sum(n_crimes) AS n_crimes
	FROM
		get_season_count
	GROUP BY
		crime_year,
		season
	ORDER BY
		crime_year, season
);


WITH get_buckets AS (
	SELECT
		*,
		round((n_crimes - LAG(n_crimes) OVER ()) / LAG(n_crimes) OVER ()::NUMERIC, 2) AS total_crime_growth,
		ntile(5) OVER (ORDER BY crime_year) AS nt
	FROM
		yearly_seasonal_data
)
SELECT
	crime_year,
	CASE
		WHEN season = '1' THEN 'Winter'
		WHEN season = '2' THEN 'Spring'
		WHEN season = '3' THEN 'Summer'
		WHEN season = '4' THEN 'Autumn'
	END
	,
	avg_temp,
	total_crime_growth,
	CASE
		WHEN total_crime_growth < 0 THEN 'Loss'
		ELSE 'Gain'
	END AS seasonal_growth
FROM
	get_buckets
WHERE
	nt = 3;
```

**Results:**

crime_year|case  |avg_temp|total_crime_growth|seasonal_growth|
----------|------|--------|------------------|---------------|
2020|Winter|      37|             -0.15|Loss           |
2020|Spring|      59|             -0.13|Loss           |
2020|Summer|      86|              0.21|Gain           |
2020|Autumn|      64|             -0.07|Loss           |

To be continued....

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:






