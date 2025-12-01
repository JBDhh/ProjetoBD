# 💉 Pipeline de Dados: Análise Exploratória de Dados dos Servidores da Prefeitura da Cidade do Recife

> **Projeto de Banco de Dados (2025.2) - CIn/UFPE**

Este projeto implementa e compara duas arquiteturas fundamentais de Engenharia de Dados — **ETL Clássico** (Python/Pandas) e **ELT Moderno** (dbt/SQL) — para processar, higienizar e modelar dados públicos de servidores municipais.

O diferencial deste projeto é a implementação final de uma **Modelagem Dimensional (Esquema Estrela)**, transformando milhões de registros brutos em um Data Warehouse otimizado para Business Intelligence (BI).

-----

## 🎯 Objetivo e Desafio

O objetivo foi integrar dados dispersos temporalmente para permitir análises históricas.

* **Fonte:** [Portal de Dados Abertos do Recife](http://dados.recife.pe.gov.br/dataset/servidores)
* **Dados Brutos:** Arquivos CSV separados por ano (2019, 2020, 2021) contendo registros de folha de pagamento.
* **Desafio Principal:** Os dados possuiam inconsistências de formato, colunas "sujas" e ausência de chaves primárias confiáveis.

## 🏗️ Arquitetura da Solução

O projeto constrói o mesmo modelo final através de dois caminhos distintos para fins de comparação:

### 1. Abordagem ETL (Python Driven)

* **Extração:** Leitura automatizada dos CSVs brutos.
* **Transformação:** Limpeza, deduplicação e **modelagem dimensional (Star Schema)** realizadas inteiramente em memória usando **Pandas**.
    * Criação de IDs substitutos (Surrogate Keys).
    * Normalização de tabelas (Cargo, Lotação, Servidor).
* **Carga:** Inserção das tabelas Fato e Dimensão finais no PostgreSQL usando SQLAlchemy.

### 2. Abordagem ELT (Modern Data Stack)

* **Extração & Carga (EL):** Python é usado apenas para carregar os dados brutos (`raw`) no banco.
* **Transformação (T):** O **dbt (data build tool)** orquestra transformações complexas diretamente no banco de dados usando SQL:
    * **Staging:** Unificação dos anos (`UNION ALL`).
    * **Intermediate:** Limpeza pesada (Regex, Split, Case When).
    * **Marts:** Criação das Tabelas Fato e Dimensão.

-----

## ⭐ Modelagem de Dados (Esquema Estrela)

Ao final do pipeline, os dados são organizados no seguinte modelo dimensional:

* **Fato:** `fato_folha` (Granularidade: Servidor/Mês)
* **Dimensões:** `dim_servidor`, `dim_lotacao`, `dim_cargo`, `dim_situacao`, `dim_tempo`.

-----

## 🛠️ Tecnologias Utilizadas

* **Python 3.10+**: Scripting e manipulação de dados (Pandas).
* **PostgreSQL**: Data Warehouse (via Docker).
* **dbt Core**: Orquestração de transformações SQL.
* **SQLAlchemy**: Conectores de banco de dados.
* **Docker & Docker Compose**: Containerização do ambiente.

-----

## 🚀 Como Executar

### Pré-requisitos

1.  Instale Docker e Docker Compose (ou tenha um Postgres local).
2.  Clone este repositório.
3.  Crie um arquivo `.env` na raiz do projeto (copie de `.env.example`):
    ```bash
    cp .env.example .env
    ```
4.  Instale as dependências Python:
    ```bash
    pip install pandas sqlalchemy psycopg2-binary dbt-postgres python-dotenv
    ```

### Passo 1: Subir o Banco de Dados

Utilize o Docker para iniciar o PostgreSQL configurado:
```bash
docker-compose up -d
