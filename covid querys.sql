--Covid death table
SELECT *
FROM [Covid-Data].dbo.covid_deaths
order by 3,4 asc

--Covid vaccine table
SELECT *
FROM [Covid-Data].dbo.covid_vaccines

--Daily death rate for total cases in each country.
SELECT
	covid_deaths.location
	,covid_deaths.date
	,covid_deaths.total_cases
	,covid_deaths.total_deaths
	,(covid_deaths.total_deaths/covid_deaths.total_cases)*100 AS daily_death_rate
FROM [Covid-Data].dbo.covid_deaths
ORDER BY 1,2;

--Daily contraction rate in each country.
SELECT
	covid_deaths.location
	,covid_deaths.date
	,covid_deaths.population
	,covid_deaths.total_cases
	,(covid_deaths.total_cases/covid_deaths.population)*100 AS contraction_rate
FROM [Covid-Data].dbo.covid_deaths
ORDER BY 1,2;

--The highest infection rate on any given day by each country.
SELECT
	dbo.covid_deaths.location
	,dbo.covid_deaths.population
	,MAX(dbo.covid_deaths.total_cases) AS max_total_case
	,(MAX(dbo.covid_deaths.total_cases)/dbo.covid_deaths.population)*100 AS contraction_rate
FROM [Covid-Data].dbo.covid_deaths
GROUP BY dbo.covid_deaths.location
		 ,dbo.covid_deaths.population
ORDER BY 4 desc;

--The highest death count on any given day for each locatation. Excluding the world and continents, only locations in the world and on the contients.
SELECT
	covid_deaths.location
	,MAX(CAST(covid_deaths.total_deaths AS int)) AS death_count
FROM [Covid-Data].dbo.covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY death_count desc;

--Highest death rate in any givin location, on any given day by each continent.
SELECT
	covid_deaths.continent
	,MAX(CAST(covid_deaths.total_deaths AS int)) AS death_count
FROM [Covid-Data].dbo.covid_deaths
WHERE covid_deaths.continent is not null
GROUP BY covid_deaths.continent
ORDER BY death_count desc;

--From here imma use a alias for the database so i dont have to type out "dbo.covid_deaths." everytime.

--Global total cases and deaths reported for each day, with the percentage death of those cases daily.
--European Union is part of Europe
SELECT
	cd.date
	,SUM(cd.new_cases)AS daily_cases
	,SUM(CAST(cd.new_deaths AS INT)) AS daily_deaths
	,(SUM(CAST(cd.new_deaths AS INT))/SUM(cd.new_cases))*100 AS daily_death_rate
FROM [Covid-Data].dbo.covid_deaths cd
WHERE continent is not null
and location not in ('World', 'European Union', 'International')
GROUP BY cd.date
ORDER BY 1,2

/*Total population in each location vs new vaccinations, along with a rolling count for the totaled and percentage of vaccinated of each location.
Used a cte because of preferance. After this i show a temp table that could be used also */
WITH pvv (continent
		,location
		,date
		,population
		,new_vaccinations
		,location_rolling_count)AS

(SELECT
	cd.continent
	,cd.location
	,cd.date
	,cd.population
	,cv.new_vaccinations
	,SUM(CONVERT(INT,cv.new_vaccinations))OVER(PARTITION BY cd.location ORDER BY CAST(cd.location AS varchar(30)), cd.date) location_rolling_count
FROM[Covid-Data].dbo.covid_deaths cd
JOIN [Covid-Data].dbo.covid_vaccines cv
	ON cd.location=cv.location
	AND cd.date=cv.date
WHERE cd.continent is not null)

SELECT *
	,(location_rolling_count/pvv.population)*100 AS percentage_rolling_count
FROM pvv
ORDER BY 2,3

--Temp table to perform the same operation as before.
--Total population in each location vs new vaccinations, along with a rolling count for the totaled and percentage of vaccinated of each location.
DROP TABLE IF EXISTS #pvv
CREATE TABLE #pvv
	(continent nvarchar(255)
	,location nvarchar(255)
	,date datetime
	,population numeric
	,new_vaccinations numeric
	,location_rolling_count numeric)

INSERT INTO #pvv
SELECT
	cd.continent
	,cd.location
	,cd.date
	,cd.population
	,cv.new_vaccinations
	,SUM(CONVERT(INT,cv.new_vaccinations))OVER(PARTITION BY cd.location ORDER BY CAST(cd.location AS varchar(40)), cd.date) location_rolling_count
FROM[Covid-Data].dbo.covid_deaths cd
JOIN [Covid-Data].dbo.covid_vaccines cv
	ON cd.location=cv.location
	AND cd.date=cv.date
WHERE cd.continent is not null

SELECT *
	,(location_rolling_count/population)*100 AS percentage_rolling_count
FROM #pvv
ORDER BY 2,3

--Creating views, Total population in each location vs new vaccinations, along with a rolling count for the totaled of vaccinated of each location.
CREATE VIEW ppv AS
SELECT
	cd.continent
	,cd.location
	,cd.date
	,cd.population
	,cv.new_vaccinations
	,SUM(CONVERT(INT,cv.new_vaccinations))OVER(PARTITION BY cd.location ORDER BY CAST(cd.location AS varchar(40)), cd.date) location_rolling_count
FROM[Covid-Data].dbo.covid_deaths cd
JOIN [Covid-Data].dbo.covid_vaccines cv
	ON cd.location=cv.location
	AND cd.date=cv.date
WHERE cd.continent is not null

--Querying off the view
SELECT *
FROM dbo.ppv


--Queries used for Tableau Project
-- 1. 
SELECT 
	SUM(cd.new_cases) AS total_cases
	,SUM(cast(cd.new_deaths AS INT)) AS total_deaths
	,SUM(cast(cd.new_deaths AS INT))/SUM(cd.New_Cases)*100 AS DeathPercentage
FROM [Covid-Data].dbo.covid_deaths cd
WHERE continent IS NOT NULL
ORDER BY 1,2

-- 2. 
-- European Union is part of Europe
SELECT
	cd.location
	,SUM(CAST(cd.new_deaths AS INT)) AS TotalDeathCount
FROM [Covid-Data].dbo.covid_deaths cd
WHERE cd.continent IS NULL 
AND cd.location NOT IN ('World', 'European Union', 'International')
GROUP BY cd.location
ORDER BY TotalDeathCount DESC

-- 3.
SELECT  
	cd.location
	,cd.population
	,MAX(cd.total_cases) AS HighestInfectionCount
	,MAX((cd.total_cases/cd.population))*100 AS PercentPopulationInfected
FROM [Covid-Data].dbo.covid_deaths cd
GROUP BY cd.location, cd.population
ORDER BY PercentPopulationInfected DESC

-- 4.
SELECT
	cd.location
	,cd.population
	,cd.date
	,MAX(cd.total_cases) AS HighestInfectionCount
	,MAX((cd.total_cases/cd.population))*100 AS PercentPopulationInfected
FROM [Covid-Data].dbo.covid_deaths cd
GROUP BY cd.location, cd.population, cd.date
ORDER BY PercentPopulationInfected DESC