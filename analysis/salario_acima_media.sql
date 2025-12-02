WITH estatisticas_cargo AS (
    SELECT
        id_cargo,
        AVG(valor_remuneracao_bruta) as media_salarial,
        STDDEV(valor_remuneracao_bruta) as desvio_padrao
    FROM servidores_elt.fato_folha
    WHERE valor_remuneracao_bruta > 0
    GROUP BY id_cargo
),
anomalias_detectadas AS (
    SELECT
        s.id_servidor,
        nome,
        cargo_nome,
        valor_remuneracao_bruta,
        media_salarial,
        ROUND(((f.valor_remuneracao_bruta - media_salarial) / NULLIF(desvio_padrao, 0)), 2) as z_score
    FROM servidores_elt.fato_folha f
    JOIN servidores_elt.dim_servidor s ON f.id_servidor = s.id_servidor
    JOIN servidores_elt.dim_cargo c ON f.id_cargo = c.id_cargo
    JOIN estatisticas_cargo e ON f.id_cargo = e.id_cargo
    WHERE desvio_padrao > 0
        AND valor_remuneracao_bruta > (media_salarial + (3 * desvio_padrao))
        AND (valor_remuneracao_bruta - media_salarial) > 2000
),
casos_unicos AS (
    SELECT DISTINCT ON (nome)
        nome,
        cargo_nome,
        valor_remuneracao_bruta as maior_salario_encontrado,
        media_salarial as media_do_cargo,
        z_score
    FROM anomalias_detectadas
    ORDER BY nome, z_score DESC
)
SELECT * FROM casos_unicos
ORDER BY z_score DESC;