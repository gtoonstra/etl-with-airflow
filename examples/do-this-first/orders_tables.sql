DROP TABLE IF EXISTS order_info;
DROP TABLE IF EXISTS orderline;

CREATE TABLE order_info (
    order_id    INTEGER PRIMARY KEY,
    customer_id VARCHAR(16),
    create_dtm  TIMESTAMP
);  

CREATE TABLE orderline (
    orderline_id  INTEGER PRIMARY KEY,
    order_id      INTEGER,
    product_id    INTEGER,
    quantity      INTEGER,
    price         REAL
);

GRANT SELECT ON ALL TABLES IN SCHEMA public TO oltp_read;

INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (5,1,current_timestamp);
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (4,1,current_timestamp - interval '1 day');
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (3,1,current_timestamp - interval '4 days');
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (2,1,current_timestamp - interval '8 days');
INSERT INTO order_info (order_id, customer_id, create_dtm) VALUES (1,1,current_timestamp - interval '10 days');

INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (1, 1, 1, 3, 49.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (2, 1, 2, 1, 24.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (3, 2, 2, 1, 24.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (4, 2, 3, 2, 19.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (5, 3, 1, 1, 49.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (6, 4, 1, 3, 47.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (7, 4, 3, 2, 24.50);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (8, 5, 1, 1, 49.99);
INSERT INTO orderline (orderline_id, order_id, product_id, quantity, price) values (9, 5, 2, 3, 24.99);

