INSERT INTO TABLE dv_raw.hub_customer
SELECT DISTINCT
    c.hkey_customer,
    c.record_source,
    c.load_dtm,
    c.customerid
FROM
    advworks_staging.customer_{{ts_nodash}} c
WHERE
    c.customerid NOT IN (
        SELECT hub.customerid FROM dv_raw.hub_customer hub
    )
