
    
    

select
    CLIENT_ID as unique_field,
    count(*) as n_records

from DBT_DCM_DEMO.STAGING_DEV.stg_clients
where CLIENT_ID is not null
group by CLIENT_ID
having count(*) > 1


