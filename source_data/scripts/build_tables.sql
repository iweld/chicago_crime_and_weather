/*
	Chicago Crime and Weather
	Author: Jaime M. Shaker
	Email: jaime.m.shaker@gmail.com or jaime@shaker.dev
	Website: https://www.shaker.dev
	LinkedIn: https://www.linkedin.com/in/jaime-shaker/
	
	File Name: build_tables.sql
	Description:  This script will import data from the CSV files and create the 
	schema, tables and table relationships for this project.  Once it is complete, 
	it will drop any unecessary schemas and tables.
*/

-- Create an schema and table for importing data
CREATE SCHEMA IF NOT EXISTS import_data;

-- Import data from CSV files
-- Create Chicago Crimes Table
DROP TABLE IF EXISTS import_data.crimes;
CREATE TABLE import_data.crimes (
	crime_id int GENERATED ALWAYS AS IDENTITY,
	date_reported TEXT,
	city_block TEXT,	
	primary_type TEXT,	
	primary_description TEXT,	
	location_description TEXT,	
	arrest TEXT,	
	domestic TEXT,	
	community_area TEXT,	
	year TEXT,	
	latitude TEXT,	
	longitude TEXT,	
	location TEXT,
	PRIMARY KEY (crime_id)
);
-- 2018 CSV files.
COPY import_data.crimes (
	date_reported,
	city_block,	
	primary_type,	
	primary_description,	
	location_description,	
	arrest,	
	domestic,	
	community_area,	
	year,	
	latitude,	
	longitude,	
	location
)
FROM '/var/lib/postgresql/source_data/csv/chicago_crime_2018.csv'
WITH DELIMITER ',' HEADER CSV;

-- 2019 CSV files.
COPY import_data.crimes (
	date_reported,
	city_block,	
	primary_type,	
	primary_description,	
	location_description,	
	arrest,	
	domestic,	
	community_area,	
	year,	
	latitude,	
	longitude,	
	location
)
FROM '/var/lib/postgresql/source_data/csv/chicago_crime_2019.csv'
WITH DELIMITER ',' HEADER CSV;

-- 2020 CSV files.
COPY import_data.crimes (
	date_reported,
	city_block,	
	primary_type,	
	primary_description,	
	location_description,	
	arrest,	
	domestic,	
	community_area,	
	year,	
	latitude,	
	longitude,	
	location
)
FROM '/var/lib/postgresql/source_data/csv/chicago_crime_2020.csv'
WITH DELIMITER ',' HEADER CSV;

-- 2021 CSV files.
COPY import_data.crimes (
	date_reported,
	city_block,	
	primary_type,	
	primary_description,	
	location_description,	
	arrest,	
	domestic,	
	community_area,	
	year,	
	latitude,	
	longitude,	
	location
)
FROM '/var/lib/postgresql/source_data/csv/chicago_crime_2021.csv'
WITH DELIMITER ',' HEADER CSV;

-- 2022 CSV files.
COPY import_data.crimes (
	date_reported,
	city_block,	
	primary_type,	
	primary_description,	
	location_description,	
	arrest,	
	domestic,	
	community_area,	
	year,	
	latitude,	
	longitude,	
	location
)
FROM '/var/lib/postgresql/source_data/csv/chicago_crime_2022.csv'
WITH DELIMITER ',' HEADER CSV;

-- Create Chicago Weather Table
DROP TABLE IF EXISTS import_data.weather;
CREATE TABLE import_data.weather (
	weather_id int GENERATED ALWAYS AS IDENTITY,
	weather_date TEXT,
	temp_high TEXT, 
	temp_low TEXT,
	average TEXT,
	precipitation TEXT, 
	PRIMARY KEY (weather_id)
);

-- Weather 2018-2022 CSV file.
COPY import_data.weather (
	weather_date,
	temp_high, 
	temp_low, 
	average,
	precipitation
)
FROM '/var/lib/postgresql/source_data/csv/chicago_temps_18-22.csv'
WITH DELIMITER ',' HEADER CSV;

-- Create Chicago Community Area Table
DROP TABLE IF EXISTS import_data.community;
CREATE TABLE import_data.community (
	community_id int, 
	community_name TEXT,
	population TEXT, 
	area_size TEXT, 
	density TEXT, 
	PRIMARY KEY (community_id)
);

-- Chicago Community CSV file.
COPY import_data.community (
	community_id, 
	community_name,
	population, 
	area_size, 
	density
)
FROM '/var/lib/postgresql/source_data/csv/chicago_areas.csv'
WITH DELIMITER ',' HEADER CSV;

-- Create an schema and tables for permanent tables
CREATE SCHEMA IF NOT EXISTS chicago;

-- Insert Crime Data from import schema
DROP TABLE IF EXISTS chicago.crimes;
CREATE TABLE chicago.crimes (
	crime_id int,
	reported_crime_date date NOT NULL,
	reported_crime_time time NOT NULL,
	street_name TEXT NOT NULL,	
	crime_type TEXT NOT NULL,	
	crime_description TEXT NOT NULL,	
	location_description TEXT,	
	arrest boolean NOT NULL,	
	domestic boolean NOT NULL,	
	community_id int,
	latitude float,	
	longitude float,	
	crime_location TEXT,
	PRIMARY KEY (crime_id)
);

INSERT INTO chicago.crimes (
	crime_id,
	reported_crime_date,
	reported_crime_time,
	street_name,
	crime_type,
	crime_description,
	location_description,
	arrest,
	domestic,
	community_id,
	latitude,
	longitude,
	crime_location
) (
	SELECT
		c.crime_id,
		date(c.date_reported::timestamp),
		c.date_reported::time,
		split_part(trim(lower(c.city_block)), ' ', 3) || ' ' || split_part(trim(lower(c.city_block)), ' ', 4),	
		trim(lower(c.primary_type)),	
		trim(lower(c.primary_description)),	
		trim(lower(c.location_description)),	
		c.arrest::boolean,	
		c.domestic::boolean,	
		c.community_area::int,	
		c.latitude::float,	
		c.longitude::float,	
		c.location
	FROM
		import_data.crimes AS c
	ORDER BY 
		-- Ordering results in random order to keep things interesting
		random()
);

-- Insert Community Data from import schema
DROP TABLE IF EXISTS chicago.community;
CREATE TABLE chicago.community (
	community_id int UNIQUE, 
	community_name TEXT,
	population int, 
	area_size float, 
	density float, 
	PRIMARY KEY (community_id)
);

INSERT INTO chicago.community (
	community_id,
	community_name,
	population,
	area_size,
	density
) (
	SELECT
		community_id,
		trim(lower(community_name)),
		population::int,
		area_size::float,
		density::float
	FROM
		import_data.community
	ORDER BY 
		random()
);

-- Insert Weather Data from import schema
DROP TABLE IF EXISTS chicago.weather;
CREATE TABLE chicago.weather (
	weather_id int,
	weather_date date UNIQUE,
	temp_high int, 
	temp_low int,
	average float,
	precipitation float, 
	PRIMARY KEY (weather_id)
);

INSERT INTO chicago.weather (
	weather_id,
	weather_date,
	temp_high,
	temp_low,
	average,
	precipitation
) (
	SELECT 
		weather_id,
		weather_date::date,
		temp_high::int,
		temp_low::int,
		average::float,
		precipitation::float
	FROM 
		import_data.weather
	ORDER BY 
		random()
);

-- Altering table for Foreign Key relationship
ALTER TABLE IF EXISTS
	chicago.crimes
DROP CONSTRAINT IF EXISTS 
	fk_community_id;

ALTER TABLE
	chicago.crimes
ADD CONSTRAINT 
	fk_community_id
FOREIGN KEY (community_id)
REFERENCES chicago.community (community_id);

-- Altering table for Foreign Key relationship
ALTER TABLE IF EXISTS
	chicago.crimes
DROP CONSTRAINT IF EXISTS 
	fk_date_reported;

ALTER TABLE
	chicago.crimes
ADD CONSTRAINT 
	fk_date_reported
FOREIGN KEY (reported_crime_date)
REFERENCES chicago.weather (weather_date);

-- Drop import schema and tables
DROP TABLE import_data.crimes;
DROP TABLE import_data.weather;
DROP TABLE import_data.community;
DROP SCHEMA import_data CASCADE;
