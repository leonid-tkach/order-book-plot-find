/* active connections */
SELECT * FROM pg_stat_activity;

/* close all active connections */
SELECT
	pg_terminate_backend(pg_stat_activity.pid)
FROM
	pg_stat_activity
WHERE
	pg_stat_activity.datname = 'obpdb'
	AND pid <> pg_backend_pid();