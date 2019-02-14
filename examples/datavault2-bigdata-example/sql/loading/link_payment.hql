INSERT INTO TABLE dv_raw.link_payment
SELECT DISTINCT
      Md5(CONCAT()) as hkey_payment
    , b.hkey_customer as hkey_customer
, c.hkey_staff as hkey_staff
, d.hkey_rental as hkey_rental
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.payment_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_customer b ON b.customer_id = a.customer_id
  INNER JOIN dv_raw.hub_staff c ON c.staff_id = a.staff_id
  INNER JOIN dv_raw.hub_rental d ON d.rental_id = a.rental_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_payment
        FROM    dv_raw.link_payment link
        WHERE 
                    link.hkey_customer = b.hkey_customer
AND     link.hkey_staff = c.hkey_staff
AND     link.hkey_rental = d.hkey_rental

    )
