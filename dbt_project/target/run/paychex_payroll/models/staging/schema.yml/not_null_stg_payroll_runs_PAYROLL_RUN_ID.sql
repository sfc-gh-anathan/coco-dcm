select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select PAYROLL_RUN_ID
from DBT_DCM_DEMO.STAGING_DEV.stg_payroll_runs
where PAYROLL_RUN_ID is null



      
    ) dbt_internal_test