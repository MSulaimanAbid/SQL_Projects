
--Creating the Tables
DROP TABLE IF EXISTS CovidDeaths;
DROP TABLE IF EXISTS CovidVaccinations;

CREATE TABLE CovidDeaths (
    code VARCHAR(100),
    country VARCHAR(255),
    continent VARCHAR(100),
    date DATE,
    population BIGINT,
    total_cases FLOAT,
    new_cases FLOAT,
    new_cases_smoothed FLOAT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,
    total_deaths FLOAT,
    new_deaths FLOAT,
    new_deaths_smoothed FLOAT,
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,
    excess_mortality FLOAT,
    excess_mortality_cumulative FLOAT,
    excess_mortality_cumulative_absolute FLOAT,
    excess_mortality_cumulative_per_million FLOAT,
    hosp_patients FLOAT,
    hosp_patients_per_million FLOAT,
    weekly_hosp_admissions FLOAT,
    weekly_hosp_admissions_per_million FLOAT,
    icu_patients FLOAT,
    icu_patients_per_million FLOAT,
    weekly_icu_admissions FLOAT,
    weekly_icu_admissions_per_million FLOAT
);

CREATE TABLE CovidVaccinations (
    code VARCHAR(100),
    country VARCHAR(255),
    continent VARCHAR(100),
    date DATE,
    stringency_index FLOAT,
    reproduction_rate FLOAT,
    total_tests FLOAT,
    new_tests FLOAT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed FLOAT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    total_vaccinations FLOAT,
    people_vaccinated FLOAT,
    people_fully_vaccinated FLOAT,
    total_boosters FLOAT,
    new_vaccinations FLOAT,
    new_vaccinations_smoothed FLOAT,
    total_vaccinations_per_hundred FLOAT,
    people_vaccinated_per_hundred FLOAT,
    people_fully_vaccinated_per_hundred FLOAT,
    total_boosters_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million FLOAT,
    new_people_vaccinated_smoothed FLOAT,
    new_people_vaccinated_smoothed_per_hundred FLOAT,
    population_density FLOAT,
    median_age FLOAT,
    life_expectancy FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    diabetes_prevalence FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    human_development_index FLOAT
);

--Inserting Data into tables
BULK INSERT CovidDeaths
FROM 'E:\Covid_Data_Set\CovidDeaths.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);




BULK INSERT CovidVaccinations
FROM 'E:\Covid_Data_Set\CovidVaccinations.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   TABLOCK
);

-- Exploring Covid Deaths DataSet
select *
from CovidDeaths
order by 3,4



select country , date ,total_cases , new_cases,total_deaths,population
from CovidDeaths
order by 1,2


-- Looking Death ratio in Pakistan
select country ,date, total_cases , total_deaths , (total_deaths/NULLIF(total_cases,0))*100 as death_ratio
from CovidDeaths
where country = 'Pakistan'

-- Looking into Total Cases VS Population
select country , date ,population,Total_cases, (total_cases /NULLIF(population,0))*100 as Cases_Ratio
from CovidDeaths
where country  = 'Pakistan'

-- Looking at  country which has Max Number of Infected Peoples
select country , date ,population,Total_cases, (total_cases /NULLIF(population,0))*100 as Cases_Ratio
from CovidDeaths
order by Cases_Ratio desc

-- Looking at countries which has Highest Infection rate compared to population
select country , population , Max(total_cases) as Highest_Infected , Max((total_cases /NULLIF(population,0)))*100 As Infection_Ratio
from CovidDeaths
group by country , population
order by Infection_Ratio desc


-- Showing Highest Death count per population
select country , population , Max(total_deaths) as Highest_Deaths , max((total_deaths/NULLIF(population,0)))*100 as Death_ratio
from CovidDeaths
group by Country , Population
order by Death_ratio desc

-- Now Looking the Numbers By Continent
select continent , date ,population ,
total_cases, new_cases, total_deaths
from CovidDeaths
where continent is not Null
order by 1,2

-- Looking Death ratio Per Population each country in asia
select continent ,country, population , Max(total_deaths) as HighestDeath , Max((total_deaths/NULLIF(population , 0)))*100 as death_ratio
from CovidDeaths
group by continent , country , population 
Having continent = 'asia'

-- Death Vs Cases by continent
select continent , Max(total_cases) as Cases , Max(total_deaths) as deaths, Max((total_deaths/NULLIF(total_cases,0))*100) as death_ratio
from CovidDeaths
where continent is not null 
group by continent
order by death_ratio desc

-- Death Vs population by continent
select continent , Max(population) as Population , Max(total_deaths) as deaths, Max((total_deaths/NULLIF(population,0))*100) as death_ratio
from CovidDeaths
where continent is not null 
group by continent
order by death_ratio desc 

-- Looking For First case reported 
select country , date , Total_cases , new_cases
from CovidDeaths
where continent is not null and total_cases >= 1 
order by Total_cases , date

-- Looking For First death reported 
select country , date , total_deaths , new_deaths
from CovidDeaths
where continent is not null and total_deaths >= 1 
order by total_deaths , date

-- Globel Numbers
Select sum(new_cases) as total_cases , sum(new_deaths) as total_deaths , (sum(new_deaths)/sum(new_cases))*100 as Death_ratio
from CovidDeaths
where continent is not null
order by 1,2


-- Now Exploring Covid Vaccination DataSet
select*
from CovidVaccinations

-- Looking at Total population Vs Vaccination
select dbo.CovidVaccinations.continent ,dbo.CovidDeaths.country,dbo.CovidDeaths.date,dbo.CovidDeaths.population , dbo.CovidVaccinations.new_vaccinations,
sum(dbo.covidvaccinations.new_vaccinations) over (partition by dbo.coviddeaths.country order by dbo.coviddeaths.country,dbo.coviddeaths.date) as RollingPeopleVaccinated
from CovidDeaths
join CovidVaccinations
on dbo.CovidDeaths.country = dbo.CovidVaccinations.country
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
where dbo.CovidVaccinations.continent is not null
order by 2,3


--Using CTE
with PopVsVac ( continent , country ,date , population , new_vaccinations ,RollingPeopleVaccinated )
as
(
select dbo.CovidVaccinations.continent ,dbo.CovidDeaths.country,dbo.CovidDeaths.date,dbo.CovidDeaths.population , dbo.CovidVaccinations.new_vaccinations,
sum(dbo.covidvaccinations.new_vaccinations) over (partition by dbo.coviddeaths.country order by dbo.coviddeaths.country,dbo.coviddeaths.date) as RollingPeopleVaccinated
from CovidDeaths
join CovidVaccinations
on dbo.CovidDeaths.country = dbo.CovidVaccinations.country
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
where dbo.CovidVaccinations.continent is not null
)
select * ,(RollingPeopleVaccinated/population)*100
from PopVsVac

-- Using Temp Table
Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Country nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dbo.CovidVaccinations.continent ,dbo.CovidDeaths.country,dbo.CovidDeaths.date,dbo.CovidDeaths.population , dbo.CovidVaccinations.new_vaccinations,
sum(dbo.covidvaccinations.new_vaccinations) over (partition by dbo.coviddeaths.country order by dbo.coviddeaths.country,dbo.coviddeaths.date) as RollingPeopleVaccinated
from CovidDeaths
join CovidVaccinations
on dbo.CovidDeaths.country = dbo.CovidVaccinations.country
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
where dbo.CovidVaccinations.continent is not null

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View for Visuals
create view DeathRatio_Pakistan as
select country ,date, total_cases , total_deaths , (total_deaths/NULLIF(total_cases,0))*100 as death_ratio
from CovidDeaths
where country = 'Pakistan'

create view CaseVsPopulation as
select country , date ,population,Total_cases, (total_cases /NULLIF(population,0))*100 as Cases_Ratio
from CovidDeaths
where country  = 'Pakistan'

create view DeathPerPopulation as
select country , population , Max(total_deaths) as Highest_Deaths , max((total_deaths/NULLIF(population,0)))*100 as Death_ratio
from CovidDeaths
group by Country , Population

create view Globel_Numbers as 
Select sum(new_cases) as total_cases , sum(new_deaths) as total_deaths , (sum(new_deaths)/sum(new_cases))*100 as Death_ratio
from CovidDeaths
where continent is not null

create view PercentPopulationVaccinated as
select dbo.CovidVaccinations.continent ,dbo.CovidDeaths.country,dbo.CovidDeaths.date,dbo.CovidDeaths.population , dbo.CovidVaccinations.new_vaccinations,
sum(dbo.covidvaccinations.new_vaccinations) over (partition by dbo.coviddeaths.country order by dbo.coviddeaths.country,dbo.coviddeaths.date) as RollingPeopleVaccinated
from CovidDeaths
join CovidVaccinations
on dbo.CovidDeaths.country = dbo.CovidVaccinations.country
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
where dbo.CovidVaccinations.continent is not null







 