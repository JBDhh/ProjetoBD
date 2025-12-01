{{ config(materialized='table') }}

WITH servidores_unicos AS (
    SELECT
        matricula,
        entidade_nome,
        cpf,
        MAX(nome) as nome,
        MAX(genero) as genero,
        MAX(grau_instrucao) as grau_instrucao,
        MIN(data_admissao) as data_admissao,
        MAX(data_aposentadoria) as data_aposentadoria,

        CASE
            WHEN COUNT(*) > COUNT(data_desligamento) THEN NULL -- Recontratação
            ELSE MAX(data_desligamento)
        END as data_desligamento

    FROM {{ ref('stg_servidores_unificados') }}
    GROUP BY matricula, entidade_nome, cpf
)

SELECT
    ROW_NUMBER() OVER (ORDER BY matricula) AS id_servidor,
    *
FROM servidores_unicos