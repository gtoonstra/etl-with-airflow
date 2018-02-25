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
OR COALESCE(p.namestyle, '') != COALESCE(sat.namestyle, '')
OR COALESCE(p.title, '') != COALESCE(sat.title, '')
OR COALESCE(p.firstname, '') != COALESCE(sat.firstname, '')
OR COALESCE(p.middlename, '') != COALESCE(sat.middlename, '')
OR COALESCE(p.lastname, '') != COALESCE(sat.lastname, '')
OR COALESCE(p.suffix, '') != COALESCE(sat.suffix, '')
OR COALESCE(p.emailpromotion, '') != COALESCE(sat.emailpromotion, '')
