INSERT INTO TABLE dv_raw.sat_person
SELECT DISTINCT
      p.hkey_person
    , p.load_dtm
    , NULL
    , p.record_source
    , p.persontype
    , p.namestyle
    , p.title
    , p.firstname
    , p.middlename
    , p.lastname
    , p.suffix
    , p.emailpromotion
FROM
                advworks_staging.person_{{ts_nodash}} p
LEFT OUTER JOIN dv_raw.sat_person sat ON (
                sat.hkey_person = p.hkey_person
            AND sat.load_end_dtm IS NULL)
WHERE
    COALESCE(p.persontype, '') != COALESCE(sat.persontype, '')
AND COALESCE(p.namestyle, '') != COALESCE(sat.namestyle, '')
AND COALESCE(p.title, '') != COALESCE(sat.title, '')
AND COALESCE(p.firstname, '') != COALESCE(sat.firstname, '')
AND COALESCE(p.middlename, '') != COALESCE(sat.middlename, '')
AND COALESCE(p.lastname, '') != COALESCE(sat.lastname, '')
AND COALESCE(p.suffix, '') != COALESCE(sat.suffix, '')
AND COALESCE(p.emailpromotion, '') != COALESCE(sat.emailpromotion, '')
