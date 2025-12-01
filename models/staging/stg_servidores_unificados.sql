WITH unificado AS (
    SELECT * FROM {{ source('dados_brutos', 'raw_servidores_2019') }}
    UNION ALL
    SELECT * FROM {{ source('dados_brutos', 'raw_servidores_2020') }}
    UNION ALL
    SELECT * FROM {{ source('dados_brutos', 'raw_servidores_2021') }}
)

SELECT
    csalsematr AS matricula,
    csalseccpf AS cpf,

    UPPER(TRIM(nsalsenome)) AS nome,
    COALESCE(esalsegenero, 'NI') AS genero,
    COALESCE(esalseinstrucao, 'NI') AS grau_instrucao,

    COALESCE(NULLIF(dslderadmissao, '')::DATE, '1900-01-01'::DATE) AS data_admissao,
    NULLIF(dslserdesligamento, '')::DATE AS data_desligamento,
    NULLIF(dsalseaposentadoria, '')::DATE AS data_aposentadoria,

    UPPER(TRIM(eslserlotacao)) AS lotacao_nome,
    COALESCE(NULLIF(UPPER(TRIM(esalseunidade)), ''), 'NI') AS unidade_nome,
    UPPER(TRIM(nsalseempr)) AS entidade_nome,
    esalseadministracao AS tipo_administracao,

    NULLIF(TRIM(REGEXP_REPLACE(UPPER(nsalsecarg), '[.]+$', '')), '') AS cargo_nome,
    UPPER(TRIM(nsalsefunc)) AS funcao_nome,
    UPPER(TRIM(nsalsecate)) AS categoria_nome,
    UPPER(TRIM(eselsesituacao)) AS situacao_nome,

    COALESCE(NULLIF(aslserjornadamensal, '')::DECIMAL, 0) AS jornada_mensal,
{#    NULLIF(tslserulat, '')::TIMESTAMP AS data_atualizacao_sistema,#}

    NULLIF(asalseanoo, '')::INTEGER AS ano_folha,
    NULLIF(asalsemess, '')::INTEGER AS mes_folha,

    COALESCE(NULLIF(vsalseprov, '')::DECIMAL, 0) AS valor_remuneracao_bruta,
    COALESCE(NULLIF(vsalseremu, '')::DECIMAL, 0) AS valor_remuneracao_base,
    COALESCE(NULLIF(vsalsecarg, '')::DECIMAL, 0) AS valor_salario_base,
    COALESCE(NULLIF(vsalsefunc, '')::DECIMAL, 0) AS valor_funcao_gratificada,
    COALESCE(NULLIF(vsalseoutr, '')::DECIMAL, 0) AS valor_outras_remuneracoes,
    COALESCE(NULLIF(vsalseferi, '')::DECIMAL, 0) AS valor_ferias,
    COALESCE(NULLIF(vsalsenatl, '')::DECIMAL, 0) AS valor_13_salario,
    COALESCE(NULLIF(vsalsedife, '')::DECIMAL, 0) AS valor_diferenca_salarial,

    COALESCE(NULLIF(vsalsedrrf, '')::DECIMAL, 0) AS valor_irrf,
    COALESCE(NULLIF(vsalsedprv, '')::DECIMAL, 0) AS valor_previdencia,
    COALESCE(NULLIF(vsalsedtot, '')::DECIMAL, 0) AS valor_descontos_total,
    COALESCE(NULLIF(vsalsedrst, '')::DECIMAL, 0) AS valor_desconto_faltas,
    COALESCE(NULLIF(vsalsedxcd, '')::DECIMAL, 0) AS valor_descontos_diversos,

    COALESCE(NULLIF(vsalseliqd, '')::DECIMAL, 0) AS valor_liquido

FROM unificado