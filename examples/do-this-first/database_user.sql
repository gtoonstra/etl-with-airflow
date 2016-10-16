DROP DATABASE orders;
DROP USER svc_account;
CREATE USER svc_account PASSWORD 'svc_account';
CREATE DATABASE orders;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO svc_account;

