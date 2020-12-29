\COPY NeighbourhoodProfile from NeighbourhoodProfile.csv with csv;
\COPY Person from Personv2.csv with csv;
\COPY CaseInfo from Case.csv with csv;
\COPY Infection from Infection.csv with csv;
\COPY NeighbourhoodAge from NeighbourhoodAge.csv with csv;
\COPY Income from Income.csv with csv;

delete from NeighbourhoodProfile
where neighbourhood is null
   or population is null;

delete from Person
where assigned_ID is null
   or ageGroup is null
   or neighbourhood is null
   or gender is null;

delete from CaseInfo
where assigned_ID is null
   or classification is null
   or episodeDate is null
   or reportedDate is null
   or outcome is null;

delete from Infection
where assigned_ID is null
   or outbreak_associated is null
   or Source_of_infection is null;

delete from NeighbourhoodAge
where neighbourhood is null
   or numYoung is null
   or numMiddleAged is null
   or numElderly is null;

delete from Income
where neighbourhood is null
   or numOver125K is null
   or numBelow125K is null;
