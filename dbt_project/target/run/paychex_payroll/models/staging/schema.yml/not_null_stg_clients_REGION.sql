select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select REGION
from DBT_DCM_DEMO.STAGING_DEV.stg_clients
where REGION is null



      
    ) dbt_internal_test