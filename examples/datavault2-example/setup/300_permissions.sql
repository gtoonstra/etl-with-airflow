\c adventureworks

GRANT USAGE ON SCHEMA humanresources TO oltp_read;
GRANT USAGE ON SCHEMA person TO oltp_read;
GRANT USAGE ON SCHEMA production TO oltp_read;
GRANT USAGE ON SCHEMA purchasing TO oltp_read;
GRANT USAGE ON SCHEMA sales TO oltp_read;

GRANT SELECT ON ALL TABLES IN SCHEMA humanresources TO oltp_read;
GRANT SELECT ON ALL TABLES IN SCHEMA person TO oltp_read;
GRANT SELECT ON ALL TABLES IN SCHEMA production TO oltp_read;
GRANT SELECT ON ALL TABLES IN SCHEMA purchasing TO oltp_read;
GRANT SELECT ON ALL TABLES IN SCHEMA sales TO oltp_read;
