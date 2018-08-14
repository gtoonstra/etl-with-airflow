DROP TABLE dv_star.dim_customer;

CREATE TABLE dv_star.dim_customer AS
SELECT
          CONCAT(sat.hkey_customer, ':', sat.load_dtm) as hkey_dim_customer
        , sat.hkey_customer
        , sat.active
        , sat.activebool
        , cast(sat.create_date as date)
        , sat.first_name
        , sat.last_name
        , sat.address
        , sat.address2
        , sat.district
        , sat.city
        , sat.postal_code
        , sat.phone
        , sat.country
FROM
            dv_raw.vw_sat_customer sat
WHERE
            sat.load_end_dtm = unix_timestamp('9999-12-31', 'yyyy-MM-dd')
