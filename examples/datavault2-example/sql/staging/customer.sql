SELECT
      c.customerid
    , c.personid
    , c.territoryid
    , LTRIM(RTRIM(COALESCE(CAST(c.customerid as varchar), ''))) as hkey_customer
    , LTRIM(RTRIM(COALESCE(CAST(p.businessentityid as varchar), ''))) as hkey_person
    , LTRIM(RTRIM(COALESCE(CAST(st.name as varchar), ''))) as hkey_salesterritory
FROM
            sales.customer c
INNER JOIN  person.person p ON c.personid = p.businessentityid
INNER JOIN  sales.salesterritory st ON st.territoryid = c.territoryid
