DROP DATABASE IF EXISTS adventureworks;
DROP USER IF EXISTS db_owner;
DROP USER IF EXISTS oltp_read;
CREATE USER db_owner PASSWORD 'db_owner';
CREATE USER oltp_read PASSWORD 'oltp_read';

-- Create adventure works database
CREATE DATABASE adventureworks;

