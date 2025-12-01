SELECT cargo_nome, funcao_nome, categoria_nome
FROM servidores_etl.dim_cargo
EXCEPT
SELECT cargo_nome, funcao_nome, categoria_nome
FROM servidores_elt.dim_cargo;