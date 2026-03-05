--------------------------------------------------------------

-- Drop tables --

DROP TABLE F_reported_crimes;

DROP TABLE station_DIM;

DROP TABLE TIME_DIM;

--------------------------------------------------------------
-- Table Creation --

-- Each entity on the model is represented by a table that needs to be created within the Database.
-- Within SQL new tables are created using the CREATE TABLE command.
-- When a table is created its name and its attributes are defined.
-- The values of which are derived from those specified on the model.
-- Certain constraints are sometimes also specified, such as identification of primary keys.

-- Create a Database table to represent the "FACT" entity.
CREATE TABLE F_reported_crimes(
    Report_id   INTEGER NOT NULL,
    Reported_crimes INTEGER,
    Closed_crimes   INTEGER,
    fk1_station_id  INTEGER NOT NULL,
    fk2_Time_id INTEGER NOT NULL,
    -- Specify the PRIMARY KEY constraint for table "F_reported_crimes_table".
    -- This indicates which attribute(s) uniquely identify each row of data.
    CONSTRAINT  pk_F_reported_crimes PRIMARY KEY (Report_id)
);

-- Create a Database table to represent the "STATION_DIM" entity.
CREATE TABLE STATION_DIM(
    Station_id  INTEGER NOT NULL,
    Station_name    VARCHAR(20) NOT NULL UNIQUE,
    -- Specify the PRIMARY KEY constraint for table "STATION_DIM".
    -- This indicates which attribute(s) uniquely identify each row of data.
    CONSTRAINT  pk_STATION_DIM PRIMARY KEY (Station_id)
);

-- Create a Database table to represent the "TIME_DIM" entity.
CREATE TABLE TIME_DIM(
    Time_id INTEGER NOT NULL,
    Year    INTEGER NOT NULL UNIQUE,
    -- Specify the PRIMARY KEY constraint for table "TIME_DIM".
    -- This indicates which attribute(s) uniquely identify each row of data.
    CONSTRAINT  pk_TIME_DIM PRIMARY KEY (Time_id)
);

--------------------------------------------------------------
-- Alter Tables to add fk constraints --

-- Now all the tables have been created the ALTER TABLE command is used to define some additional
-- constraints.  These typically constrain values of foreign keys to be associated in some way
-- with the primary keys of related tables.  Foreign key constraints can actually be specified
-- when each table is created, but doing so can lead to dependency problems within the script
-- i.e. tables may be referenced before they have been created.  This method is therefore safer.

-- Alter table to add new constraints required to implement the "FACT_STATION_DIM" relationship

-- This constraint ensures that the foreign key of table "FACT"
-- correctly references the primary key of table "STATION_DIM"

ALTER TABLE F_reported_crimes ADD CONSTRAINT fk1_FACT_to_STATION_DIM FOREIGN KEY(fk1_Station_id) REFERENCES STATION_DIM(Station_id);

-- Alter table to add new constraints required to implement the "FACT_TIME_DIM" relationship

-- This constraint ensures that the foreign key of table "FACT"
-- correctly references the primary key of table "TIME_DIM"

ALTER TABLE F_reported_crimes ADD CONSTRAINT fk2_FACT_to_TIME_DIM FOREIGN KEY(fk2_Time_id) REFERENCES TIME_DIM(Time_id);

--------------------------------------------------------------
