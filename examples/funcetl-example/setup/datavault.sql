DROP DATABASE IF EXISTS datavault;
DROP USER IF EXISTS datavault_read;
CREATE USER datavault_read PASSWORD 'datavault_read';

-- Create orders database
CREATE DATABASE datavault;
\c datavault;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_owner;

CREATE SCHEMA datavault AUTHORIZATION db_owner;
GRANT ALL PRIVILEGES ON SCHEMA datavault TO db_owner;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA datavault TO db_owner;

DROP TABLE IF EXISTS hub_customer;
DROP TABLE IF EXISTS hub_product;
DROP TABLE IF EXISTS hub_order;
DROP TABLE IF EXISTS link_order;
DROP TABLE IF EXISTS link_orderline;
DROP TABLE IF EXISTS sat_orderline;
DROP TABLE IF EXISTS sat_customer;
DROP TABLE IF EXISTS sat_order;
DROP TABLE IF EXISTS sat_product;


CREATE TABLE hub_customer (
    h_customer_id INTEGER NOT NULL,
    -----
    customer_id VARCHAR(16) NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);  

CREATE TABLE hub_product (
    h_product_id INTEGER NOT NULL,
    -----
    product_id INTEGER NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);  

CREATE TABLE hub_order (
    h_order_id INTEGER NOT NULL,
    -----
    order_id INTEGER NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);  

CREATE TABLE link_order (
    l_order_id INTEGER NOT NULL,
    -----
    h_order_id INTEGER NOT NULL,
    h_customer_id INTEGER NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);

CREATE TABLE link_orderline (
    l_orderline_id INTEGER NOT NULL,
    -----
    l_order_id INTEGER NOT NULL,
    h_product_id INTEGER NOT NULL,
    -----
    h_rsrc VARCHAR(20) NOT NULL,
    load_audit_id INTEGER NOT NULL
);

CREATE TABLE sat_orderline (
    sat_orderline_id INTEGER NOT NULL,
    sat_load_dts    TIMESTAMP NOT NULL,
    -----
    orderline_id INTEGER NOT NULL,    
    quantity      INTEGER NOT NULL,
    price         REAL NOT NULL
);

CREATE TABLE sat_customer (
    sat_customer_id INTEGER NOT NULL,
    sat_load_dts    TIMESTAMP NOT NULL,
    -----
    cust_name      VARCHAR(20) NOT NULL,
    street         VARCHAR(50),
    city           VARCHAR(30)
);

CREATE TABLE sat_order (
    sat_order_id  INTEGER NOT NULL,
    sat_load_dts  TIMESTAMP NOT NULL,
    -----
    create_dtm    TIMESTAMP NOT NULL
);

CREATE TABLE sat_product (
    sat_product_id INTEGER NOT NULL,
    sat_load_dts   TIMESTAMP NOT NULL,
    -----
    product_name   VARCHAR(50) NOT NULL,
    supplier_id    INTEGER NOT NULL,
    producttype_id INTEGER NOT NULL
);

GRANT SELECT ON ALL TABLES IN SCHEMA public TO datavault_read;
