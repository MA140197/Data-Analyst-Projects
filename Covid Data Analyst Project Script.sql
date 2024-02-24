--select *
--from CovidDeaths cd 
--Order BY 3, 4

--SELECT 
--	*
--FROM CovidVaccinations cv 
--ORDER BY 3, 4

--SELECT Data we are using

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths cd 
WHERE location = 'United Kingdom'
ORDER BY 1, 2

--Total cases vs Total deaths
--This shows how likely it would be for an individual to die from covid
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as percentage_deaths
FROM CovidDeaths cd 
WHERE location = 'United Kingdom'
ORDER BY 1, 2

--Total case vs population
--Shows perctenage of population that have COVID at given date
SELECT 
	location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 as percentage_cases_vs_population
FROM CovidDeaths cd 
WHERE location = 'United Kingdom'
ORDER BY 1, 2

--rate of infection
SELECT 
	location,
	population,
	max(total_cases) as HighestInfectionCount,
	max((total_cases/population))*100 InfectedPopulationPercentage
FROM CovidDeaths cd 
GROUP BY 1, 2  	
ORDER BY InfectedPopulationPercentage DESC

--Death rate, shows rate at which infected population was dying
SELECT 
	location,
	population,
	CAST(max(total_deaths) AS INTEGER) as HighestDeathCount,
	max((CAST(total_deaths AS REAL)/population))*100 DeceasedPopulationPercentage
FROM CovidDeaths cd 
GROUP BY 1, 2  	
HAVING max(total_deaths) NOT NULL
ORDER BY DeceasedPopulationPercentage DESC

--Total deaths
SELECT 
	location,
	cast(max(total_deaths)AS REAL) as TotalDeathCount
FROM CovidDeaths cd 
GROUP BY 1  	
ORDER BY TotalDeathCount DESC

--GLOBAL Numbers
--Rate of inection 
SELECT 
	date,
	SUM(new_cases) as case_per_day,
	SUM(new_deaths) as death_per_day,
	SUM(new_deaths)/SUM(new_cases) * 100 as GlobalDeathRate 
FROM CovidDeaths cd 
GROUP BY 1
ORDER BY 1
;
--KRI of Global Figures

SELECT 
	SUM(new_cases) as case_per_day,
	SUM(new_deaths) as death_per_day,
	SUM(new_deaths)/SUM(new_cases) * 100 as GlobalDeathRate 
FROM CovidDeaths cd 
ORDER BY 1

-Looking at Population vs Vaccinations
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	population,
	cv.new_vaccinations, 
	SUM(cast(cv.new_vaccinations as REAL)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rolling_vaccination_count
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cv.date = cd.date 
AND cv.location = cd.location 
WHERE cd.continent != "" 
ORDER BY 2, 3

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccination_Count)
AS (
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	population,
	cv.new_vaccinations, 
	SUM(cast(cv.new_vaccinations as REAL)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rolling_vaccination_count
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cv.date = cd.date 
AND cv.location = cd.location 
WHERE cd.continent != "" 
ORDER BY 2, 3
)
SELECT *, (Rolling_Vaccination_Count/Population) * 100 as Percentage_of_Pop_Vaccinated
FROM PopvsVac

--Temp Tbable syntax for case count, percetnage of population with infected by date
DROP TABLE IF EXISTS PopvsInfected
CREATE TEMP TABLE PopvsInfected AS 
SELECT 
	cd.continent as Continent,
	cd.location as Location,
	cd.date as Date,
	population as Population,
	cd.new_cases as New_Cases, 
	SUM(cast(cd.new_cases  as REAL)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_Case_Count
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cv.date = cd.date 
AND cv.location = cd.location 
WHERE cd.continent != "" 
ORDER BY 2, 3

SELECT 
	*,
	(Rolling_Case_Count/Population) * 100 as PercentageInfected  
FROM PopvsInfecteds
	
--USING View, creating view of rolling death count and death percentage vs cases
SELECT 
	cd.continent Continent, 
	cd.location Location, 
	cd.date Date, 
	cd.total_cases TotalCases ,
	cd.new_deaths NewDeaths, 
	SUM(cast(cd.new_deaths as REAL)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) RollingDeathCount
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cv.date = cd.date 
AND cv.location = cd.location 
WHERE cd.continent != "" 
ORDER BY 2, 3

CREATE VIEW DeathVsCases AS
SELECT 
	cd.continent Continent, 
	cd.location Location, 
	cd.date Date, 
	cd.total_cases TotalCases ,
	cd.new_deaths NewDeaths, 
	SUM(cast(cd.new_deaths as REAL)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) RollingDeathCount
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cv.date = cd.date 
AND cv.location = cd.location 
WHERE cd.continent != "" 
ORDER BY 2, 3

SELECT 
	*,
	(RollingDeathCount/TotalCases * 100)  DeathRateOfInfected
FROM DeathVsCases 

--Creating view for visualsations

CREATE VIEW PopVaccinated AS
SELECT 
	cd.continent Continent,
	cd.location Location,
	cd.date Date,
	population Population,
	cv.new_vaccinations New_Vaccinations, 
	SUM(cast(cv.new_vaccinations as REAL)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_Vaccination_Count
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cv.date = cd.date 
AND cv.location = cd.location 
WHERE cd.continent != "" 
ORDER BY 2, 3
	

select *
from PopVaccinated
