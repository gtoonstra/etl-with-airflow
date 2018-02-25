INSERT INTO TABLE dv_raw.sat_creditcard
SELECT DISTINCT
      cc.hkey_creditcard
    , cc.load_dtm
    , NULL
    , cc.record_source
    , cc.creditcardid
    , cc.cardtype
    , cc.expmonth
    , cc.expyear
FROM
                advworks_staging.creditcard_{{ts_nodash}} cc
LEFT OUTER JOIN dv_raw.sat_creditcard sat ON (
                sat.hkey_creditcard = cc.hkey_creditcard
            AND sat.load_end_dtm IS NULL)
WHERE
   COALESCE(cc.creditcardid, '') != COALESCE(sat.creditcardid, '')
OR COALESCE(cc.cardtype, '') != COALESCE(sat.cardtype, '')
OR COALESCE(cc.expmonth, '') != COALESCE(sat.expmonth, '')
OR COALESCE(cc.expyear, '') != COALESCE(sat.expyear, '')
