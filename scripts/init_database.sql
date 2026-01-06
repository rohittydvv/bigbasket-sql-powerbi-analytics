/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'bigbasket_DB'. 
    Additionally, the script sets up three schemas within
    the database: 'bronze', 'silver' and 'gold'.
=============================================================
*/


USE master;
GO

-- Create the main database
CREATE DATABASE bigbasket_DB;
GO
-- Use the database
USE bigbasket_DB;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO