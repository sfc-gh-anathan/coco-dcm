select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select CLIENT_ID
from DBT_DCM_DEMO.STAGING_DEV.stg_clients
where CLIENT_ID is null



      
    ) dbt_internal_test