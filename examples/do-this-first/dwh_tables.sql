DROP TABLE IF EXISTS staging.order_info;
DROP TABLE IF EXISTS staging.orderline;
DROP TABLE IF EXISTS staging.audit_runs;
DROP TABLE IF EXISTS dwh.fact_order_transaction;
DROP TABLE IF EXISTS dwh.dim_customer;
DROP TABLE IF EXISTS dwh.dim_date;
DROP TABLE IF EXISTS dwh.dim_time;
DROP TABLE IF EXISTS dwh.dim_product;

CREATE TABLE staging.order_info (
    order_id    INTEGER PRIMARY KEY,
    customer_id VARCHAR(16),
    create_dtm  TIMESTAMP,
    audit_id    INTEGER,
    insert_dtm  TIMESTAMP
);

CREATE TABLE staging.orderline (
    orderline_id  INTEGER PRIMARY KEY,
    order_id      INTEGER,
    product_id    INTEGER,
    quantity      INTEGER,
    price         REAL,
    audit_id      INTEGER,
    insert_dtm    TIMESTAMP
);

CREATE TABLE staging.audit_runs (
    audit_id      INTEGER,
    audit_key     VARCHAR(16),
    execution_dtm TIMESTAMP,
    cycle_dtm     TIMESTAMP
);

GRANT USAGE ON SCHEMA staging TO dwh_svc_account;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA staging TO dwh_svc_account;

CREATE TABLE dwh.fact_order_transaction (
    order_date   DATE,
    product_key  INTEGER,
    customer_key INTEGER,
    quantity     INTEGER,
    price        REAL,
    time_key     VARCHAR(5),
    order_id     INTEGER,
    orderline_id INTEGER
);

CREATE TABLE dwh.dim_customer (
    customer_key  INTEGER PRIMARY KEY,
    customer_id   VARCHAR(16)
);

CREATE TABLE dwh.dim_product (
    product_key  INTEGER PRIMARY KEY,
    product_id   INTEGER
);

CREATE TABLE dwh.dim_date (
    date_pk       DATE,
    year          INTEGER,
    month         INTEGER,
    month_name    VARCHAR(32),
    day_of_month  INTEGER,
    day_of_year   INTEGER,
    week_day_name VARCHAR(32),
    week          INTEGER,
    fmt_datum     VARCHAR(20),
    quarter       VARCHAR(2),
    year_quarter  VARCHAR(7),
    year_month    VARCHAR(7),
    year_week     VARCHAR(7),
    month_start   DATE,
    month_end     DATE
);

CREATE TABLE dwh.dim_time (
    time_of_day  VARCHAR(5),
    hour         INTEGER,
    minute       INTEGER,
    daytime_name VARCHAR(7),
    day_night    VARCHAR(5)
);

GRANT USAGE ON SCHEMA dwh TO dwh_svc_account;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dwh TO dwh_svc_account;


INSERT INTO dwh.dim_date(
    date_pk,
    year,
    month,
    month_name,
    day_of_month,
    day_of_year,
    week_day_name,
    week,
    fmt_datum,
    quarter,
    year_quarter,
    year_month,
    year_week,
    month_start,
    month_end
)
SELECT
	datum AS date_pk,
	EXTRACT(YEAR FROM datum) AS year,
	EXTRACT(MONTH FROM datum) AS month,
	-- Localized month name
	to_char(datum, 'TMMonth') AS month_name,
	EXTRACT(DAY FROM datum) AS day_of_month,
	EXTRACT(doy FROM datum) AS day_of_year,
	-- Localized weekday
	to_char(datum, 'TMDay') AS week_day_name,
	-- ISO calendar week
	EXTRACT(week FROM datum) AS week,
	to_char(datum, 'dd. mm. yyyy') AS fmt_datum,
	'Q' || to_char(datum, 'Q') AS quarter,
	to_char(datum, 'yyyy/"Q"Q') AS year_quarter,
	to_char(datum, 'yyyy/mm') AS year_month,
	-- ISO calendar year and week
	to_char(datum, 'iyyy/IW') AS year_week,
	-- Start and end of the month of this date
	datum + (1 - EXTRACT(DAY FROM datum))::INTEGER AS month_start,
	(datum + (1 - EXTRACT(DAY FROM datum))::INTEGER + '1 month'::INTERVAL)::DATE - '1 day'::INTERVAL AS month_end
FROM (
	-- There are 3 leap years in this range, so calculate 365 * 10 + 3 records
	SELECT '2016-01-01'::DATE + SEQUENCE.DAY AS datum
	FROM generate_series(0,3652) AS SEQUENCE(DAY)
	GROUP BY SEQUENCE.DAY
     ) DQ
ORDER BY 1;


INSERT INTO dwh.dim_time ( 
    time_of_day,
    hour,
    minute,
    daytime_name,
    day_night
) 
SELECT to_char(MINUTE, 'hh24:mi') AS time_of_day,
	-- Hour of the day (0 - 23)
	EXTRACT(HOUR FROM MINUTE) AS hour, 
	-- Minute of the day (0 - 1439)
	EXTRACT(HOUR FROM MINUTE)*60 + EXTRACT(MINUTE FROM MINUTE) AS minute,
	-- Names of day periods
	CASE WHEN to_char(MINUTE, 'hh24:mi') BETWEEN '06:00' AND '08:29'
		THEN 'Morning'
	     WHEN to_char(MINUTE, 'hh24:mi') BETWEEN '08:30' AND '11:59'
		THEN 'AM'
	     WHEN to_char(MINUTE, 'hh24:mi') BETWEEN '12:00' AND '17:59'
		THEN 'PM'
	     WHEN to_char(MINUTE, 'hh24:mi') BETWEEN '18:00' AND '22:29'
		THEN 'Evening'
	     ELSE 'Night'
	END AS daytime_name,
	-- Indicator of day or night
	CASE WHEN to_char(MINUTE, 'hh24:mi') BETWEEN '07:00' AND '19:59' THEN 'Day'
	     ELSE 'Night'
	END AS day_night
FROM (SELECT '0:00'::TIME + (SEQUENCE.MINUTE || ' minutes')::INTERVAL AS MINUTE
	FROM generate_series(0,1439) AS SEQUENCE(MINUTE)
	GROUP BY SEQUENCE.MINUTE
     ) DQ
ORDER BY 1
