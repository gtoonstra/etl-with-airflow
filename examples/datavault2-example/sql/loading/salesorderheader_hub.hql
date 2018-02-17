INSERT INTO TABLE dv2_raw.hub_salesorder
SELECT DISTINCT
    hash_key_salesorderheader,
    load_date,
    record_source,
    salesorderid
FROM
    staging_advworks.salesorderheader_{{ds_nodash}}
WHERE
    salesorderid NOT IN (
        SELECT salesorderid FROM dv2_raw.hub_salesorder
    )
AND load_date = '{{ds}}'
