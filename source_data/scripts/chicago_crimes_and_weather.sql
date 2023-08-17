

-- List the total number of reported crimes between 2018 and 2022?

SELECT to_char(count(*), '9g999g999') AS "Total Reported Crimes"
FROM chicago.crimes;

-- Results:

Total Reported Crimes|
---------------------+
 1,189,780           |

-- What is the count of Homicides, Battery and Assaults reported?

SELECT 
	primary_type AS crime_type,
	count(*) AS n_crimes
FROM 
	chicago.crimes
WHERE 
	primary_type IN ('homicide', 'battery', 'assault')
group BY 
	crime_type
order BY 
	n_crimes DESC;

-- Results:

crime_type|n_crimes|
----------+--------+
battery   |  222214|
assault   |  100411|
homicide  |    3440|

