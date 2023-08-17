

-- List the total number of reported crimes between 2018 and 2022?

SELECT to_char(count(*), '9g999g999') AS "Total Reported Crimes"
FROM chicago.crimes;

-- Results:

Total Reported Crimes|
---------------------+
 1,189,780           |

-- What is the count of Homicides, Battery and Assaults reported?

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

