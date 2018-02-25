DROP TABLE dv_star.dim_currency;

CREATE TABLE dv_star.dim_currency AS
SELECT
          CONCAT(cr.hkey_currencyrate, ':', scr.currencyratedate) as hkey_dim_currencyrate
        , cr.hkey_currencyrate
        , hca.currencycode as currencycodea
        , sca.name as currencynamea
        , hcb.currencycode as currencycodeb
        , scb.name as currencynameb
        , scr.currencyratedate
        , scr.averagerate
        , scr.endofdayrate
FROM
           dv_raw.link_currencyrate cr
INNER JOIN dv_raw.sat_currencyrate scr ON cr.hkey_currencyrate = scr.hkey_currencyrate
INNER JOIN dv_raw.hub_currency hca ON cr.hkey_currency_fromcurrencycode = hca.hkey_currency
INNER JOIN dv_raw.hub_currency hcb ON cr.hkey_currency_tocurrencycode = hcb.hkey_currency
INNER JOIN dv_raw.sat_currency sca ON cr.hkey_currency_fromcurrencycode = sca.hkey_currency
INNER JOIN dv_raw.sat_currency scb ON cr.hkey_currency_tocurrencycode = scb.hkey_currency
WHERE
           scr.currencyratedate BETWEEN sca.load_dtm AND sca.load_end_dtm
AND        scr.currencyratedate BETWEEN scb.load_dtm AND scb.load_end_dtm
