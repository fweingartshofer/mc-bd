create database onlineshop;
/* Connect to the new database */
\c onlineshop
DROP TABLE IF EXISTS visit;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
CREATE TABLE IF NOT EXISTS orders
(
    idorders     serial,
    user_iduser  bigint,
    married_to   bigint,
    total_sum    decimal(10, 2) NOT NULL,
    date_ordered varchar(15)    NOT NULL,
    PRIMARY KEY (idorders)
    );

INSERT INTO orders (idorders, user_iduser, total_sum, date_ordered)
VALUES (1, 1, 1200, '12.02.2021');
INSERT INTO orders (idorders, user_iduser, total_sum, date_ordered)
VALUES (2, 2, 1400, '22.02.2022');

CREATE TABLE IF NOT EXISTS order_item
(
    orders_idorders   serial,
    product_idproduct serial,
    quantity          decimal(10, 2) NOT NULL,
    price             decimal(10, 2) NOT NULL,
    PRIMARY KEY (orders_idorders, product_idproduct)
    );

INSERT INTO order_item (orders_idorders, product_idproduct, quantity, price)
VALUES (1, 1, 2, 500.00);
INSERT INTO order_item (orders_idorders, product_idproduct, quantity, price)
VALUES (1, 2, 1, 200.00);
INSERT INTO order_item (orders_idorders, product_idproduct, quantity, price)
VALUES (2, 3, 2, 500.00);
INSERT INTO order_item (orders_idorders, product_idproduct, quantity, price)
VALUES (2, 2, 2, 200.00);

CREATE TABLE IF NOT EXISTS "visit"
(
    "idvisit"     serial PRIMARY KEY ,
    "ip_address"  varchar(45) NOT NULL,
    "timestamp"   timestamp   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_iduser" bigint DEFAULT NULL,
    CHECK (idvisit>=0),
    CHECK (user_iduser>=0)
    ) ;

--
-- Daten für Tabelle "visit"
--

insert into visit ("ip_address", "timestamp", "user_iduser")
values ('10.28.14.123', NOW(), 1),
       ('10.28.14.124', NOW(), 2),
       ('10.28.14.123', NOW(), 1),
       ('10.28.14.123', NOW(), 2),
       ('10.28.14.125', NOW(), null);