select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        STATUS as value_field,
        count(*) as n_records

    from DBT_DCM_DEMO.STAGING_DEV.stg_payroll_runs
    group by STATUS

)

select *
from all_values
where value_field not in (
    'PENDING','COMPLETED','FAILED','CANCELLED'
)



      
    ) dbt_internal_test