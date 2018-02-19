INSERT INTO TABLE dv_raw.hub_address
SELECT DISTINCT
    a.hkey_address,
    a.record_source,
    a.load_dtm,
    a.postalcode,
    a.addressline1,
    a.addressline2
FROM
    advworks_staging.address_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_address
        FROM 
                dv_raw.hub_address hub
        WHERE
                hub.postalcode = a.postalcode
        AND     hub.addressline1 = a.addressline1
        AND     hub.addressline2 = a.addressline2
    )
