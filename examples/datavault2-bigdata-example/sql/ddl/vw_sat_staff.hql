CREATE VIEW dv_raw.vw_sat_staff AS
SELECT 
          hkey_staff
        , load_dtm
        , LEAD(s.load_dtm, 1, '9999-12-31') OVER (PARTITION BY s.hkey_staff ORDER BY s.load_dtm ASC) AS load_end_dtm
        , record_source
        , checksum
        , email
        , active
        , username
        , address
        , address2
        , district
        , city
        , postal_code
        , phone
        , country
FROM 
    dv_raw.sat_staff s
