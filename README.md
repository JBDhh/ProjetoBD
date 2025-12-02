# 💉 Pipeline de Dados: Análise Exploratória de Dados dos Servidores da Prefeitura da Cidade do Recife

**Projeto de Banco de Dados (2025.2) - CIn/UFPE**

Este projeto implementa e compara duas arquiteturas fundamentais de Engenharia de Dados — **ETL Clássico** (Python/Pandas) e **ELT Moderno** (dbt/SQL) — para processar, higienizar e modelar dados públicos de servidores municipais.

O diferencial deste projeto é a implementação final de uma **Modelagem Dimensional (Esquema Estrela)**, transformando milhões de registros brutos em um Data Warehouse otimizado para Business Intelligence (BI), além de scripts de auditoria de qualidade de dados.

-----

## 🎯 Objetivo e Desafio

O objetivo foi integrar dados dispersos temporalmente para permitir análises históricas.

* **Fonte:** [Portal de Dados Abertos do Recife](http://dados.recife.pe.gov.br/dataset/servidores)
* **Dados Brutos:** Arquivos CSV separados por ano (2019, 2020, 2021) contendo registros de folha de pagamento.
* **Desafio Principal:** Os dados possuiam inconsistências de formato, colunas "sujas" (ex: valores nulos acima de 90%) e ausência de chaves primárias confiáveis.

-----

## 🏗️ Arquitetura da Solução

O projeto constrói o mesmo modelo final através de dois caminhos distintos para fins de comparação:

### 1. Abordagem ETL (Python Driven)

* **Extração:** Leitura automatizada dos CSVs brutos com tratamento de formatação (leitura bruta para correção de aspas).
* **Transformação (Pandas):**
    * Limpeza avançada e tipagem de dados.
    * Deduplicação e tratamento de dimensões (SCD Tipo 1).
    * **Modelagem Dimensional:** Criação de Tabelas Fato e Dimensão em memória.
* **Carga:** Inserção otimizada no PostgreSQL via SQLAlchemy.

### 2. Abordagem ELT (Modern Data Stack)

* **Extração & Carga (EL):** Python é usado apenas para carregar os dados brutos (`raw`) no banco.
* **Transformação (T):** O **dbt (data build tool)** orquestra transformações complexas diretamente no banco de dados:
    * **Staging:** Unificação dos anos e padronização de tipos.
    * **Intermediate:** Regras de negócio e limpeza via SQL.
    * **Marts:** Materialização do Esquema Estrela.

-----

## 📂 Estrutura do Projeto

```
├── analysis/           # Consultas SQL para insights (Outliers, Sazonalidade)
├── checks/             # Scripts SQL de auditoria e validação cruzada
├── data/               # Arquivos CSV (Dados Brutos)
├── models/             # Modelos dbt (Staging e Marts)
├── notebooks/          # Jupyter Notebooks (ETL.ipynb e ELT.ipynb)
├── docker-compose.yml  # Configuração do Banco de Dados (Opcional)
├── requirements.txt    # Dependências do Python
└── dbt_project.yml     # Configuração do dbt
````

-----

## 🚀 Como Executar

### 1\. Preparação do Ambiente Python

Clone o repositório e instale as dependências listadas.

```
# Clone o repositório
# Crie um ambiente virtual (recomendado)
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Instale as dependências
pip install -r requirements.txt
```

### 2\. Configuração do Banco de Dados

Você precisa de um banco de dados PostgreSQL rodando. Escolha uma das opções abaixo:

#### Opção A: Usando Docker

Se você tem Docker instalado, basta rodar o comando abaixo para subir um banco configurado automaticamente:

```
docker-compose up -d
```

#### Opção B: Usando um Banco Local existente

Se você já tem o PostgreSQL instalado na sua máquina:

1.  Crie um banco de dados vazio (ex: `servidores_recife`).
2.  Garanta que as credenciais no arquivo `.env` apontem para o seu banco local.

### 3\. Configuração de Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto baseando-se no exemplo:

```
cp .env.example .env
```

Edite o arquivo `.env` e ajuste as credenciais (`POSTGRES_USER`, `POSTGRES_PASSWORD`, etc.) conforme a opção de banco escolhida acima.

-----

## 📓 Executando os Notebooks

Os processos de ingestão e tratamento estão documentados em **Jupyter Notebooks** na pasta `notebooks/`.

### Execução Local (VS Code ou Jupyter Lab)

Basta abrir os arquivos `ETL.ipynb` ou `ELT.ipynb` e executar as células sequencialmente. O Kernel do Python deve estar utilizando o ambiente virtual onde as dependências foram instaladas.

### ⚠️ Execução no Google Colab

Se você optar por rodar no Google Colab:

1.  **Dependências:** O arquivo `requirements.txt` não é lido automaticamente. Você deve executar o seguinte comando na primeira célula:
    ```
    !pip install pandas sqlalchemy psycopg2-binary dbt-postgres python-dotenv
    ```
2.  **Arquivos:** Você precisará fazer o upload manual da pasta `data/` (com os CSVs) e do arquivo `.env` para o ambiente de execução do Colab.
3.  **Conexão:** Certifique-se de que o Colab consiga acessar seu banco de dados (se o banco for local, você precisará usar um túnel como o *ngrok* ou migrar o banco para a nuvem, como AWS RDS ou Supabase).

-----

## 🏃 Executando o Pipeline Completo (dbt)

Após rodar a carga inicial via notebooks, você pode gerenciar as transformações ELT via CLI do dbt:

```
# Executar todas as transformações (Criação de Tabelas/Views)
dbt run
```

-----

## 🔎 Análises Disponíveis

Após a execução, você pode rodar as consultas SQL disponíveis na pasta `analysis/` diretamente no seu cliente de banco de dados (DBeaver, pgAdmin) para gerar insights:

  * **`salario_acima_media.sql`**: Detecta salários discrepantes (Z-Score \> 3).
  * **`variacao_salario.sql`**: Analisa aumentos bruscos (\>100%) de um mês para o outro.
  * **`idosos_ativos.sql`**: Identifica servidores com tempo de casa excessivo sem aposentadoria.

-----

## 🛠️ Tecnologias

  * **Linguagem:** Python 3.10+
  * **Banco de Dados:** PostgreSQL 15
  * **Engenharia de Dados:** Pandas, SQLAlchemy, dbt
  * **Infraestrutura:** Docker (Opcional)