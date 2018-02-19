INSERT INTO TABLE dv_raw.sat_salesorder
SELECT DISTINCT
      so.hkey_salesorder
    , so.load_dtm
    , NULL
    , so.record_source
    , so.revisionnumber
    , so.orderdate
    , so.duedate
    , so.shipdate
    , so.status
    , so.onlineorderflag
    , so.purchaseordernumber
    , so.accountnumber
    , so.creditcardapprovalcode
    , so.subtotal
    , so.taxamt
    , so.freight
    , so.totaldue
FROM
                advworks_staging.salesorderheader_{{ts_nodash}} so
LEFT OUTER JOIN dv_raw.sat_salesorder sat ON (
                sat.hkey_salesorder = so.hkey_salesorder
            AND sat.load_end_dtm IS NULL)
WHERE
    COALESCE(so.revisionnumber, '') != COALESCE(sat.revisionnumber, '')
AND COALESCE(so.orderdate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.orderdate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
AND COALESCE(so.duedate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.duedate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
AND COALESCE(so.shipdate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.shipdate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
AND COALESCE(so.status, '') != COALESCE(sat.status, '')
AND COALESCE(so.onlineorderflag, '') != COALESCE(sat.onlineorderflag, '')
AND COALESCE(so.purchaseordernumber, '') != COALESCE(sat.purchaseordernumber, '')
AND COALESCE(so.accountnumber, '') != COALESCE(sat.accountnumber, '')
AND COALESCE(so.creditcardapprovalcode, '') != COALESCE(sat.creditcardapprovalcode, '')
AND COALESCE(so.subtotal, '') != COALESCE(sat.subtotal, '')
AND COALESCE(so.taxamt, '') != COALESCE(sat.taxamt, '')
AND COALESCE(so.freight, '') != COALESCE(sat.freight, '')
AND COALESCE(so.totaldue, '') != COALESCE(sat.totaldue, '')
