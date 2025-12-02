# Relatório: Pipeline de Dados de Servidores Públicos (ETL e ELT)

Este relatório descreve o projeto de integração de dados de servidores públicos da Prefeitura do Recife. O projeto implementou e comparou as abordagens **ETL (Python/Pandas)** e **ELT (dbt/SQL)** para construir um **Data Warehouse em Esquema Estrela**.

***

## 1. Justificativa da Escolha da Base de Dados

A escolha do conjunto de dados de **Servidores da Administração Direta e Indireta da Prefeitura do Recife** (2019-2021) foi motivada por critérios técnicos que favorecem o aprendizado das técnicas de Engenharia de Dados propostas pela disciplina:

1.  **Desafio de Integração e Limpeza (Data Quality):** Diferente de datasets pré-processados, os dados brutos governamentais apresentavam desafios reais de ingestão, como formatação de CSV corrompida (uso incorreto de aspas), tipagem inconsistente e codificação de colunas legadas. Essas características tornaram a base ideal para demonstrar a robustez dos scripts de tratamento em Python e SQL.
2.  **Adequação à Modelagem Dimensional:** A natureza dos dados de folha de pagamento favorece naturalmente a construção de um Esquema Estrela. A existência de entidades claras (Servidores, Cargos, Lotações) e eventos transacionais periódicos (pagamentos mensais) permitiu a criação de um Data Warehouse completo, possibilitando a análise comparativa entre as abordagens ETL e ELT.
3.  **Volume e Temporalidade:** Com cerca de 1,4 milhão de registros distribuídos ao longo de três anos, o volume de dados foi suficiente para testar a performance de carga e permitir análises de séries temporais (sazonalidade de pagamentos), sem inviabilizar o processamento em ambiente acadêmico local.
4.  **Transparência e Interesse Público:** Sendo dados reais e abertos, o projeto ganha relevância ao permitir auditorias cidadãs, como a identificação de discrepâncias salariais e análise de quadros funcionais, simulando um cenário real de Business Intelligence governamental.

***

## 2. Descrição da Modelagem Dimensional (Esquema Estrela)

O Data Warehouse foi estruturado utilizando a metodologia de **Modelagem Dimensional (Esquema Estrela)**. Esta arquitetura foi escolhida para facilitar consultas analíticas, agregação de valores financeiros e performance em ferramentas de BI.

O modelo é composto por uma tabela central de fatos (`fato_folha`), que armazena as métricas quantitativas (valores de pagamentos e descontos), circundada por cinco tabelas de dimensão que fornecem o contexto descritivo (quem, onde, quando, qual cargo e qual situação).

### Diagrama Lógico Simplificado
* **Fato:** `fato_folha` (Granularidade: Vínculo do Servidor por Mês de Referência)
* **Dimensões:**
    * `dim_servidor`: Dados do vínculo contratual e perfil do servidor.
    * `dim_lotacao`: Estrutura organizacional (Secretaria, Departamento, Entidade).
    * `dim_cargo`: Detalhes da função e categoria profissional.
    * `dim_situacao`: Status funcional (Ativo, Aposentado, Exonerado).
    * `dim_tempo`: Calendário fiscal (Ano, Mês, Trimestre).

---

## 3. Dicionário de Dados

Abaixo apresenta-se a descrição técnica dos atributos disponíveis na base de dados analítica.

### 3.1. Tabela Fato: `fato_folha`
Contém os registros financeiros processados da folha de pagamento. Cada linha representa o contracheque de um vínculo em um determinado mês.

| Coluna | Tipo | Descrição | Origem/Transformação |
| :--- | :--- | :--- | :--- |
| **`id_servidor`** | FK | Chave estrangeira para a dimensão Servidor. | `dim_servidor` |
| **`id_cargo`** | FK | Chave estrangeira para a dimensão Cargo. | `dim_cargo` |
| **`id_lotacao`** | FK | Chave estrangeira para a dimensão Lotação. | `dim_lotacao` |
| **`id_situacao`** | FK | Chave estrangeira para a dimensão Situação. | `dim_situacao` |
| **`id_tempo`** | FK | Chave estrangeira para a dimensão Tempo (Formato YYYYMM). | `dim_tempo` |
| `jornada_mensal` | Decimal | Quantidade de horas da jornada mensal de trabalho. | Bruto: `aslserjornadamensal` |
| `valor_remuneracao_bruta` | Decimal | Valor total dos proventos (Ganhos) antes dos descontos. Utilizado para cálculo de médias salariais. | Bruto: `vsalseprov` (Validado como o campo correto para bruto) |
| `valor_salario_base` | Decimal | Salário base do cargo, sem gratificações. | Bruto: `vsalsecarg` |
| `valor_liquido` | Decimal | Valor efetivamente recebido (Bruto - Descontos). | Bruto: `vsalseliqd` |
| `valor_ferias` | Decimal | Pagamentos referentes a férias. | Bruto: `vsalseferi` |
| `valor_13_salario` | Decimal | Pagamentos referentes ao décimo terceiro. | Bruto: `vsalsenatl` |
| `valor_irrf` | Decimal | Valor retido para Imposto de Renda. | Bruto: `vsalsedrrf` |
| `valor_previdencia` | Decimal | Valor retido para Previdência. | Bruto: `vsalsedprv` |
| `valor_descontos_total` | Decimal | Soma de todos os descontos aplicados. | Bruto: `vsalsedtot` |
| `status_integridade_admissao`| String | **Campo de Auditoria**. Indica se a data de admissão é válida. Valores: `DATA_NULA` (origem vazia), `ADMISSAO_FUTURA` (inconsistência) ou `OK`. | Regra de Negócio SQL |

### 3.2. Dimensão: `dim_servidor`
Armazena os dados cadastrais do vínculo do servidor. Devido à não unicidade da matrícula entre entidades, esta dimensão reflete o **vínculo** e não necessariamente a pessoa física única.

| Coluna | Tipo | Descrição |
| :--- | :--- | :--- |
| **`id_servidor`** | PK | Chave substituta (Surrogate Key) única para o vínculo. |
| `matricula` | String | Código de matrícula no sistema de origem. **Nota:** Pode se repetir entre entidades diferentes. |
| `cpf` | String | CPF do servidor (parcialmente mascarado na fonte). |
| `nome` | String | Nome completo do servidor (Normalizado em maiúsculas). |
| `entidade_nome` | String | Nome da entidade pública contratante (ex: Prefeitura, Autarquias). Essencial para diferenciar matrículas iguais. |
| `genero` | String | Gênero do servidor. |
| `grau_instrucao` | String | Nível de escolaridade. |
| `data_admissao` | Date | Data de início do vínculo. Se houver recontratação, considera a data mais antiga (`MIN`). |
| `data_desligamento` | Date | Data de encerramento do vínculo. |

### 3.3. Dimensão: `dim_cargo`
Normaliza os cargos, funções e categorias profissionais.

| Coluna | Tipo | Descrição |
| :--- | :--- | :--- |
| **`id_cargo`** | PK | Chave substituta para o cargo. |
| `cargo_nome` | String | Nome oficial do cargo (ex: PROFESSOR, ANALISTA). Normalizado com remoção de pontuação final. |
| `funcao_nome` | String | Função exercida (pode diferir do cargo em casos de confiança). |
| `categoria_nome` | String | Categoria do cargo (ex: ESTATUTARIO, COMISSIONADO). |

### 3.4. Dimensão: `dim_lotacao`
Representa a hierarquia organizacional onde o servidor está alocado.

| Coluna | Tipo | Descrição |
| :--- | :--- | :--- |
| **`id_lotacao`** | PK | Chave substituta para a lotação. |
| `lotacao_nome` | String | Local específico de trabalho (ex: ESCOLA MUNICIPAL X). |
| `unidade_nome` | String | Unidade administrativa superior (ex: SECRETARIA DE EDUCACAO). |
| `entidade_nome` | String | Entidade jurídica da administração pública. |
| `tipo_administracao` | String | Classificação da entidade (Direta ou Indireta). |

### 3.5. Dimensão: `dim_situacao`
Define o estado funcional do servidor na folha.

| Coluna | Tipo | Descrição |
| :--- | :--- | :--- |
| **`id_situacao`** | PK | Chave substituta para a situação. |
| `situacao_nome` | String | Descrição original (ex: ATIVO, APOSENTADO, LICENCA). |
| `is_ativo` | Boolean | **Campo Calculado**. Retorna `TRUE` para servidores ativos e `FALSE` para desligados ou aposentados. Usado para filtros rápidos de pessoal ativo. |

### 3.6. Dimensão: `dim_tempo`
Tabela auxiliar para navegação temporal nos relatórios.

| Coluna | Tipo | Descrição |
| :--- | :--- | :--- |
| **`id_tempo`** | PK | Inteiro no formato `AAAAMM` (ex: 202101). Facilita ordenação e joins. |
| `ano` | Int | Ano da folha. |
| `mes` | Int | Mês numérico (1-12). |
| `nome_mes` | String | Nome do mês por extenso (Janeiro, Fevereiro...). |
| `trimestre` | Int | Trimestre do ano (1-4). |
| `semestre` | Int | Semestre do ano (1-2). |

***

## 4. Descrição dos Processos de Transformação Aplicados

Para garantir a consistência e qualidade dos dados, foram aplicadas transformações em diferentes níveis do pipeline. Abaixo detalham-se as técnicas utilizadas para sanear a base bruta e estruturar o modelo dimensional.

### 4.1. Tratamento de Formatação
A primeira e mais crítica transformação ocorreu na etapa de ingestão. Os arquivos CSV originais apresentavam uso inconsistente de aspas duplas (`"`), o que quebrava a estrutura de colunas nos parsers tradicionais.
* **Técnica Aplicada:** Implementou-se uma estratégia de "Leitura Bruta" em Python. O interpretador de aspas foi desativado (`quoting=csv.QUOTE_NONE`), carregando o arquivo integralmente como texto. Em seguida, as aspas residuais foram removidas das bordas das colunas via manipulação de *string*, garantindo a recuperação de 100% das linhas sem deslocamento de dados.

### 4.2. Padronização e Tipagem de Dados
Após a correção estrutural, os dados foram tipados e padronizados:
* **Conversão de Tipos:** Colunas originalmente texto foram convertidas para `DECIMAL` (valores financeiros), `INTEGER` (ano/mês) e `DATE` (admissão/desligamento). No fluxo ELT, isso foi realizado via SQL (`CAST` e `::DATE`) na camada de *staging*.
* **Tratamento de Nulos:**
    * **Dados Categóricos:** Campos como `Gênero` e `Grau de Instrução` receberam o valor padronizado `'NI'` (Não Informado).
    * **Datas Críticas:** Para a data de admissão, registros vazios (erros de cadastro) foram imputados com `'1900-01-01'`. Já para datas de desligamento, manteve-se o valor `NULL` para preservar a semântica de "Servidor Ativo".

### 4.3. Normalização de Texto e Categorias
Para corrigir a divergência semântica nos cadastros (e.g., variações de "VIGIA" e "VIGILANTE"), aplicaram-se funções de limpeza:
* **Funções de String:** Aplicação de `TRIM` (remoção de espaços), `UPPER` (padronização em maiúsculas) e remoção de pontuações finais em nomes de cargos e departamentos.

### 4.4. Criação de Chaves Substitutas
Para o Esquema Estrela, não se utilizou os identificadores originais do sistema legado. Foram geradas novas chaves primárias numéricas sequenciais (`id_servidor`, `id_cargo`, `id_lotacao`) utilizando a função de janela `ROW_NUMBER()`, garantindo unicidade e independência do sistema de origem.

### 4.5. Validação da Remuneração Bruta

A base de dados apresentava ambiguidade entre duas colunas candidatas a representar o salário bruto: `vsalseprov` e `vsalseremu`.
Para resolver essa incerteza, foram desenvolvidos scripts exploratórios em SQL (`checks/remu_vs_prov.sql` e `checks/prov_10cents.sql`) que testaram a consistência contábil de cada coluna. Aplicou-se a fórmula fundamental `Líquido + Descontos = Bruto` em uma amostra aleatória dos dados.
* **Resultado:** A coluna `vsalseprov` apresentou consistência matemática em 100% dos casos testados, enquanto `vsalseremu` apresentava discrepâncias. Essa validação analítica definiu a regra de negócio final para o mapeamento da tabela Fato.

***

## 5. Comparativo entre ETL e ELT

O projeto implementou dois pipelines distintos para atingir o mesmo Data Warehouse, permitindo uma comparação técnica direta entre as abordagens.

### 5.1. Arquitetura e Fluxo de Dados

| Característica | Abordagem ETL (Python) | Abordagem ELT (dbt/SQL) |
| :--- | :--- | :--- |
| **Ordem de Processamento** | **Extract $\rightarrow$ Transform $\rightarrow$ Load** | **Extract $\rightarrow$ Load $\rightarrow$ Transform** |
| **Local da Transformação** | Memória RAM (Processamento no Python/Pandas). | Motor do Banco de Dados (Processamento no PostgreSQL). |
| **Ingestão (Loader)** | O script Python limpa, tipa e estrutura os dados *antes* de inserir no banco. | O script Python (`ELT.ipynb`) apenas carrega os dados "sujos" (raw) para tabelas de *staging* no banco. |
| **Lógica de Negócio** | Código Imperativo (Loops, Funções Pandas). | Código Declarativo (SQL `SELECT`, `CASE WHEN`, `JOIN`). |

### 5.2. Vantagens e Desvantagens Observadas

**ETL (Python/Pandas):**
* **Vantagens:** Flexibilidade extrema para tratamentos complexos de *string* linha a linha (como a remoção de aspas residuais) antes mesmo do dado entrar no banco.
* **Desvantagens:** O processamento ocorre em memória. Se o volume de dados crescer além da RAM disponível, o pipeline falha ou exige hardware mais robusto. A lógica de negócio fica "escondida" dentro do script Python.

**ELT (dbt/SQL):**
* **Vantagens:** Alta performance para agregações e *joins*, pois utiliza o motor otimizado do Banco de Dados. A separação em camadas (`staging` $\rightarrow$ `marts`) via modelos SQL facilita a auditoria, o versionamento e a linhagem dos dados.
* **Desvantagens:** Exige que os dados brutos sejam carregados no banco mesmo com problemas. No projeto, o tratamento de aspas ainda precisou ser feito via Python antes do Load.

### 5.3. Adequação ao Projeto
A abordagem **ELT com dbt** mostrou-se mais adequada para a evolução do projeto. Embora o Python tenha sido indispensável para a correção inicial do arquivo físico (extração), delegar a modelagem dimensional (criação de fatos e dimensões) para o SQL/dbt trouxe maior transparência às regras de negócio e facilitou a manutenção do dicionário de dados.

### 5.4. Validação Cruzada

Para garantir que ambas as abordagens (ETL e ELT) produzissem resultados idênticos não apenas em volume, mas em conteúdo, foi implementada uma bateria de testes automatizados via SQL:

* **Validação Volumétrica (`checks/linhas.sql`):** Comparação da contagem total de registros (`COUNT(*)`) em todas as tabelas dimensão e fato dos dois schemas (`servidores_etl` vs `servidores_elt`). O resultado apontou divergência zero.
* **Validação de Integridade de Dimensões (`checks/servidores.sql` e `checks/cargos.sql`):** Utilização do operador `EXCEPT` para identificar se existia alguma linha (servidor ou cargo) presente em uma abordagem e ausente na outra. O retorno vazio confirmou que a lógica de limpeza e deduplicação foi reproduzida com exatidão nas duas linguagens (Python e SQL).
* **Validação Financeira Agregada (`checks/fato.sql`):** Cruzamento dos valores totais de remuneração bruta agrupados por ano e mês. A diferença aritmética (`p.total_bruto - d.total_bruto`) foi calculada para cada período.

***

## 6. Análises e Insights

### Análise 1: Detecção de Outliers Salariais Extremos

A consulta `analysis/salario_acima_media.sql` identifica valores de remuneração bruta que estão **acima de 3 desvios-padrão** da média do cargo (Z-score > 3).

**Insight:**

Foi detectado um registro de pagamento de **R\$ 365.270,60** para um servidor de cargo ordinário que, em meses anteriores, recebia cerca de R\$ 3.000. Este valor extremo é um provável **erro de digitação** (falta de vírgula/ponto decimal), o qual distorce a média salarial do órgão no mês, mas a presença de 11.779 registros com valores anômalos sugere a necessidade de uma análise mais aprofundada para entender se tais valores decorrem de pagamentos retroativos, indenizações, cargos comissionados, verbas eventuais ou inconsistências nos dados originais.

### Análise 2: Análise de Sazonalidade (Variação Brusca de Salário)

A consulta `analysis/variacao_salario.sql` usa a função `LAG` para comparar o salário de um mês com o anterior, buscando aumentos superiores a 100%.

**Insight:**

O padrão recorrente de picos de 200% ou mais no **Mês 4 (Abril)** para categorias específicas indica **sazonalidade legítima**. A hipótese é o pagamento fixo de verbas anuais, como 1/3 de férias e/ou bônus de desempenho, sendo este um padrão de negócio, e não um erro de processamento.

### Análise 3: Servidores com Maior Tempo de Casa (Idosos Ativos)

A consulta `analysis/idosos_ativos.sql` busca servidores ativos que não possuem data de aposentadoria e cujo tempo de casa é superior a **57 anos** (75 anos de idade - 18 anos de admissão).

**Insight:**

Apenas 2 servidores foram identificados nesse grupo de "idosos ativos". O tempo de serviço foi usado como um *proxy* para idade avançada, mas a falta da **data de nascimento** no dataset impede uma análise mais precisa da elegibilidade real para aposentadoria. O resultado indica um baixo número de casos extremos, sugerindo que o ciclo de vida dos servidores está relativamente bem registrado.

### Análise 4: Tentativa de Identificação de Acúmulo de Cargos

Tentativa de cruzar dados para identificar servidores com múltiplos vínculos ativos simultaneamente (acumulação de cargos).

**Insight:**

Esta análise foi descontinuada devido à inviabilidade técnica de garantir a identidade única do servidor (falta de CPF completo e repetição de matrículas entre entidades). Além disso, a **divergência semântica** nos nomes dos cargos (e.g., variações como "VIGIA" e "VIGILANTE") impediu uma normalização confiável. Sem uma chave única de pessoa física e sem uma padronização rigorosa dos títulos, qualquer apontamento de acúmulo de cargos conteria alto risco de "falsos positivos", comprometendo a credibilidade do relatório.

***

## 7. Reflexão sobre o Aprendizado

A execução deste projeto proporcionou uma visão prática dos desafios reais de Engenharia de Dados, indo além da teoria de construção de pipelines. As principais lições aprendidas e desafios superados foram:

### 7.1. O Impacto da Qualidade dos Dados na Arquitetura
Um dos maiores aprendizados foi constatar que **não existe pipeline robusto sem uma estratégia de ingestão defensiva**.
* **Desafio Superado:** O bloqueio técnico inicial com a formatação do arquivo CSV (uso inconsistente de aspas) ensinou que ferramentas de alto nível (como o parser padrão do Pandas) nem sempre funcionam "out-of-the-box" com dados legados governamentais.
* **Lição:** Foi necessário descer ao nível de manipulação de *string* (Leitura Bruta) para recuperar os dados. Isso reforçou que a etapa de **Exploração e Limpeza** consome a maior parte do esforço do projeto, sendo determinante para o sucesso das etapas seguintes.

### 7.2. Modelagem Orientada à Realidade vs. Ideal Teórico
Durante a modelagem dimensional, houve um conflito entre o desejo de criar uma dimensão "Pessoa" única e a realidade dos dados disponíveis.
* **Desafio Superado:** A descoberta de que a matrícula não é um identificador único global (repetindo-se entre entidades) e a ausência de um CPF completo impediram a criação de uma chave única confiável para indivíduos.
* **Lição:** Aprendemos a priorizar a **Rastreabilidade Fiscal** em detrimento da deduplicação agressiva. A decisão de modelar a granularidade no nível do **Vínculo (Contrato)**, e não da Pessoa, garantiu que o Data Warehouse refletisse fielmente a folha de pagamento para fins de auditoria, evitando o risco de agrupar pessoas diferentes sob o mesmo ID (falsos positivos).

### 7.3. Maturidade na Escolha entre ETL e ELT
A implementação paralela das duas abordagens esclareceu na prática onde cada uma brilha.
* **Lição:** O Python (ETL) provou-se insubstituível para resolver problemas físicos do arquivo (correção de *encoding* e aspas). Porém, para a lógica de negócio (regras de *joins*, agregações e criação de tabelas fato), a abordagem ELT com **dbt** mostrou-se superior. Centralizar as regras em SQL versionado, rodando dentro do banco, oferece muito mais transparência, facilidade de teste e governança do que scripts Python imperativos complexos.

### 7.4. A Complexidade Semântica
Por fim, lidamos com a "divergência semântica", onde o mesmo cargo recebia nomes diferentes ao longo dos anos (e.g., "VIGIA" vs "VIGILANTE"). Isso ensinou que a normalização de dados não é apenas um processo técnico (`TRIM`/`UPPER`), mas exige conhecimento profundo do domínio para decidir quando agrupar ou manter termos separados, impactando diretamente a qualidade de análises futuras sobre evolução de carreira.