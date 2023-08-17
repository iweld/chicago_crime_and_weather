# Chicago Crime & Weather
## Questions and Answers

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />


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

**3.** What are the top ten communities that had the most crimes reported?  Include the current population and density and order by the number of reported crimes in descending order.

````sql
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
````

**Results:**

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

To be continued....













