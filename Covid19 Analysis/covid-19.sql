
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

-- Using CTE to perform calculations
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
