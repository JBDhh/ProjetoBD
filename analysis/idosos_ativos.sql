SELECT
    matricula,
    nome,
    data_aposentadoria,
    cargo_nome,
    (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_admissao)) AS anos_de_casa
FROM servidores_elt.fato_folha f
JOIN servidores_elt.dim_servidor s ON f.id_servidor = s.id_servidor
JOIN servidores_elt.dim_cargo c ON f.id_cargo = c.id_cargo
JOIN servidores_elt.dim_lotacao l ON f.id_lotacao = l.id_lotacao
JOIN servidores_elt.dim_situacao sit ON f.id_situacao = sit.id_situacao
WHERE
    is_ativo
    AND status_integridade_admissao IN ('OK')
    AND data_aposentadoria IS NULL
    AND (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_admissao)) > (75 - 18)
GROUP BY matricula, nome, data_admissao, data_aposentadoria, cargo_nome, data_admissao
ORDER BY anos_de_casa DESC;
