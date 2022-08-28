SELECT * FROM covid_project.covid_deaths
WHERE continent is not null
order by 3,4;

-- Select data that we are going ot be using

SELECT location
	,date
    ,total_cases
    ,new_cases
    ,total_deaths
    ,population    
FROM covid_project.covid_deaths
ORDER BY 1,2;

-- 				Shows likehood of dying if you catch Covid in certain country
SELECT location
    ,MAX(total_cases) AS total_cases
    ,MAX(total_deaths) AS total_deaths
    ,round(AVG((total_deaths/total_cases)*100),2)AS death_percentage
FROM covid_project.covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 4 DESC;

-- Lithuianian cases
SELECT location
	,date
    ,total_cases
    ,total_deaths
    ,round((total_deaths/total_cases)*100,2)AS death_percentage
FROM covid_project.covid_deaths
WHERE location='Lithuania'
ORDER BY 2 DESC;

-- 				Shows what percentage of population got Covid
SELECT location
	,AVG(population)
    ,MAX(total_cases) AS total_cases
    ,round(AVG((total_cases/population)*100),2)AS contagiousness_percentage
FROM covid_project.covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 4 DESC;

-- Lithuanian cases: 
SELECT location
	,date
    ,population
    ,total_cases
    ,round((total_cases/population)*100,2)AS contagiousness_percentage
FROM covid_project.covid_deaths
WHERE location='Lithuania'
ORDER BY 2;

-- 			Showing Countries with Highest Infection Rate compared to Population
SELECT location
    ,population
	,MAX(total_cases) AS highest_infection_count
    ,round(MAX((total_cases/population)*100),2)AS contagiousness_percentage
FROM covid_project.covid_deaths
WHERE continent is not null
GROUP BY location,population
ORDER BY 4 DESC;

--  		Showing Countries with Highest Death Count per Population
SELECT location
    ,population
	,MAX(total_deaths) AS highest_death_count
    ,round(MAX((total_deaths/population)*100),2)AS death_percentage
FROM covid_project.covid_deaths
WHERE continent is not null
GROUP BY location,population
ORDER BY 4 DESC;

-- 		Break down by Continent
SELECT continent
	,MAX(total_deaths) AS highest_death_count
    ,round(MAX((total_deaths/population)*100),2)AS death_percentage
FROM covid_project.covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY death_percentage DESC;

--  Grouping by location with no continent
SELECT location
	,MAX(total_deaths) AS highest_death_count
    ,round(MAX((total_deaths/population)*100),2)AS death_percentage
FROM covid_project.covid_deaths
WHERE continent is null and location NOT LIKE '%income%'
GROUP BY location
ORDER BY death_percentage DESC;

-- 		Global Numbers
SELECT date
    ,SUM(new_cases) AS total_cases
    ,SUM(new_deaths) AS total_deaths
    ,round((sum(new_deaths)/sum(new_cases))*100,2)AS death_percentage
FROM covid_project.covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--  			Showing Total Population vs Vaccinations
SELECT dea.continent
	,dea.location
    ,dea.date
    ,dea.population
    ,vac.new_vaccinations
    ,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS vaccination_count
 --   ,(vaccination_count/dea.population)*100 AS
FROM covid_project.covid_deaths AS dea
JOIN covid_project.covid_vaccinations AS vac
	ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- 			 USE CTE for vaccination per population 
WITH PopvsVac (continent,location,date,population,new_vaccinations,vaccination_count)
AS
(
SELECT dea.continent
	,dea.location
    ,dea.date
    ,dea.population
    ,vac.new_vaccinations
    ,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS vaccination_count
 --   ,(vaccination_count/dea.population)*100 AS
FROM covid_project.covid_deaths AS dea
JOIN covid_project.covid_vaccinations AS vac
	ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent is not null
)
SELECT *
	,ROUND((vaccination_count/population)*100,3) AS vaccinated_per_population
FROM PopvsVac;

-- 			Creating view to store data for later visualizations
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent
	,dea.location
    ,dea.date
    ,dea.population
    ,vac.new_vaccinations
    ,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS vaccination_count
 --   ,(vaccination_count/dea.population)*100 AS
FROM covid_project.covid_deaths AS dea
JOIN covid_project.covid_vaccinations AS vac
	ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent is not null;