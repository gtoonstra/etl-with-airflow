CREATE VIEW dv_raw.vw_sat_customer AS
SELECT 
          hkey_customer
        , load_dtm
        , LEAD(s.load_dtm, 1, '9999-12-31') OVER (PARTITION BY s.hkey_customer ORDER BY s.load_dtm ASC) AS load_end_dtm
        , record_source
        , checksum
        , active
        , activebool
        , create_date
        , first_name
        , last_name
        , address
        , address2
        , district
        , city
        , postal_code
        , phone
        , country
FROM 
    dv_raw.sat_customer s
