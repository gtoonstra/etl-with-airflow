INSERT INTO TABLE dv_raw.link_rental_transaction
SELECT DISTINCT
      Md5(CONCAT()) as hkey_rental_transaction
    , b.hkey_rental as hkey_rental
, c.hkey_customer as hkey_customer
, d.hkey_inventory as hkey_inventory
, e.hkey_staff as hkey_staff
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.rental_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_rental b ON b.rental_id = a.rental_id
  INNER JOIN dv_raw.hub_customer c ON c.customer_id = a.customer_id
  INNER JOIN dv_raw.hub_inventory d ON d.inventory_id = a.inventory_id
  INNER JOIN dv_raw.hub_staff e ON e.staff_id = a.staff_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_rental_transaction
        FROM    dv_raw.link_rental_transaction link
        WHERE 
                    link.hkey_rental = b.hkey_rental
AND     link.hkey_customer = c.hkey_customer
AND     link.hkey_inventory = d.hkey_inventory
AND     link.hkey_staff = e.hkey_staff

    )
