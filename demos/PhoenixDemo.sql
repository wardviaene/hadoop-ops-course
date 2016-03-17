/* phoenix-sqlline localhost:2181:/hbase-unsecure */
CREATE TABLE customers (id VARCHAR NOT NULL PRIMARY KEY, firstname VARCHAR, lastname VARCHAR) IMMUTABLE_ROWS=true;
UPSERT INTO customers (id, firstname, lastname) VALUES ('1', 'John', 'Smith');
UPSERT INTO customers (id, firstname, lastname) VALUES ('2', 'Alice', 'Jones');
UPSERT INTO customers (id, firstname, lastname) VALUES ('3', 'Bob', 'Johnson');
UPSERT INTO customers (id, firstname, lastname) VALUES ('4', 'Jim', 'Brown');
UPSERT INTO customers (id, firstname, lastname) VALUES ('5', 'Joe', 'Williams');
UPSERT INTO customers (id, firstname, lastname) VALUES ('6', 'Tom', 'Miller');

CREATE TABLE orders (orderID VARCHAR NOT NULL PRIMARY KEY, customerID VARCHAR, orderTotal VARCHAR) IMMUTABLE_ROWS=true;
CREATE INDEX customerIDIndex on orders (customerID);
UPSERT INTO orders (orderID, customerID, orderTotal) VALUES ('1', '1', '100');
UPSERT INTO orders (orderID, customerID, orderTotal) VALUES ('2', '2', '250');
UPSERT INTO orders (orderID, customerID, orderTotal) VALUES ('3', '2', '300');
UPSERT INTO orders (orderID, customerID, orderTotal) VALUES ('4', '6', '30');
UPSERT INTO orders (orderID, customerID, orderTotal) VALUES ('5', '6', '85');
UPSERT INTO orders (orderID, customerID, orderTotal) VALUES ('6', '6', '70');

SELECT C.ID, C.Firstname, C.Lastname, O.CustomerID, O.OrderTotal
FROM Orders AS O
INNER JOIN Customers AS C
ON O.CustomerID = ID;

