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
LEFT OUTER JOIN (
    SELECT  s.hkey_film,
            s.load_dtm,
            s.checksum,
            row_number() OVER (PARTITION BY s.hkey_film ORDER BY load_dtm DESC) AS most_recent_row
    FROM
            dv_raw.sat_film s
) sat 
ON  sat.hkey_film       = a.dv__bk
AND sat.most_recent_row = 1
WHERE
    COALESCE(sat.checksum, '') != a.dv__cksum
