DEFINE SCHEMA DBT_DCM_DEMO.RAW{{ env_suffix }}
    COMMENT = 'Landing zone for Paychex payroll source data';

DEFINE SCHEMA DBT_DCM_DEMO.STAGING{{ env_suffix }}
    COMMENT = 'Cleaned and standardized payroll data (dbt managed)';

DEFINE SCHEMA DBT_DCM_DEMO.MARTS{{ env_suffix }}
    WITH MANAGED ACCESS
    COMMENT = 'Business-ready Paychex payroll analytics (dbt managed)';

DEFINE WAREHOUSE PAYCHEX_WH{{ env_suffix }}
WITH WAREHOUSE_SIZE = '{{ wh_size }}';
