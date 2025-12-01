SELECT
    SUM(CASE WHEN ABS((vsalseremu - vsalsedtot) - vsalseliqd) < 0.1 THEN 1 ELSE 0 END) AS acertos_remuneracao,
    SUM(CASE WHEN ABS((vsalseprov - vsalsedtot) - vsalseliqd) < 0.1 THEN 1 ELSE 0 END) AS acertos_proventos,
    COUNT(*) as total_linhas
FROM (
    SELECT
        COALESCE(NULLIF(vsalseremu, '')::DECIMAL, 0) as vsalseremu,
        COALESCE(NULLIF(vsalseprov, '')::DECIMAL, 0) as vsalseprov,
        COALESCE(NULLIF(vsalsedtot, '')::DECIMAL, 0) as vsalsedtot,
        COALESCE(NULLIF(vsalseliqd, '')::DECIMAL, 0) as vsalseliqd
    FROM staging.raw_servidores_2021
) t;