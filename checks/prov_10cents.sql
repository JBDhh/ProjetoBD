WITH calculo_diferenca AS (
    SELECT
        ABS(
            (COALESCE(NULLIF(vsalseprov, '')::DECIMAL, 0) -
             COALESCE(NULLIF(vsalsedtot, '')::DECIMAL, 0)) -
             COALESCE(NULLIF(vsalseliqd, '')::DECIMAL, 0)
        ) AS diferenca
    FROM staging.raw_servidores_2021
)

SELECT
    COUNT(*) as total_registros,
    SUM(CASE WHEN diferenca = 0 THEN 1 ELSE 0 END) AS exato_zero,
    SUM(CASE WHEN diferenca > 0.00 AND diferenca <= 0.01 THEN 1 ELSE 0 END) AS ate_0_01,
    SUM(CASE WHEN diferenca > 0.01 AND diferenca <= 0.10 THEN 1 ELSE 0 END) AS ate_0_10,
    SUM(CASE WHEN diferenca > 0.10 AND diferenca <= 1.00 THEN 1 ELSE 0 END) AS ate_1_00,
    MAX(diferenca) as maior_diferenca_encontrada
FROM calculo_diferenca;