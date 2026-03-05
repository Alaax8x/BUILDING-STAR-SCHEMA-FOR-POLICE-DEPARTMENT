-- Extract
-- we are going to extract the data from PRCS (Data Source 1) and PS_wales (Data Source 2).

-- Data Source 1
SELECT CRIME_STATUS, DATE_REPORTED, station_NAME FROM PL_REPORTED_CRIME R, PL_STATION S
Where R.FK2_STATION_ID = S.STATION_ID;

-- Data Source 2
SELECT CRIME_STATUS,REPORTED_DATE, CITY_NAME FROM CRIME_REGISTER C, LOCATION L
Where L.LOCATION_ID = C.LOCATION_ID;

-- Start and creat Stage area 1:
DROP TABLE S1_STAGEAREA;
CREATE TABLE S1_STAGEAREA AS SELECT CRIME_STATUS, DATE_REPORTED, station_NAME FROM PL_REPORTED_CRIME R, PL_STATION S
Where R.FK2_STATION_ID = S.STATION_ID;

-- add a column that says the source of the data.
ALTER TABLE S1_STAGEAREA 
ADD DATASOURCE VARCHAR2(5);
UPDATE S1_STAGEAREA SET DATASOURCE = 'DS1';

INSERT INTO  S1_STAGEAREA (SELECT CRIME_STATUS, REPORTED_DATE, CITY_NAME, 'DS2' FROM CRIME_REGISTER C, LOCATION L
Where L.LOCATION_ID = C.LOCATION_ID);

-- Before moving on with qquality checks, we are going to create a trigger that log any changes happen to the data.
DROP table etl_log cascade constraints;

CREATE TABLE etl_log
(issue_id NUMBER(5) NOT NULL, 
table_name VARCHAR2(20),
data_error_code NUMBER(5),
issue_desc VARCHAR2(50),
issue_date DATE, 
issue_status VARCHAR2(20),
status_update_date DATE);

drop sequence EL_SEQ;
create sequence EL_SEQ
start with 1
increment by 1
maxvalue 10000
minvalue 1;

-- Drop the existing trigger
DROP TRIGGER S1_STAGEAREA.trg_quality_chk;

-- Create the new trigger
CREATE TRIGGER trg_quality_chk
  BEFORE UPDATE ON S1_STAGEAREA
  FOR EACH ROW
BEGIN
  INSERT INTO ETL_log
  (issue_id, table_name, data_error_code, issue_desc, issue_date, issue_status, status_update_date)
  VALUES
  (
    EL_SEQ.NEXTVAL, 
    'S1_STAGEAREA', 
    '0', 
    'Quality checks', 
    SYSDATE, 
    'completed', 
    SYSDATE
  );
END;
/

-- Data Quality checks and transformation on S1_STAGEAREA:  
--  the dealing with the date issue (making it only year)
--  change 'ESCALATE' to 'OPEN'
--  the locations data may have have some dublication

-- Quality cheack - change escalate to open for easier calculation
UPDATE S1_STAGEAREA SET CRIME_STATUS = 'OPEN' WHERE CRIME_STATUS ='ESCALATE';

-- transformation  - all dates are in year formate
DROP TABLE S2_STAGEAREA;
CREATE TABLE S2_STAGEAREA AS SELECT CRIME_STATUS, EXTRACT(YEAR FROM DATE_REPORTED) as which_year, STATION_NAME, DATASOURCE FROM S1_STAGEAREA;

-- we are cleaning duplicate values for year 
DROP table stage3;
CREATE TABLE stage3  AS
SELECT  Distinct(which_year) FROM  S2_STAGEAREA GROUP by which_year;

-- Load the data to the SS
DROP sequence time_seq;
create sequence time_SEQ
start with 1
increment by 1
maxvalue 10000
minvalue 1;

INSERT INTO TIME_DIM SELECT time_seq.nextval, WHICH_YEAR FROM stage3;

-- we are cleaning duplicate values for station 
-- using the distinct and upper functions to get rid of any redundant.
-- we also did not use S2_STAGEAREA to get the data from becase some locations dont have any records. so we had to take it from the source table.
DROP table stage4;
CREATE TABLE stage4  AS
SELECT Distinct(upper(CITY_NAME)) as station_name FROM  location;
INSERT INTO  stage4 (SELECT Distinct(upper(STATION_NAME)) FROM Pl_station);

DROP sequence station_SEQ;
create sequence station_SEQ
start with 1
increment by 1
maxvalue 10000
minvalue 1;

INSERT INTO STATION_DIM SELECT station_seq.nextval, STATION_NAME FROM stage4;

-- The fact_claims table

DROP sequence fact_seq;
create sequence FACT_SEQ
start with 1
increment by 1
maxvalue 10000
minvalue 1;

DROP table tmp_crimes;
-- this tmp table contains all data we need, with the year (not the whole date)
-- the sentance that starts with sum is way to calcualte the number of closed crimes in each report.
CREATE TABLE tmp_crimes AS
SELECT 
    COUNT(*) AS REPORTED_CRIMES,
    SUM(CASE WHEN CRIME_STATUS = 'CLOSED' THEN 1 ELSE 0 END) AS CLOSED_CRIMES,
    WHICH_YEAR,
    STATION_NAME
FROM S2_STAGEAREA
GROUP BY WHICH_YEAR, STATION_NAME
ORDER BY WHICH_YEAR;

-- check the data
SELECT * FROM tmp_crimes;
SELECT * FROM time_dim;
SELECT * FROM STATION_dim;

-- inserting the data into the fact table from time and station dimension and the tem_crime tbale.
INSERT INTO F_reported_crimes (report_id, fk1_station_id, fk2_Time_id, Reported_crimes, Closed_crimes)
SELECT fact_seq.nextval, station_dim.Station_id, time_dim.time_id, tmp_crimes.REPORTED_CRIMES, tmp_crimes.CLOSED_CRIMES 
FROM tmp_crimes, time_dim, station_dim
WHERE tmp_crimes.which_year = time_dim.year AND tmp_crimes.STATION_NAME = station_dim.STATION_NAME;

SELECT * FROM tmp_crimes;
SELECT * FROM time_dim;
SELECT * FROM STATION_dim;
select * from F_reported_crimes;
select * from etl_log;

