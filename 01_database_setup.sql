-- MySQL 8+ | Run in MySQL Workbench before the Python import script.
CREATE DATABASE IF NOT EXISTS medicare_partd;
USE medicare_partd;
-- The scripts/import_to_mysql.py script imports cms_partd_raw, retaining all 46 CMS fields
-- and adding a traceable source_row_id. It also creates and loads partd_drug_year.
-- Do not execute an INSERT twice unless you intentionally rebuild the tables.
SELECT DATABASE() AS active_database;
