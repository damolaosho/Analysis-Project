-- create schema
CREATE DATABASE covidDB;

USE covidDB;

CREATE TABLE covidDeaths(
iso_code VARCHAR(10),
continent VARCHAR(30),
location VARCHAR(30),
dates DATE,
population BIGINT,
total_cases INT,
new_cases INT,
new_cases_smoothed DECIMAL(12,3),
total_deaths INT,
new_deaths INT,
new_deaths_smoothed DECIMAL(10,3),
total_cases_per_million DECIMAL (10,3),
new_cases_per_million DECIMAL (10,3),
new_cases_smoothed_per_million DECIMAL(9,3),
total_deaths_per_million DECIMAL(7,3),
new_deaths_per_million DECIMAL(6,3),
new_deaths_smoothed_per_million DECIMAL(6,3),
reproduction_rate DECIMAL(3,2),
icu_patients INT,
icu_patients_per_million DECIMAL (6,3),
hosp_patients INT,
hosp_patients_per_million DECIMAL(7,3),
weekly_icu_admissions INT,
weekly_icu_admissions_per_million DECIMAL(6,3),
weekly_hosp_admissions INT,
weekly_hosp_admissions_per_million DECIMAL(6,3)
);
-- view table created
SELECT * FROM covidDeaths;
-- load csv into table as it is too large for the regular table data import wizard
LOAD DATA LOCAL INFILE '/usr/local/mysql-8.0.32-macos13-arm64/data/covidDB/covidDeaths.csv'
INTO TABLE covidDeaths
FIELDS TERMINATED BY ',' -- Specify the field delimiter
IGNORE 1 LINES;

-- bug fix to import csv into table created above
SHOW VARIABLES LIKE "secure_file_priv";

show variables like "local_infile";

set global local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- QUERIES 
-- how much percentage of the population for each continent contacted covid in each state
SELECT (SUM(total_cases)/SUM(population)) * 100 AS 'COVID INFECTION PERCENTAGE BY CONTINENT', continent
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;

--  Which continent had the highest mortality and also the lowest rate
SELECT continent, MAX(total_deaths) AS 'Highest Mortality'
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;

-- How was the death percentage in Nigeria and compare the cases to the population
SELECT dates, location,population, total_cases,total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage, (total_cases/population) * 100 AS PopulationInfectedPercentage
FROM covidDeaths
WHERE location LIKE 'Nigeria'
ORDER BY dates DESC;

-- How did COVID affect the West African countries, what was the deathpercentage, admission rates per country
SELECT iso_code, location,
SUM(population) AS Population, SUM(total_cases) AS OverallCases,SUM( total_deaths) AS OverallDeaths
,((SUM(total_deaths)/SUM(total_cases))) * 100 AS DeathPercentage, ((SUM(total_cases)/SUM(population))) * 100 AS InfectedPopulationPercentage
FROM covidDeaths
WHERE iso_code REGEXP 'BEN|BFA|CPV|GMB|GHA|GIN|GNB|LBR|MRT|MLI|NER|NGA|SEN|SLE|TGO'
GROUP BY iso_code,location
ORDER BY InfectedPopulationPercentage DESC;

-- How covid affected the world population
SELECT SUM(population) AS worldPopulation,SUM(new_cases) AS worldCases, SUM(new_deaths) AS worldDeaths,(SUM(total_cases)/SUM(population)) * 100 AS worldInfectedPercentage, (SUM(total_deaths)/SUM(total_cases)) * 100 AS worldDeathPercentage
FROM covidDeaths;

CREATE  TABLE covidVaccinations(
iso_code VARCHAR(10),
continent VARCHAR(30),
location VARCHAR(30),
dates DATE,
total_tests BIGINT,
new_tests INT,
total_tests_per_thousand DECIMAL(8,3),
new_tests_per_thousand DECIMAL(6,3),
new_tests_smotthed INT,
positive_rate DECIMAL(5,4),
tests_per_case DECIMAL(8,1),
tests_units VARCHAR(40),
total_vaccinations BIGINT,
people_vaccinated BIGINT,
people_fully_vaccinated BIGINT,
total_boosters BIGINT,
new_vaccinations INT,
new_vaccinations_smoothed INT,
total_vaccinations_per_hundred DECIMAL(5,2),
people_vaccinated_per_hundred DECIMAL(5,2),
people_fully_vaccinated_per_hundred DECIMAL(5,2),
total_boosters_per_hundred DECIMAL(5,2),
new_vaccinations_smoothed_per_million INT,
new_people_vaccinated_smoothed INT,
new_people_vaccinated_smoothed_per_hundred DECIMAL(5,3),
stringency_index DECIMAL(6,3),
population_density DECIMAL(8,3),
median_age DECIMAL(3,1),
aged_65_older  DECIMAL(5,3),
aged_70_older DECIMAL(5,3),
gdp_per_capita DECIMAL(9,3),
extreme_poverty DECIMAL(3,1),
cardiovasc_death_rate DECIMAL(9,3),
diabetes_prevalence DECIMAL(5,3),
female_smokers DECIMAL(6,3),
male_smokers DECIMAL(6,3),
handwashing_facilities DECIMAL(5,3),
hospital_beds_per_thousand DECIMAL(6,3), 
life_expectancy DECIMAL(4,2),
human_development_index DECIMAL(4,3),
excess_mortality_cumulative_absolute DECIMAL(9,4),
excess_mortality_cumulative DECIMAL(4,2),
excess_mortality DECIMAL(5,3),
excess_mortality_cumulative_per_million DECIMAL(10,5)
);

LOAD DATA LOCAL INFILE '/usr/local/mysql-8.0.32-macos13-arm64/data/covidDB/covidVaccinations.csv'
INTO TABLE covidVaccinations
FIELDS TERMINATED BY ',' -- Specify the field delimiter
IGNORE 1 LINES; 

With PopVSVac (location,population,dates,total_tests, new_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT cd.location,cd.population,cd.dates, cv.total_tests, cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location, cd.dates) AS RollingPeopleVaccinated
 FROM covidDeaths cd
JOIN covidVaccinations cv ON cd.dates = cv.dates AND cd.location = cv.location
)
SELECT *, (RollingPeopleVaccinated/ Population) * 100
FROM PopVSVac;

-- CREATING VIEW FORF FUTURE VIZ
CREATE VIEW  PercentPopulation AS 
SELECT iso_code, location,
SUM(population) AS Population, SUM(total_cases) AS OverallCases,SUM( total_deaths) AS OverallDeaths
,((SUM(total_deaths)/SUM(total_cases))) * 100 AS DeathPercentage, ((SUM(total_cases)/SUM(population))) * 100 AS InfectedPopulationPercentage
FROM covidDeaths
WHERE iso_code REGEXP 'BEN|BFA|CPV|GMB|GHA|GIN|GNB|LBR|MRT|MLI|NER|NGA|SEN|SLE|TGO'
GROUP BY iso_code,location























