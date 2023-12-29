CREATE TABLE performance_log (
    checkpoint_time TIMESTAMP WITHOUT TIME ZONE,
    database_name TEXT,
    buffers_alloc BIGINT,
    buffers_backend BIGINT,
    buffers_backend_fsync BIGINT,
    buffers_backend_alloc_ratio NUMERIC,
    table_name TEXT,
    seq_scans BIGINT,
    seq_rows_read BIGINT,
    idx_scans BIGINT,
    idx_rows_fetched BIGINT
);



CREATE OR REPLACE FUNCTION monitor_postgresql_performance() RETURNS VOID AS $$
BEGIN
    INSERT INTO performance_log (
        checkpoint_time,
        database_name,
        buffers_alloc,
        buffers_backend,
        buffers_backend_fsync,
        buffers_backend_alloc_ratio,
        table_name,
        seq_scans,
        seq_rows_read,
        idx_scans,
        idx_rows_fetched
    )
    SELECT
        current_timestamp::TIMESTAMP WITHOUT TIME ZONE,
        pg_database.datname::TEXT,
        pg_stat_bgwriter.checkpoints_timed,
        pg_stat_bgwriter.buffers_backend,
        pg_stat_bgwriter.buffers_backend_fsync,
        CASE
            WHEN pg_stat_bgwriter.buffers_backend > 0 THEN 
                pg_stat_bgwriter.buffers_alloc::NUMERIC / pg_stat_bgwriter.buffers_backend::NUMERIC
            ELSE 0
        END,
        pg_stat_user_tables.relname::TEXT,
        pg_stat_user_tables.seq_scan,
        pg_stat_user_tables.seq_tup_read,
        pg_stat_user_tables.idx_scan,
        pg_stat_user_tables.idx_tup_fetch
    FROM
        pg_stat_bgwriter
    CROSS JOIN
        pg_database
    LEFT JOIN
        pg_stat_user_tables ON pg_database.oid = pg_stat_user_tables.schemaname::regnamespace::OID
                            AND pg_stat_user_tables.relname = 'your_table_name'
    WHERE
        pg_database.datname = current_database();
END;
$$ LANGUAGE plpgsql;
