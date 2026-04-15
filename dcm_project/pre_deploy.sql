--------------------------------------------------------------------
-- Pre-Deploy Script
-- Runs BEFORE snow dcm plan/deploy
-- Use for: integrations, network rules, shares, or any objects
-- that DEFINE statements reference and the planner validates.
--------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS DBT_DCM_DEMO;
CREATE SCHEMA IF NOT EXISTS DBT_DCM_DEMO.PROJECTS;






