{{ config(materialized='table') }}

WITH situacoes_unicas AS (
    SELECT DISTINCT
        situacao_nome
    FROM {{ ref('stg_servidores_unificados') }}
    WHERE situacao_nome IS NOT NULL
)

SELECT
    ROW_NUMBER() OVER (ORDER BY situacao_nome) AS id_situacao,
    situacao_nome,

    CASE
        WHEN situacao_nome LIKE '%DESLIGADO/EXONERADO%' OR situacao_nome LIKE '%APOSENTADO%' THEN FALSE
        ELSE TRUE
    END AS is_ativo

FROM situacoes_unicas