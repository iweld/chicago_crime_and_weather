# Chicago Crime & Weather
## Questions and Answers

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />


#### List the total number of reported crimes between 2018 and 2022?

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

#### List the total amount of Homicides, Batteries and Assaults reported between 2018 and 2022.

````sql
SELECT 
	primary_type AS crime_type,
	count(*) AS n_crimes
FROM 
	chicago.crimes
WHERE 
	primary_type IN ('homicide', 'battery', 'assault')
GROUP BY 
	crime_type
ORDER BY 
	n_crimes DESC;
````

**Results:**

crime_type|n_crimes|
----------|--------|
battery   |  222214|
assault   |  100411|
homicide  |    3440|

To be continued....













