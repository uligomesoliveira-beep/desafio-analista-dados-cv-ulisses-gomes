# Desafio EMPM - Ulisses Gomes - Orientações para Verificação dos Resultados

Este repositório reúne as consultas, scripts e análises desenvolvidos para a etapa prática do processo seletivo.  
A análise foi realizada combinando **SQL (BigQuery)** para extração e agregação dos dados, **Python (Pandas)** para tratamento e validação das métricas, e **Power BI** para visualização dos resultados.

### Primeiro passo

Faça um pull (ou clone) deste repositório para a sua máquina local

## Estrutura do Repositório

# SQL e Big Query
- As respostas das perguntas 1 a 10 do arquivo [text](perguntas_sql.md) estão na pasta ['analise_sql.sql"](analise_sql.sql)
Para acessar;
- Para rodar as consultas, você deve acessar o Google Cloud Console e ir para o Big Query;
- Após abrir o arquivo ['analise_sql.sql"](analise_sql.sql) voce deve copiar e colar pergunta a pergunta no painel de consultas, certificando-se de que não irá colar uma ou mais perguntas
Ex:
#PERGUNTA 1: Quantos chamados foram abertos no dia 01/04/2023?
--Objetivo da consulta: utilizar o operador COUNT(*) para contar os chamados com o filtro WHERE para a data em questão.
SELECT 
    COUNT(*)AS total_chamados_abertos
FROM 
    `datario.adm_central_atendimento_1746.chamado`
WHERE 
DATE(data_inicio) = '2023-04-01'; 

/*Optei por utilizar o operador WHERE em conjunto com DATE 
ao invés do operador LIKE para deixar a consulta mais limpa, 
visto que a coluna 'data_inicio' da tabela registra tanto data quanto a hora dos chamados*/

--Resultado: foram registrados 2067 chamados em 01/04/2023

# Python
- As respostas das perguntas 1 a 10 do arquivo [text](perguntas_sql.md) estão na pasta [text](analise_python.ipynb)
- As respostas das perguntas 1 a 8 do arquivo [text](perguntas_api.md) estão na pasta [text](analise_api.ipynb)
- Com os arquivos [text](analise_python.ipynb) e [text](analise_api.ipynb) execute-os em ordem sequencial, da primeira a ultima pergunta.

# Power Bi
- A visualização dos dados pode ser verificada por meio deste link: https://app.powerbi.com/view?r=eyJrIjoiOWM3NjY1ZjQtYjZhNy00ZTY2LThlMmQtOGY3YTVlZWFiZWQ3IiwidCI6ImY0ZDJjMGYxLTYxMGUtNDQ1YS1hODA3LTY1MWQ4Y2Q3ZGFlMiJ9
