SELECT matricula, cpf, entidade_nome
FROM servidores_etl.dim_servidor
EXCEPT
SELECT matricula, cpf, entidade_nome
FROM servidores_elt.dim_servidor;