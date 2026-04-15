select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select REGION
from DBT_DCM_DEMO.MARTS_DEV.fct_payroll_volume_by_region
where REGION is null



      
    ) dbt_internal_test