SELECT 'dim_cargo' as tabela,
       (SELECT COUNT(*) FROM servidores_etl.dim_cargo) as qtd_python,
       (SELECT COUNT(*) FROM servidores_elt.dim_cargo) as qtd_dbt
UNION ALL
SELECT 'dim_servidor',
       (SELECT COUNT(*) FROM servidores_etl.dim_servidor),
       (SELECT COUNT(*) FROM servidores_elt.dim_servidor)
UNION ALL
SELECT 'dim_lotacao',
       (SELECT COUNT(*) FROM servidores_etl.dim_lotacao),
       (SELECT COUNT(*) FROM servidores_elt.dim_lotacao)
UNION ALL
SELECT 'fato_folha',
       (SELECT COUNT(*) FROM servidores_etl.fato_folha),
       (SELECT COUNT(*) FROM servidores_elt.fato_folha);