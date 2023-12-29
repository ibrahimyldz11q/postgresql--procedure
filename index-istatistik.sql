CREATE OR REPLACE FUNCTION show_index_statistics() RETURNS TABLE (
    index_name TEXT,
    table_name TEXT,
    scan_count BIGINT,
    tuple_read_count BIGINT,
    tuple_fetch_count BIGINT
) AS $$
BEGIN
    FOR index_name, table_name, scan_count, tuple_read_count, tuple_fetch_count IN
        SELECT
            indexrelname,
            relname,
            idx_scan,
            idx_tup_read,
            idx_tup_fetch
        FROM
            pg_stat_user_indexes
    LOOP
        RETURN NEXT;
    END LOOP;

    RETURN;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM show_index_statistics();
