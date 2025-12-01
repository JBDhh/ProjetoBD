WITH metricas_python AS (
    SELECT t.ano_folha, t.mes_folha, SUM(f.valor_remuneracao_bruta) as total_bruto
    FROM servidores_etl.fato_folha f
    JOIN servidores_etl.dim_tempo t ON f.id_tempo = t.id_tempo
    GROUP BY 1, 2
),
metricas_dbt AS (
    SELECT t.ano, t.mes, SUM(f.valor_remuneracao_bruta) as total_bruto
    FROM servidores_elt.fato_folha f
    JOIN servidores_elt.dim_tempo t ON f.id_tempo = t.id_tempo
    GROUP BY 1, 2
)
SELECT
    p.ano_folha, p.mes_folha,
    p.total_bruto as vlr_python,
    d.total_bruto as vlr_dbt,
    (p.total_bruto - d.total_bruto) as diferenca
FROM metricas_python p
JOIN metricas_dbt d ON p.ano_folha = d.ano AND p.mes_folha = d.mes
WHERE (p.total_bruto - d.total_bruto) <> 0
ORDER BY 1, 2;