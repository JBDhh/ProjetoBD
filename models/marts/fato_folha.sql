{{ config(materialized='table') }}

SELECT
    s.id_servidor,
    c.id_cargo,
    l.id_lotacao,
    t.id_tempo,
    sit.id_situacao,

    stg.jornada_mensal,
    stg.valor_salario_base,
    stg.valor_remuneracao_bruta,
    stg.valor_ferias,
    stg.valor_13_salario,
    stg.valor_irrf,
    stg.valor_previdencia,
    stg.valor_desconto_faltas,
    stg.valor_diferenca_salarial,
    stg.valor_descontos_total,
    stg.valor_liquido,
{#    stg.data_atualizacao_sistema,#}

    CASE
        WHEN stg.data_admissao = '1900-01-01' THEN 'DATA_NULA'
        WHEN stg.data_admissao > CURRENT_DATE THEN 'ADMISSAO_FUTURA'
        ELSE 'OK'
    END AS status_integridade_admissao

FROM {{ ref('stg_servidores_unificados') }} stg

LEFT JOIN {{ ref('dim_servidor') }} s
    ON stg.matricula = s.matricula
    AND stg.entidade_nome = s.entidade_nome
    AND stg.cpf = s.cpf

LEFT JOIN {{ ref('dim_cargo') }} c
    ON stg.cargo_nome = c.cargo_nome
    AND stg.funcao_nome = c.funcao_nome
    AND stg.categoria_nome = c.categoria_nome

LEFT JOIN {{ ref('dim_lotacao') }} l
    ON stg.lotacao_nome = l.lotacao_nome
    AND stg.unidade_nome = l.unidade_nome
    AND stg.entidade_nome = l.entidade_nome

LEFT JOIN {{ ref('dim_tempo') }} t
    ON (stg.ano_folha * 100 + stg.mes_folha) = t.id_tempo

LEFT JOIN {{ ref('dim_situacao') }} sit
    ON UPPER(TRIM(stg.situacao_nome)) = sit.situacao_nome