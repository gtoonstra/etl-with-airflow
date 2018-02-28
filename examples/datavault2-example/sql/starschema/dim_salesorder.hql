DROP TABLE dv_star.dim_salesorder;

CREATE TABLE dv_star.dim_salesorder AS
SELECT
          hub.hkey_salesorder
        , hub.salesorderid
        , sat.revisionnumber
        , sat.orderdate
        , sat.duedate
        , sat.shipdate
        , sat.status
        , sat.onlineorderflag
        , sat.purchaseordernumber
        , sat.accountnumber
        , sat.creditcardapprovalcode
        , sat.subtotal
        , sat.taxamt
        , sat.freight
        , sat.totaldue
        , sr.name as reasonname
        , sr.reasontype
FROM
            dv_raw.sat_salesorder sat
INNER JOIN  dv_raw.hub_salesorder hub ON hub.hkey_salesorder = sat.hkey_salesorder
LEFT JOIN (
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY solink.hkey_salesorder ORDER BY srhub.name ASC) as rank,
        solink.hkey_salesorder,
        satr.name,
        satr.reasontype 
    FROM
               dv_raw.link_salesorderreason solink 
    INNER JOIN dv_raw.sat_salesreason satr ON solink.hkey_salesreason = satr.hkey_salesreason
    INNER JOIN hub_salesreason srhub ON srhub.hkey_salesreason = solink.hkey_salesreason
    WHERE
               satr.load_end_dtm IS NULL) sr
        ON sr.hkey_salesorder = hub.hkey_salesorder
WHERE
        (sr.rank = 1 OR sr.rank IS NULL)
AND     sat.load_end_dtm IS NULL
