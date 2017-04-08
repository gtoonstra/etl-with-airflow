\c dwh;

DROP TABLE IF EXISTS staging.order_info;
DROP TABLE IF EXISTS staging.orderline;
DROP TABLE IF EXISTS staging.audit_runs;
DROP TABLE IF EXISTS staging.customer;
DROP TABLE IF EXISTS staging.product;
DROP TABLE IF EXISTS dwh.fact_orderline;
DROP TABLE IF EXISTS dwh.dim_customer;
DROP SEQUENCE IF EXISTS seq_customer;
DROP TABLE IF EXISTS dwh.dim_date;
DROP TABLE IF EXISTS dwh.dim_time;
DROP TABLE IF EXISTS dwh.dim_product;
DROP SEQUENCE IF EXISTS seq_product;

CREATE TABLE staging.order_info (
    order_id       INTEGER PRIMARY KEY NOT NULL,
    customer_id    VARCHAR(16) NOT NULL,
    create_dtm     TIMESTAMP NOT NULL,
    audit_id       INTEGER NOT NULL,
    partition_dtm  TIMESTAMP NOT NULL
);

CREATE TABLE staging.orderline (
    orderline_id   INTEGER PRIMARY KEY NOT NULL,
    order_id       INTEGER NOT NULL,
    product_id     INTEGER NOT NULL,
    quantity       INTEGER NOT NULL,
    price          REAL NOT NULL,
    audit_id       INTEGER NOT NULL,
    partition_dtm  TIMESTAMP NOT NULL
);

CREATE TABLE staging.customer (
    customer_id    VARCHAR(16) PRIMARY KEY NOT NULL,
    cust_name      VARCHAR(20) NOT NULL,
    street         VARCHAR(50),
    city           VARCHAR(30),
    audit_id       INTEGER NOT NULL,
    partition_dtm  TIMESTAMP NOT NULL
);

CREATE TABLE staging.product (
    product_id     INTEGER PRIMARY KEY NOT NULL,
    product_name   VARCHAR(50) NOT NULL,
    supplier_id    INTEGER NOT NULL,
    audit_id       INTEGER NOT NULL,
    partition_dtm  TIMESTAMP NOT NULL
);

CREATE TABLE staging.audit_runs (
    audit_id       INTEGER NOT NULL,
    audit_key      VARCHAR(16) NOT NULL,
    execution_dtm  TIMESTAMP NOT NULL,
    cycle_dtm      TIMESTAMP NOT NULL
);

GRANT USAGE ON SCHEMA staging TO dwh_svc_account;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA staging TO dwh_svc_account;

--SELECT partman.create_parent('staging.order_info', 'partition_dtm', 'time', 'daily', NULL, 4, true, to_char((CURRENT_TIMESTAMP - INTERVAL '90 days'), 'YYYY-MM-DD') );
--SELECT partman.create_parent('staging.orderline', 'partition_dtm', 'time', 'daily', NULL, 4, true, to_char((CURRENT_TIMESTAMP - INTERVAL '90 days'), 'YYYY-MM-DD' ) );
--UPDATE partman.part_config set retention = '90', retention_schema = NULL, retention_keep_table = false, retention_keep_index = false;

CREATE SEQUENCE seq_customer START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_customer TO dwh_svc_account;

CREATE TABLE dwh.dim_customer (
    customer_key  INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('seq_customer'),
    customer_id   VARCHAR(16) NOT NULL,
    cust_name     VARCHAR(20) NOT NULL,
    street        VARCHAR(50),
    city          VARCHAR(30),
    start_dtm     TIMESTAMP NOT NULL,
    end_dtm       TIMESTAMP NOT NULL DEFAULT TIMESTAMP '9999-01-01'
);

CREATE SEQUENCE seq_product START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_product TO dwh_svc_account;

CREATE TABLE dwh.dim_product (
    product_key  INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('seq_product'),
    product_id   INTEGER NOT NULL,
    product_name VARCHAR(50) NOT NULL,
    supplier_id  INTEGER NOT NULL,
    start_dtm    TIMESTAMP NOT NULL,
    end_dtm      TIMESTAMP NOT NULL DEFAULT TIMESTAMP '9999-01-01'
);

CREATE TABLE dwh.dim_date (
    date_pk       DATE NOT NULL PRIMARY KEY,
    year          INTEGER NOT NULL,
    month         INTEGER NOT NULL,
    month_name    VARCHAR(32) NOT NULL,
    day_of_month  INTEGER NOT NULL,
    day_of_year   INTEGER NOT NULL,
    week_day_name VARCHAR(32) NOT NULL,
    week          INTEGER NOT NULL,
    fmt_datum     VARCHAR(20) NOT NULL,
    quarter       VARCHAR(2) NOT NULL,
    year_quarter  VARCHAR(7) NOT NULL,
    year_month    VARCHAR(7) NOT NULL,
    year_week     VARCHAR(7) NOT NULL,
    month_start   DATE NOT NULL,
    month_end     DATE NOT NULL
);

CREATE TABLE dwh.dim_time (
    time_pk      TIME NOT NULL PRIMARY KEY,
    time_of_day  VARCHAR(5) NOT NULL,
    hour         INTEGER NOT NULL,
    minute       INTEGER NOT NULL,
    daytime_name VARCHAR(7) NOT NULL,
    day_night    VARCHAR(5) NOT NULL
);

CREATE TABLE dwh.fact_orderline (
    order_date_key   DATE NOT NULL REFERENCES dwh.dim_date (date_pk),
    time_key         TIME NOT NULL REFERENCES dwh.dim_time (time_pk),
    product_key      INTEGER NOT NULL REFERENCES dwh.dim_product (product_key),
    customer_key     INTEGER NOT NULL REFERENCES dwh.dim_customer (customer_key),
    order_id         INTEGER NOT NULL,
    orderline_id     INTEGER NOT NULL,
    quantity         INTEGER NOT NULL,
    price            REAL NOT NULL
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
    time_pk,
    time_of_day,
    hour,
    minute,
    daytime_name,
    day_night
) 
SELECT MINUTE as time_pk,
    to_char(MINUTE, 'hh24:mi') AS time_of_day,
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
