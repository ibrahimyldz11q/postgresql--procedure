CREATE OR REPLACE FUNCTION restore_database(
    backup_file_path TEXT,
    target_database_name TEXT
) RETURNS VOID AS $$
DECLARE
    cmd TEXT;
BEGIN
    -- Veritabanını kontrol et ve varsa kapat
    PERFORM pg_terminate_backend(pg_stat_get_backendid(datid, datdba))
    FROM pg_database WHERE datname = target_database_name;

    -- Veritabanını silebilirsiniz, ancak dikkatli olun!
    -- EXECUTE 'DROP DATABASE IF EXISTS ' || target_database_name;

    -- Yedeği geri yükle
    cmd := 'pg_restore --dbname=' || target_database_name || ' --no-password --username=' || current_user || ' --verbose ' || backup_file_path;
    EXECUTE cmd;

    -- Veritabanını aç
    EXECUTE 'ALTER DATABASE ' || target_database_name || ' OWNER TO ' || current_user;
    EXECUTE 'GRANT ALL ON DATABASE ' || target_database_name || ' TO ' || current_user;

    RAISE NOTICE 'Veritabanı başarıyla geri yüklendi: %', target_database_name;
END;
$$ LANGUAGE plpgsql;
