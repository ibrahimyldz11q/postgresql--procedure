CREATE OR REPLACE FUNCTION execute_query_and_handle_errors(query_text TEXT)
RETURNS TABLE (success BOOLEAN, result TEXT, error_message TEXT) AS $$
BEGIN
    -- İlk olarak, varsayılan değerleri ayarla
    success := false;
    result := '';
    error_message := '';

    BEGIN
        -- Ana sorguyu çalıştır
        EXECUTE query_text INTO result;

        -- Başarılı olduysa success değerini güncelle
        success := true;
    EXCEPTION
        WHEN others THEN
            -- Hata durumlarını ele al
            error_message := SQLERRM;
    END;

    -- Sonuçları döndür
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;




-- Başarılı bir sorgu
SELECT * FROM execute_query_and_handle_errors('SELECT 1');

-- Hata içeren bir sorgu
SELECT * FROM execute_query_and_handle_errors('SELECT * FROM non_existent_table');
