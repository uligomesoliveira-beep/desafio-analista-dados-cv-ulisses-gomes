#Arquivo criado para hospedar os códigos e respostas das perguntas 1 a 10 do arquivo "perguntas_sql.md" em Python.
#Primeiro passo: importação das bases de dados do GCP.
import basedosdados as bd
import pandas as pd

PROJECT_ID = "desafio-empm-ulisses-gomes" 

print("Baixando dados do GCP")

# Baixando as tabelas 'dados_mestres_bairro' e 'turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos'.
df_bairros = bd.read_sql("SELECT * FROM `datario.dados_mestres.bairro`", billing_project_id=PROJECT_ID)
df_eventos = bd.read_sql("SELECT * FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`", billing_project_id=PROJECT_ID)

#Baixando a tabela 'adm_central_atendimento_1746.chamado' com o filtros para não exceder a cota de consultas.
#Para as perguntas de 1 a 5, baixamos apenas os chamados do dia 01/04/2023
query_p1 = "SELECT * FROM `datario.adm_central_atendimento_1746.chamado` WHERE DATE(data_inicio) = '2023-04-01'"
df_chamados_p1 = bd.read_sql(query_p1, billing_project_id=PROJECT_ID)
#Para as perguntas 6 a 10, baixamos apenas os chamados de Perturbação do Sossego entre 2022 e 2024.
query_p2 = """
SELECT * FROM `datario.adm_central_atendimento_1746.chamado` 
WHERE id_subtipo = '5071' AND DATE(data_inicio) BETWEEN '2022-01-01' AND '2024-12-31'
"""
df_chamados_p2 = bd.read_sql(query_p2, billing_project_id=PROJECT_ID)

#Transformando as colunas de datas para o formato 'datetime.date' do pandas.
df_chamados_p2['data_inicio'] = pd.to_datetime(df_chamados_p2['data_inicio']).dt.date
df_eventos['data_inicial'] = pd.to_datetime(df_eventos['data_inicial']).dt.date
df_eventos['data_final'] = pd.to_datetime(df_eventos['data_final']).dt.date

print("Bases carregadas")