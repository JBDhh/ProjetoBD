WITH comparativo AS (
    SELECT
        nome,
        cargo_nome,
        ano,
        mes,
        valor_remuneracao_bruta AS salario_atual,
        LAG(valor_remuneracao_bruta) OVER (PARTITION BY f.id_servidor ORDER BY t.id_tempo) AS salario_anterior
    FROM servidores_elt.fato_folha f
    JOIN servidores_elt.dim_servidor s ON f.id_servidor = s.id_servidor
    JOIN servidores_elt.dim_cargo c ON f.id_cargo = c.id_cargo
    JOIN servidores_elt.dim_tempo t ON f.id_tempo = t.id_tempo
)

SELECT
    nome,
    cargo_nome,
    ano,
    mes,
    salario_anterior,
    salario_atual,
    ROUND(((salario_atual - salario_anterior) / salario_anterior) * 100, 2) as pct_aumento
FROM comparativo
WHERE salario_anterior > 0
    AND ((salario_atual - salario_anterior) / salario_anterior) > 1.0
ORDER BY salario_atual DESC;