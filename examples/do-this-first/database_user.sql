DROP DATABASE orders;
DROP USER svc_account;
DROP USER db_owner;
CREATE USER db_owner PASSWORD 'db_owner';
CREATE USER svc_account PASSWORD 'svc_account';
CREATE DATABASE orders;
\c orders;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_owner;




