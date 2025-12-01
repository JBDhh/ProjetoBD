{{ config(materialized='table') }}

WITH cargos_unicos AS (
    SELECT DISTINCT
        cargo_nome,
        funcao_nome,
        categoria_nome
    FROM {{ ref('stg_servidores_unificados') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY cargo_nome, categoria_nome) AS id_cargo,
    *
FROM cargos_unicos