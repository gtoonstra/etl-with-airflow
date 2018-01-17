\c orders;

DROP TABLE IF EXISTS order_info;
DROP TABLE IF EXISTS orderline;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS product;

CREATE TABLE order_info (
    order_id    INTEGER NOT NULL,
    customer_id VARCHAR(16) NOT NULL,
    create_dtm  TIMESTAMP NOT NULL
);  

CREATE TABLE orderline (
    orderline_id  INTEGER NOT NULL,
    order_id      INTEGER NOT NULL,
    product_id    INTEGER NOT NULL,
    quantity      INTEGER NOT NULL,
    price         REAL NOT NULL
);

CREATE TABLE customer (
    customer_id    VARCHAR(16) NOT NULL,
    cust_name      VARCHAR(20) NOT NULL,
    street         VARCHAR(50),
    city           VARCHAR(30),
    updated_dtm    TIMESTAMP DEFAULT current_timestamp - interval '6 days'
);

CREATE TABLE product (
    product_id     INTEGER NOT NULL,
    product_name   VARCHAR(50) NOT NULL,
    supplier_id    INTEGER NOT NULL,
    producttype_id INTEGER NOT NULL,
    updated_dtm    TIMESTAMP DEFAULT current_timestamp - interval '6 days'
);

GRANT SELECT ON ALL TABLES IN SCHEMA public TO oltp_read;

INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (6,'CUST-004',current_timestamp - interval '1 day');
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (5,'CUST-001',current_timestamp - interval '2 day');
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (4,'CUST-002',current_timestamp - interval '2 day');
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (3,'CUST-003',current_timestamp - interval '3 days');
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (2,'CUST-001',current_timestamp - interval '5 days');
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (1,'CUST-001',current_timestamp - interval '6 days');

INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (1, 1, 1, 3, 49.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (2, 1, 2, 1, 24.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (3, 2, 2, 1, 24.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (4, 2, 3, 2, 19.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (5, 3, 1, 1, 49.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (6, 4, 1, 3, 47.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (7, 4, 3, 2, 24.50);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (8, 5, 1, 1, 49.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (9, 5, 2, 3, 24.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (10, 6, 1, 1, 48.99);

INSERT INTO customer (customer_id, cust_name, street, city, updated_dtm) VALUES ('CUST-001', 'Jonesy', 'E 187th Street', 'New York', current_timestamp - interval '6 days');
INSERT INTO customer (customer_id, cust_name, street, city, updated_dtm) VALUES ('CUST-001', 'Jones', 'E 187th Street', 'New York', current_timestamp - interval '5 days');
INSERT INTO customer (customer_id, cust_name, street, city, updated_dtm) VALUES ('CUST-001', 'Jones', 'W 82nd Street', 'New York', current_timestamp - interval '1 day');
INSERT INTO customer (customer_id, cust_name, street, city, updated_dtm) VALUES ('CUST-002', 'Doe', 'Poland St NW', 'Atlanta', current_timestamp - interval '2 day');
INSERT INTO customer (customer_id, cust_name, street, city, updated_dtm) VALUES ('CUST-003', 'Smith', 'Sotelo Ave', 'San Francisco', current_timestamp - interval '6 days');
INSERT INTO customer (customer_id, cust_name, street, city, updated_dtm) VALUES ('CUST-003', 'Smith', 'Main Street', 'Baltimore', current_timestamp - interval '3 days');
INSERT INTO customer (customer_id, cust_name, street, city, updated_dtm) VALUES ('CUST-004', 'Parker', 'Race street', 'Denver', current_timestamp - interval '1 day');

INSERT INTO product (product_id, product_name, supplier_id, producttype_id, updated_dtm) VALUES (1, 'Vacuum cleaner', 1, 1, current_timestamp - interval '6 days');
INSERT INTO product (product_id, product_name, supplier_id, producttype_id, updated_dtm) VALUES (2, 'Cleaner bags', 201, 2, current_timestamp - interval '6 days');
INSERT INTO product (product_id, product_name, supplier_id, producttype_id, updated_dtm) VALUES (3, 'Oven mittens', 380, 3, current_timestamp - interval '6 days');

INSERT INTO product (product_id, product_name, supplier_id, producttype_id, updated_dtm) VALUES (1, 'Vacuum cleaner', 1, 4, current_timestamp - interval '3 days');
INSERT INTO product (product_id, product_name, supplier_id, producttype_id, updated_dtm) VALUES (1, 'Vacuum cleaner', 1, 1, current_timestamp - interval '1 day');
