-- Schema for storing information for all confirmed and probable cases
-- of Covid-19 in October 2020 and neighbourhood profiles in Toronto
-- Find the data here https://open.toronto.ca/dataset/covid-19-cases-in-toronto/
drop schema if exists Covid cascade;
create schema Covid;
set search_path to Covid;

create domain Gender as varchar(20)
not null
check (value in ('FEMALE', 'MALE', 'UNKNOWN', 'OTHER', 'TRANSGENDER'));

create domain Outcome as varchar(10)
not null
check (value in ('RESOLVED','ACTIVE','FATAL'));

create domain Class as varchar(15)
not null
check (value in ('CONFIRMED','PROBABLE'));

-- A neighbourhood in Toronto
Create table NeighbourhoodProfile(
	-- The name of the neighbourhood
	neighbourhood varchar(40) primary key,
	-- the population of the neighbourhood
	population integer
	);

-- A person living in Toronto
Create table Person(
	assigned_ID integer primary key,
	-- the age group of the person
	ageGroup varChar(40),
	-- the neighbourhood this person lives in
	neighbourhood varChar(40),
	-- the gender of this person
	gender Gender,
	Foreign key (neighbourhood) references NeighbourhoodProfile ON DELETE CASCADE
	);

-- Information about a covid-19 case
Create table CaseInfo(
	assigned_ID integer primary key,
	-- the classification of this case
	classification Class,
	-- the date that best estimates when the disease was acquired
	episodeDate Date,
	-- the date on which the case was reported to Toronto Public Health
	reportedDate Date,
	-- the outcome of the case (fatal,resolved,active)
	outcome Outcome,
	Foreign key (assigned_ID) references Person ON DELETE CASCADE
	);

-- Information regarding the infection of a person
Create table Infection(
	assigned_ID integer primary key,
	-- outbreaks of COVID-19 in Toronto healthcare institutions and healthcare settings
	outbreak_associated varChar(40),
	-- Most likely source of infection of this case
	Source_of_infection varChar(40),
	Foreign key (assigned_ID) references Person ON DELETE CASCADE
	);

-- Information about the number of young, middle aged and eldely
Create table NeighbourhoodAge(
	-- The neighbourhood name 
	neighbourhood varchar(40) primary key,
	-- Number of people that are 0-24 years in age
	numYoung integer,
	-- Number of people that are 25-64 years in age
	numMiddleAged integer,
	-- Number of people that are 65+ years in age
	numElderly integer,
	Foreign key (neighbourhood) references NeighbourhoodProfile ON DELETE CASCADE
	);

-- Information regarding the the income of families that live in this neighbourhood
Create table Income (
	-- The neighbourhood name
	neighbourhood varchar(40) primary key,
	-- Number of families that make over $125 000 annual income
	numOver125K integer,
	-- Number of families that make below $125 000 annual income
	numBelow125K integer,
	Foreign key (neighbourhood) references NeighbourhoodProfile ON DELETE CASCADE);

