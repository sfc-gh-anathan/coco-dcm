DEFINE SCHEMA DBT_DCM_DEMO.RAW_DEV
    COMMENT = 'Landing zone for CheckPay payroll source data';

DEFINE SCHEMA DBT_DCM_DEMO.STAGING_DEV
    COMMENT = 'Cleaned and standardized payroll data (dbt managed)';

DEFINE SCHEMA DBT_DCM_DEMO.MARTS_DEV
    WITH MANAGED ACCESS
    COMMENT = 'Business-ready CheckPay payroll analytics (dbt managed)';

DEFINE WAREHOUSE CHECKPAY_WH_DEV
WITH WAREHOUSE_SIZE = 'XSMALL';