DROP DATABASE IF EXISTS datavault;
DROP USER IF EXISTS datavault_rw;
CREATE USER datavault_rw PASSWORD 'datavault_rw';

-- Create orders database
CREATE DATABASE datavault;
\c datavault;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_owner;

CREATE SCHEMA datavault AUTHORIZATION db_owner;
GRANT ALL PRIVILEGES ON SCHEMA datavault TO db_owner;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA datavault TO db_owner;

CREATE SCHEMA staging AUTHORIZATION db_owner;
GRANT ALL PRIVILEGES ON SCHEMA staging TO db_owner;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA staging TO db_owner;


DROP TABLE IF EXISTS staging.order_info;
DROP TABLE IF EXISTS staging.orderline;
DROP TABLE IF EXISTS staging.audit_runs;
DROP TABLE IF EXISTS staging.customer;
DROP TABLE IF EXISTS staging.product;

CREATE TABLE staging.order_info (
    order_id       INTEGER PRIMARY KEY NOT NULL,
    customer_id    VARCHAR(16) NOT NULL,
    create_dtm     TIMESTAMP NOT NULL
);

CREATE TABLE staging.orderline (
    orderline_id   INTEGER PRIMARY KEY NOT NULL,
    order_id       INTEGER NOT NULL,
    product_id     INTEGER NOT NULL,
    quantity       INTEGER NOT NULL,
    price          REAL NOT NULL
);

CREATE TABLE staging.customer (
    customer_id    VARCHAR(16) NOT NULL,
    cust_name      VARCHAR(20) NOT NULL,
    street         VARCHAR(50),
    city           VARCHAR(30)
);

CREATE TABLE staging.product (
    product_id     INTEGER NOT NULL,
    product_name   VARCHAR(50) NOT NULL,
    supplier_id    INTEGER NOT NULL,
    producttype_id INTEGER NOT NULL
);

CREATE TABLE staging.audit_runs (
    audit_id       INTEGER NOT NULL,
    audit_key      VARCHAR(16) NOT NULL,
    execution_dtm  TIMESTAMP NOT NULL,
    cycle_dtm      TIMESTAMP NOT NULL
);

GRANT USAGE ON SCHEMA staging TO datavault_rw;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA staging TO datavault_rw;


DROP TABLE IF EXISTS datavault.hub_customer;
DROP TABLE IF EXISTS datavault.hub_product;
DROP TABLE IF EXISTS datavault.hub_order;
DROP TABLE IF EXISTS datavault.link_order;
DROP TABLE IF EXISTS datavault.link_orderline;
DROP TABLE IF EXISTS datavault.sat_orderline;
DROP TABLE IF EXISTS datavault.sat_customer;
DROP TABLE IF EXISTS datavault.sat_order;
DROP TABLE IF EXISTS datavault.sat_product;


CREATE SEQUENCE seq_hub_customer START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_hub_customer TO datavault_rw;

CREATE TABLE datavault.hub_customer (
    h_customer_id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('seq_hub_customer'),
    -----
    customer_id VARCHAR(16) NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);  

CREATE SEQUENCE seq_hub_product START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_hub_product TO datavault_rw;

CREATE TABLE datavault.hub_product (
    h_product_id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('seq_hub_product'),
    -----
    product_id INTEGER NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);  

CREATE SEQUENCE seq_hub_order START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_hub_order TO datavault_rw;

CREATE TABLE datavault.hub_order (
    h_order_id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('seq_hub_order'),
    -----
    order_id INTEGER NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);  

CREATE SEQUENCE seq_link_order START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_link_order TO datavault_rw;

CREATE TABLE datavault.link_order (
    l_order_id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('seq_link_order'),
    -----
    h_order_id INTEGER NOT NULL,
    h_customer_id INTEGER NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);

CREATE SEQUENCE seq_link_orderline START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_link_orderline TO datavault_rw;

CREATE TABLE datavault.link_orderline (
    l_orderline_id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('seq_link_orderline'),
    -----
    h_order_id INTEGER NOT NULL,
    h_product_id INTEGER NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);

CREATE SEQUENCE seq_sat_orderline START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_sat_orderline TO datavault_rw;

CREATE TABLE datavault.sat_orderline (
    l_orderline_id INTEGER PRIMARY KEY NOT NULL,
    load_dts       TIMESTAMP NOT NULL,
    -----
    quantity       INTEGER NOT NULL,
    price          REAL NOT NULL
);

CREATE SEQUENCE seq_sat_customer START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_sat_customer TO datavault_rw;

CREATE TABLE datavault.sat_customer (
    h_customer_id  INTEGER PRIMARY KEY NOT NULL,
    load_dts       TIMESTAMP NOT NULL,
    -----
    cust_name      VARCHAR(20) NOT NULL,
    street         VARCHAR(50),
    city           VARCHAR(30)
);

CREATE SEQUENCE seq_sat_order START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_sat_order TO datavault_rw;

CREATE TABLE datavault.sat_order (
    h_order_id    INTEGER PRIMARY KEY NOT NULL,
    load_dts      TIMESTAMP NOT NULL,
    -----
    create_dtm    TIMESTAMP NOT NULL
);

CREATE SEQUENCE seq_sat_product START 1;
GRANT USAGE, SELECT ON SEQUENCE seq_sat_product TO datavault_rw;

CREATE TABLE datavault.sat_product (
    h_product_id   INTEGER PRIMARY KEY NOT NULL,
    load_dts       TIMESTAMP NOT NULL,
    -----
    product_name   VARCHAR(50) NOT NULL,
    supplier_id    INTEGER NOT NULL,
    producttype_id INTEGER NOT NULL
);

GRANT USAGE ON SCHEMA public TO datavault_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO datavault_rw;
GRANT USAGE ON SCHEMA datavault TO datavault_rw;
GRANT SELECT, INSERT, DELETE ON ALL TABLES IN SCHEMA datavault TO datavault_rw;
