DEFINE SCHEMA DBT_DCM_DEMO.RAW{{ env_suffix }}
    COMMENT = 'Landing zone for CheckPay payroll source data';

DEFINE SCHEMA DBT_DCM_DEMO.STAGING{{ env_suffix }}
    COMMENT = 'Cleaned and standardized payroll data (dbt managed)';

DEFINE SCHEMA DBT_DCM_DEMO.MARTS{{ env_suffix }}
    WITH MANAGED ACCESS
    COMMENT = 'Business-ready CheckPay payroll analytics (dbt managed)';

DEFINE WAREHOUSE CHECKPAY_WH{{ env_suffix }}
WITH WAREHOUSE_SIZE = '{{ wh_size }}';
