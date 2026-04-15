
    
    

select
    PAYROLL_RUN_ID as unique_field,
    count(*) as n_records

from DBT_DCM_DEMO.STAGING_DEV.stg_payroll_runs
where PAYROLL_RUN_ID is not null
group by PAYROLL_RUN_ID
having count(*) > 1


