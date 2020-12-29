-- Query 1 (Question 1)
DROP TABLE IF EXISTS q1a cascade;
DROP TABLE IF EXISTS q1b cascade;

CREATE TABLE q1a (
    neighbourhood varChar(40),
    population INT,
    numcases INT
);

CREATE TABLE q1b (
    neighbourhood varChar(40),
    numover125k INT,
    numBelow125K INT,
    numcases INT
);

-- Report the neighbourhood name, its population and its number of confirmed +             -- probable cases
insert into q1a
select neighbourhoodprofile.neighbourhood,population,count(CaseInfo.assigned_ID) as numCases from neighbourhoodprofile, Person, CaseInfo                                                                                                           
where CaseInfo.assigned_ID = Person.assigned_ID and Person.neighbourhood = Neighbourhoodprofile.neighbourhood
group by neighbourhoodprofile.neighbourhood;

-- Report the neighbourhood, numOver125K, numBelow125K, numCases
insert into q1b
select neighbourhoodprofile.neighbourhood,numOver125K,numBelow125K,count(CaseInfo.assigned_ID) as numCases from neighbourhoodprofile, Person, CaseInfo, Income                                                                                                           
where CaseInfo.assigned_ID = Person.assigned_ID and Person.neighbourhood = Neighbourhoodprofile.neighbourhood and Income.neighbourhood = Neighbourhoodprofile.neighbourhood
group by neighbourhoodprofile.neighbourhood,numOver125K,numBelow125K;

-- Query 2 (Question 2)
DROP TABLE IF EXISTS q2 cascade;

CREATE TABLE q2 (
    neighbourhood varChar(40),
    numFatalCases INT
);

-- Report neighbourhood and its number of fatal cases
insert into q2
select neighbourhoodprofile.neighbourhood,count(CaseInfo.assigned_ID) as numFatalCases 
from neighbourhoodprofile, Person, CaseInfo                                                                                                           
where CaseInfo.assigned_ID = Person.assigned_ID and Person.neighbourhood = Neighbourhoodprofile.neighbourhood and outcome = 'FATAL'
group by neighbourhoodprofile.neighbourhood;

-- Query 3 (Question 3)
DROP TABLE IF EXISTS q3 cascade;
DROP TABLE IF EXISTS q3b cascade;

CREATE TABLE q3 (
    neighbourhood varChar(40),
    numElderly INT,
    avgFatal decimal
);

CREATE TABLE q3b (
    neighbourhood varChar(40),
    avgFatal decimal
);

DROP VIEW IF EXISTS CasesNeighbourhoods CASCADE;

-- Connects case outcome with case neighbourhood
CREATE VIEW CasesNeighbourhoods AS
SELECT CaseInfo.assigned_ID, neighbourhood, agegroup, outcome
FROM CaseInfo, Person
WHERE (CaseInfo.assigned_ID = Person.assigned_ID);

-- Counts all cases by neighbourhoods
CREATE VIEW CasesCount3 AS
SELECT neighbourhood, COUNT(*) as countCases
FROM CasesNeighbourhoods
GROUP BY neighbourhood;

-- Sort out fatal cases
CREATE VIEW FatalCases3 AS
SELECT *
FROM CasesNeighbourhoods
WHERE (outcome = 'FATAL');

-- Counts fatal cases by neighbourhoods
CREATE VIEW FatalCounts3 AS
SELECT COUNT(*) as numFatal, neighbourhood
FROM FatalCases3
GROUP BY neighbourhood
ORDER BY numFatal DESC;

-- Connect total cases with fatal cases for each neighbourhood
CREATE VIEW SourceFatal3 AS
SELECT a.neighbourhood, numFatal, countCases
FROM FatalCounts3 as a, CasesCount3 as b
WHERE a.neighbourhood = b.neighbourhood;

-- Get the avg of fatal cases
CREATE VIEW SourceFatalAvg3 AS
SELECT neighbourhood, (numFatal::decimal / countCases::decimal) as avgFatal
FROM SourceFatal3
ORDER BY avgFatal DESC;

-- Connect avg of fatal cases with the number of elderyly
CREATE VIEW NeighbourhoodElderly3 AS
SELECT a.neighbourhood, numElderly, avgFatal
FROM NeighbourhoodAge as a, SourceFatalAvg3 as b
WHERE a.neighbourhood = b.neighbourhood
ORDER BY numElderly DESC;

insert into q3 select * from NeighbourhoodElderly3;

-- For added context, these are the areas with the highest fatal avg
insert into q3b
SELECT * 
FROM SourceFatalAvg3
ORDER BY avgFatal DESC;

-- Query 4 (Question 3)
DROP TABLE IF EXISTS q4 cascade;

CREATE TABLE q4 (
    source_of_infectio varchar(40) primary key,
    avgFatal decimal
);

DROP VIEW IF EXISTS CaseType CASCADE;

-- Get only confirmed cases
CREATE VIEW CaseType AS
SELECT a.assigned_ID, source_of_infection, outcome 
FROM Infection as a, CaseInfo as b
WHERE (a.assigned_ID = b.assigned_ID and classification = 'CONFIRMED');

-- Get only fatal cases
CREATE VIEW FatalCaseType AS
SELECT assigned_ID, source_of_infection
FROM CaseType
WHERE outcome = 'FATAL';

-- Get count of fatal cases by infection type
CREATE VIEW FatalCount AS
SELECT source_of_infection, COUNT(*) as fatalCount
FROM FatalCaseType
GROUP BY source_of_infection;

-- Get a count of total cases by infection type
CREATE VIEW SourceCount AS 
SELECT source_of_infection, COUNT(*) as sourceCount
FROM CaseType
GROUP BY source_of_infection;

-- Join the number of fatal cases with the number of cases by infection type
CREATE VIEW SourceFatal AS
SELECT a.source_of_infection, fatalCount, sourceCount
FROM FatalCount as a, SourceCount as b
WHERE a.source_of_infection = b.source_of_infection;

-- Get fatal avg for each infection type
CREATE VIEW SourceFatalAvg AS
SELECT source_of_infection, (fatalcount::decimal / sourcecount::decimal) as avgFatal
FROM SourceFatal
ORDER BY avgFatal DESC;

insert into q4 select * from SourceFatalAvg;