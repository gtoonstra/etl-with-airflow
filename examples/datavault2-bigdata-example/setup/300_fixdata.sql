\c dvdrentals

-- Customers have dates that are out of the region of rentals,
-- so we fudge the dates to the first rental
UPDATE customer c SET create_date = uq.min_rental_date
FROM (
select 
    min(r.rental_date) as min_rental_date,
    c.customer_id
from 
    customer c inner join rental r on r.customer_id = c.customer_id
group by
    c.customer_id ) uq
WHERE c.customer_id = uq.customer_id;

-- The payment dates are two years delayed.
-- Noticing the trend, it seems that people pay 'up-front' and 
-- then take out the rental. Probably there's a timezone
-- issue involved somewhere, but let's go with this, it is 
-- a consistent thing.
UPDATE payment p SET payment_date = a.ts_value
FROM (
SELECT
    p.payment_id,
    make_timestamp(date_part('year', r.rental_date)::int,
    date_part('month', r.rental_date)::int,
    date_part('day', r.rental_date)::int,
    date_part('hour', p.payment_date)::int,
    date_part('minute', p.payment_date)::int,
    date_part('second', p.payment_date)) as ts_value
FROM
    rental r LEFT JOIN payment p ON r.rental_id = p.rental_id
) a WHERE p.payment_id = a.payment_id;

-- There's one day with a clear system downtime (unfortunately first day?)
-- but it's outside the typical running time of the system.
-- Let's bring it within range.
UPDATE rental r SET rental_date = make_timestamp(2005,
    6,
    14,
    date_part('hour', rental_date)::int,
    date_part('minute', rental_date)::int,
    date_part('second', rental_date))
WHERE
    rental_date > '2006-02-01';

-- There's one day with a clear system downtime (unfortunately first day?)
-- but it's outside the typical running time of the system.
-- Let's bring it within range.
UPDATE payment p SET payment_date = make_timestamp(2005,
    6,
    14,
    date_part('hour', payment_date)::int,
    date_part('minute', payment_date)::int,
    date_part('second', payment_date))
WHERE
    payment_date > '2006-02-01';
