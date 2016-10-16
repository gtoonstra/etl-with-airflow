CREATE TABLE order (
    order_id    INTEGER PRIMARY KEY DEFAULT nextval('serial'),
    create_dtm  TIMESTAMP
);

CREATE TABLE orderline (
    orderline_id  INTEGER PRIMARY KEY DEFAULT nextval('serial'),
    product_id    INTEGER,
    quantity      INTEGER,
    price         REAL
);

