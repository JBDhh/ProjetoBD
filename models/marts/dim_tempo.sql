{{ config(materialized='table') }}

WITH datas_unicas AS (
    SELECT DISTINCT
        ano_folha,
        mes_folha
    FROM {{ ref('stg_servidores_unificados') }}
)

SELECT
    (ano_folha * 100 + mes_folha) AS id_tempo,
    ano_folha AS ano,
    mes_folha AS mes,

    CASE
        WHEN mes_folha <= 6 THEN 1
        ELSE 2
    END AS semestre,

    CASE
        WHEN mes_folha IN (1, 2, 3) THEN 1
        WHEN mes_folha IN (4, 5, 6) THEN 2
        WHEN mes_folha IN (7, 8, 9) THEN 3
        ELSE 4
    END AS trimestre,

    CASE mes_folha
        WHEN 1 THEN 'JANEIRO'
        WHEN 2 THEN 'FEVEREIRO'
        WHEN 3 THEN 'MARCO'
        WHEN 4 THEN 'ABRIL'
        WHEN 5 THEN 'MAIO'
        WHEN 6 THEN 'JUNHO'
        WHEN 7 THEN 'JULHO'
        WHEN 8 THEN 'AGOSTO'
        WHEN 9 THEN 'SETEMBRO'
        WHEN 10 THEN 'OUTUBRO'
        WHEN 11 THEN 'NOVEMBRO'
        WHEN 12 THEN 'DEZEMBRO'
    END AS nome_mes

FROM datas_unicas
ORDER BY 1