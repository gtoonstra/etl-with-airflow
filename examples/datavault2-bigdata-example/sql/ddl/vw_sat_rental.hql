CREATE VIEW dv_raw.vw_sat_rental AS
SELECT 
          hkey_rental
        , load_dtm
        , LEAD(s.load_dtm, 1, unix_timestamp('9999-12-31', 'yyyy-MM-dd')) OVER (PARTITION BY s.hkey_rental ORDER BY s.load_dtm ASC) AS load_end_dtm
        , record_source
        , checksum
        , rental_date
        , return_date
FROM 
    dv_raw.sat_rental s
