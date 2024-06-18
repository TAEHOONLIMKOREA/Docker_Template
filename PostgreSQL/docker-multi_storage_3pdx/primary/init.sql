CREATE ROLE replica WITH REPLICATION PASSWORD 'madcoder' LOGIN;

-- Set wal_level
ALTER SYSTEM SET wal_level = 'replica';

-- Set max_wal_senders
ALTER SYSTEM SET max_wal_senders = 10;

-- Set wal_keep_size
ALTER SYSTEM SET wal_keep_size = '64MB';

-- Listen on all addresses
ALTER SYSTEM SET listen_addresses = '*';

-- Reload configuration to apply changes
SELECT pg_reload_conf();