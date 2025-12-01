{{ config(materialized='table') }}

WITH lotacoes_unicas AS (
    SELECT DISTINCT
        lotacao_nome,
        unidade_nome,
        entidade_nome,
        tipo_administracao
    FROM {{ ref('stg_servidores_unificados') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY entidade_nome, unidade_nome, lotacao_nome) AS id_lotacao,
    *
FROM lotacoes_unicas