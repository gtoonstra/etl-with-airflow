INSERT INTO TABLE dv_raw.sat_film
SELECT DISTINCT
      a.dv__bk as hkey_film
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.dv__rec_source as record_source
    , a.dv__cksum as checksum
    , a.description
    , a.fulltext
    , a.length
    , a.rating
    , a.rental_duration
    , a.rental_rate
    , a.replacement_cost
    , a.special_features
FROM
                staging_dvdrentals.film_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.vw_sat_film sat
ON  sat.hkey_film       = a.dv__bk
AND sat.load_end_dtm    = unix_timestamp('9999-12-31', 'yyyy-MM-dd')
WHERE
    COALESCE(sat.checksum, '') != a.dv__cksum
