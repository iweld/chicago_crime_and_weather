# Chicago Crime & Weather 2021
## Questions and Answers
#### by jaime.m.shaker@gmail.com


#### How many total crimes were reported in 2021?

````sql
SELECT count(crime_id) AS "total reported crimes"
FROM crimes;
````

**Results:**

Total Reported Crimes|
---------------------|
202536|

#### What is the count of Homicides, Battery and Assaults reported?

````sql
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
````

**Results:**

crime_type|n_crimes|
----------|--------|
battery   |   39988|
assault   |   20086|
homicide  |     803|

#### Create a temp table that joins data from all three tables

````sql
DROP TABLE IF EXISTS chicago_crimes;
CREATE TEMP TABLE chicago_crimes AS (
	SELECT
		cr.crime_id, 
		date_trunc('second', cr.crime_date) AS crime_date,
		cr.crime_date::timestamp::time AS time_reported,
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
		w.precipitation,
		cr.latitude,
		cr.longitude
	FROM crimes AS cr
	JOIN community AS co
	ON cr.community_id = co.area_id
	JOIN weather AS w
	ON w.weather_date = date(cr.crime_date)
);

SELECT * FROM chicago_crimes LIMIT 10;
````

**Results:**

crime_id|crime_date             |crime_type       |crime_description      |location_description|street_name      |community_name|population|area_size|density |arrest|domestic|temp_high|temp_low|precipitation|
--------|-----------------------|-----------------|-----------------------|--------------------|-----------------|--------------|----------|---------|--------|------|--------|---------|--------|-------------|
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


#### What are the top ten communities that had the most crimes reported?
##### We will also add the current population to see if area density is also a factor.

````sql
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
````

**Results:**

community             |population|density |reported_crimes|
----------------------|----------|--------|---------------|
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

#### What are the top ten communities that had the least amount of crimes reported?
##### We will also add the current population to see if area density is also a factor.

````sql
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
````

**Results:**

community      |population|density |Reported Crimes|
---------------|----------|--------|---------------|
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

#### What month had the most crimes reported?

````sql
SELECT
	to_char(CRIME_DATE::timestamp, 'Month') AS month,
	COUNT(*) AS n_crimes
FROM
	chicago_crimes
GROUP BY
	month
ORDER BY
	n_crimes DESC;
````

**Results:**

month    |n_crimes|
---------|--------|
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

#### What month had the most homicides and what was the average and median temperature?

````sql
SELECT
	to_char(CRIME_DATE::timestamp, 'Month') AS month,
	COUNT(*) AS n_homicides,
	round(avg(temp_high), 1) AS avg_high_temp,
	percentile_cont(0.5) WITHIN group(ORDER BY temp_high) AS median_temp
FROM
	chicago_crimes
WHERE crime_type = 'homicide'
GROUP BY
	month
ORDER BY
	n_homicides DESC;
````

**Results:**

month    |n_homicides|avg_high_temp|median_temp|
---------|-----------|-------------|-----------|
July     |        112|         82.6|       82.0|
September|         89|         80.8|       82.0|
June     |         85|         83.5|       82.0|
August   |         81|         85.3|       85.0|
May      |         66|         73.9|       75.5|
October  |         64|         67.9|       71.0|
November |         62|         50.6|       51.0|
January  |         55|         34.1|       34.0|
April    |         54|         65.1|       62.0|
December |         52|         48.6|       49.0|
March    |         45|         54.7|       52.0|
February |         38|         27.0|       26.0|

#### What weekday were most crimes committed?

````sql
SELECT
	to_char(CRIME_DATE::timestamp, 'Day') AS day_of_week,
	COUNT(*) AS n_crimes
FROM
	chicago_crimes
GROUP BY
	day_of_week
ORDER BY
	n_crimes DESC;
````

**Results:**

day_of_week|n_crimes|
-----------|--------|
Saturday   |   29841|
Friday     |   29829|
Sunday     |   29569|
Monday     |   29194|
Wednesday  |   28143|
Tuesday    |   28135|
Thursday   |   27825|

#### What are the top ten city streets that have had the most reported crimes?

````sql
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
````

**Results:**

street_name                 |n_crimes|
----------------------------|--------|
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

#### What are the top ten city streets that have had the most homicides including ties?

````sql
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
````

**Results:**

street_name                 |n_homicides|
----------------------------|-----------|
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

#### What are the top ten city streets that have had the most burglaries?

````sql
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
````

**Results:**

street_name                 |n_burglaries|
----------------------------|------------|
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


#### What was the number of reported crimes on the hottest day of the year vs the coldest?

````sql
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

SELECT
	h.temp_high,
	h.n_crimes
FROM 
	hottest AS h
UNION
SELECT
	c.temp_high,
	c.n_crimes
FROM 
	coldest AS c;
````

**Results:**

temp_high|n_crimes|
---------|--------|
95|     552|
4|     402|

#### What is the number and types of reported crimes on Michigan Ave (The Rodeo Drive of the Midwest)?

````sql
SELECT
	crime_type,
	count(*) AS michigan_ave_crimes
FROM 
	chicago_crimes
WHERE 
	street_name like '%michigan ave%'
GROUP BY 
	crime_type
ORDER BY 
	michigan_ave_crimes desc;
````

**Results:**

crime_type                       |michigan_ave_crimes|
---------------------------------|-------------------|
theft                            |                923|
battery                          |                564|
assault                          |                324|
deceptive practice               |                317|
criminal damage                  |                269|
motor vehicle theft              |                212|
other offense                    |                172|
weapons violation                |                106|
robbery                          |                106|
burglary                         |                 92|
criminal trespass                |                 53|
criminal sexual assault          |                 30|
offense involving children       |                 22|
narcotics                        |                 16|
public peace violation           |                 14|
sex offense                      |                 10|
homicide                         |                  9|
liquor law violation             |                  8|
stalking                         |                  5|
interference with public officer |                  5|
obscenity                        |                  1|
arson                            |                  1|
intimidation                     |                  1|
concealed carry license violation|                  1|

#### What are the top 5 least reported crime, how many arrests were made and the percentage of arrests made?

````sql
SELECT
	crime_type,
	least_amount,
	arrest_count,
	round(100 * (arrest_count::float / least_amount)) AS arrest_percentage
from
	(SELECT
		crime_type,
		count(*) AS least_amount,
		sum(CASE
			WHEN arrest = 'true' THEN 1
			ELSE 0
		END) AS arrest_count
	FROM chicago_crimes
	GROUP BY 
		crime_type
	ORDER BY least_amount
	LIMIT 5) AS tmp;
````

**Results:**

crime_type              |least_amount|arrest_count|arrest_percentage|
------------------------|------------|------------|-----------------|
other narcotic violation|           2|           1|             50.0|
non-criminal            |           4|           1|             25.0|
public indecency        |           4|           4|            100.0|
human trafficking       |          12|           0|              0.0|
gambling                |          13|          11|             85.0|

#### What is the percentage of domestic violence crimes?

````sql
SELECT
	100 - n_domestic_perc AS non_domestic_violence,
	n_domestic_perc AS domestic_violence
from
	(SELECT
		round(100 * (SELECT count(*) FROM chicago_crimes WHERE domestic = true)::numeric / count(*), 2) AS n_domestic_perc
	FROM 
		chicago_crimes) AS tmp
````

**Results:**

non_domestic_violence|domestic_violence|
---------------------|-----------------|
78.20|            21.80|

#### Display how many crimes were reported on a monthly basis in chronological order.  What is the month to month percentage change of crimes reported?

````sql
SELECT
	crime_month,
	n_crimes,
	round(100 * (n_crimes - LAG(n_crimes) over()) / LAG(n_crimes) over()::numeric, 2) AS month_to_month
FROM
	(SELECT
		to_char(crime_date, 'Month') AS crime_month,
		count(*) AS n_crimes
	FROM 
		chicago_crimes
	GROUP BY 
		crime_month
	ORDER BY
		to_date(to_char(crime_date, 'Month'), 'Month')) AS tmp
````

**Results:**

crime_month|n_crimes|month_to_month|
-----------|--------|--------------|
January    |   16038|              |
February   |   12888|        -19.64|
March      |   15742|         22.14|
April      |   15305|         -2.78|
May        |   17539|         14.60|
June       |   18566|          5.86|
July       |   18966|          2.15|
August     |   18255|         -3.75|
September  |   18987|          4.01|
October    |   19018|          0.16|
November   |   16974|        -10.75|
December   |   14258|        -16.00|

#### Display the most consecutive days where a homicide occured and the timeframe.

````sql
WITH get_all_dates AS (
	-- Get only one date per homicide
	SELECT DISTINCT ON (crime_date::date)
		crime_date::date AS c_date
	FROM
		chicago_crimes
	WHERE
		crime_type = 'homicide'
),
get_diff AS (
	SELECT 
		c_date,
		row_number() OVER () AS rn,
		c_date - row_number() OVER ()::int AS diff
	from
		get_all_dates
),
get_diff_count AS (
	SELECT
		c_date,
		count(*) over(PARTITION BY diff) AS diff_count
	from
		get_diff
	GROUP BY
		c_date,
		diff
)
SELECT
	max(diff_count) AS most_consecutive_days,
	min(c_date) || ' to ' || max(c_date) AS time_frame
from
	get_diff_count
WHERE diff_count > 40;
````

**Results:**

most_consecutive_days|time_frame              |
---------------------|------------------------|
43|2021-06-17 to 2021-07-29|

#### What are the top 10 most common locations for reported crimes and their frequency depending on the season?

````sql
SELECT
	location_description,
	count(*) AS location_description_count,
	sum(
		CASE
			WHEN crime_date::date >= '2021-04-15' AND crime_date::date <= '2021-10-15' THEN 1
			ELSE 0
		END) AS mild_weather,
	sum(
		CASE
			WHEN crime_date::date >= '2021-01-01' AND crime_date::date < '2021-04-15' THEN 1
			WHEN crime_date::date > '2021-10-15' AND crime_date::date <= '2021-12-31' THEN 1
			ELSE 0
		END) AS cold_weather
FROM
	chicago_crimes
WHERE
	location_description IS NOT NULL
GROUP BY
	location_description
ORDER BY 
	location_description_count DESC
LIMIT 10;
````

**Results:**

location_description                  |location_description_count|mild_weather|cold_weather|
--------------------------------------|--------------------------|------------|------------|
street                                |                     51310|       28308|       23002|
apartment                             |                     43253|       22823|       20430|
residence                             |                     31081|       15923|       15158|
sidewalk                              |                     11687|        7083|        4604|
parking lot / garage (non residential)|                      6324|        3497|        2827|
small retail store                    |                      5300|        2773|        2527|
alley                                 |                      4694|        2647|        2047|
restaurant                            |                      3650|        2025|        1625|
residence - porch / hallway           |                      2932|        1500|        1432|
gas station                           |                      2921|        1562|        1359|

#### What is the Month, day of the week and the number of homicides that occured in a babershop or beauty salon?

````sql
SELECT
	DISTINCT location_description,
	crime_type,
	to_char(crime_date, 'Month') AS crime_month,
	to_char(crime_date, 'Day') AS crime_day,
	count(*) AS incident_count
FROM
	chicago_crimes
WHERE
	location_description LIKE '%barber%'
AND 
	crime_type = 'homicide'
GROUP BY 
	location_description,
	crime_month,
	crime_day,
	crime_type
ORDER BY
	incident_count DESC;
````

**Results:**

location_description    |crime_type|crime_month|crime_day|incident_count|
------------------------|----------|-----------|---------|--------------|
barber shop/beauty salon|homicide  |July       |Wednesday|             2|
barber shop/beauty salon|homicide  |November   |Tuesday  |             2|
barber shop/beauty salon|homicide  |April      |Friday   |             1|
barber shop/beauty salon|homicide  |August     |Sunday   |             1|
barber shop/beauty salon|homicide  |January    |Thursday |             1|













