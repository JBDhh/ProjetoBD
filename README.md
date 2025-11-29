# ProjetoBD# 💉 Pipeline de Dados: Análise Exploratória de Dados dos Servidores da Prefeitura da Cidade do Recife

> **Projeto de Banco de Dados (2025.2) - CIn/UFPE**



Este projeto implementa e compara duas arquiteturas fundamentais de Engenharia de Dados — **ETL Clássico** (Python/Pandas) e **ELT Moderno** (dbt/SQL) — para processar, higienizar e modelar dados públicos de vacinação.

O diferencial deste projeto é a implementação final de uma **Modelagem Dimensional (Esquema Estrela)** , transformando milhões de registros brutos em um Data Warehouse otimizado para Business Intelligence (BI).

-----

## 🎯 Objetivo e Desafio

O objetivo foi integrar dados dispersos temporalmente para permitir análises históricas.

  * **Fonte:** [Portal de Dados Abertos do Recife](http://dados.recife.pe.gov.br/dataset/servidores)
  * **Dados Brutos:** Arquivos CSV separados por ano (2022, 2023, 2024) contendo registros de vacinação.
  * **Desafio Principal:** Os dados possuiam inconsistências de formato, colunas "sujas" (misturando múltiplos dados em uma string) e ausência de chaves primárias confiáveis.

## 🏗️ Arquitetura da Solução

O projeto constrói o mesmo modelo final através de dois caminhos distintos para fins de comparação:

### 1\. Abordagem ETL (Python Driven)

  * **Extração:** Leitura automatizada dos CSVs.
  * **Transformação:** Limpeza, deduplicação e modelagem dimensional realizadas inteiramente em memória usando **Pandas**.
  * **Carga:** Inserção das tabelas finais no PostgreSQL usando SQLAlchemy.

### 2\. Abordagem ELT (Modern Data Stack)

  * **Extração & Carga (EL):** Python é usado apenas para carregar os dados brutos (`raw`) no banco.
  * **Transformação (T):** O **dbt (data build tool)** orquestra transformações complexas diretamente no banco de dados usando SQL:
      * **Staging:** Unificação dos anos (`UNION ALL`).
      * **Intermediate:** Limpeza pesada (Regex, Split, Case When).
      * **Marts:** Criação das Tabelas Fato e Dimensão.

-----

## ⭐ Modelagem de Dados (Esquema Estrela)

Ao final do pipeline, os dados são organizados em um modelo dimensional para facilitar análises:


-----

## 🛠️ Tecnologias Utilizadas

  *  **Python 3.10+**: Scripting e manipulação de dados (Pandas).
  *  **PostgreSQL**: Data Warehouse.
  *  **dbt Core**: Orquestração de transformações SQL e testes de dados.
  * **SQLAlchemy & Psycopg2**: Conectores de banco de dados.
  * **Git/GitHub**: Versionamento de código.

-----

## 📂 Estrutura do Repositório

```
.
├── analysis/                     # Scripts SQL com as análises finais (Insights)
├── data/                         # Arquivos CSV brutos (ignorados no git)
├── notebooks/
│   ├── ETL.ipynb                 # Pipeline 1: ETL completo em Python
│   └── ELT_load.ipynb            # Pipeline 2: Carga bruta para o dbt
└── README.md
```

-----

## 🚀 Como Executar

### Pré-requisitos

1.  Instale Python e PostgreSQL.
2.  Clone este repositório.
3.  Instale as dependências: `pip install pandas sqlalchemy psycopg2-binary dbt-postgres`.

### Passo 1: Carga Inicial (EL)

Execute o notebook `notebooks/ELT_load.ipynb`. Isso lerá os CSVs da pasta `data/` e criará as tabelas `raw_Servidores` no seu banco de dados.

### Passo 2: Configuração do dbt

1.  Configure seu arquivo `profiles.yml` (geralmente em `~/.dbt/`) com as credenciais do seu PostgreSQL local.
2.  No terminal, navegue até a pasta do projeto dbt:
    ```bash
    cd transformacao_vacinados
    ```
3.  Teste a conexão:
    ```bash
    dbt debug
    ```

### Passo 3: Execução das Transformações

Ainda no terminal, execute o comando para construir o Data Warehouse:

```bash
dbt run
```

*Isso criará todas as views de staging e as tabelas Fato e Dimensão finais.*

-----

## 📊 Resultados e Insights

As consultas SQL na pasta `/analysis` demonstram o poder do modelo construído:



>**Alunos:**
> Denilson
> Janderson
> Jean
> Leonardo
> Lucas Matheus
> Luiz Miguel