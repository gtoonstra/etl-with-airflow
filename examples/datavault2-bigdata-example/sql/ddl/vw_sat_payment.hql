CREATE VIEW dv_raw.vw_sat_payment AS
SELECT 
          hkey_payment
        , load_dtm
        , LEAD(s.load_dtm, 1, '9999-12-31') OVER (PARTITION BY s.hkey_payment ORDER BY s.load_dtm ASC) AS load_end_dtm
        , record_source
        , checksum
        , amount
        , payment_date
FROM 
    dv_raw.sat_payment s
