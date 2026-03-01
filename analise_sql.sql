#Arquivo criado para hospedar os códigos e respostas das perguntas 1 a 10 do arquivo "perguntas_sql.md" em SQL.
  
*/Para conseguir visualizar a estrutura das tabelas do desafio, adotou-se como primeiro passo
a fixação da base de dados 'datario' ao painel lateral no BigQuery para visualizar a disposição das tabelas requisitadas.
Essa abordagem foi considerada mais adequada do que a utilização de consultas com o operador LIMIT pois assim não consumiria a cota gratuita*/

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
  
#PERGUNTA 2: Qual o tipo de chamado que teve mais teve chamados abertos no dia 01/04/2023?
  -- Objetivo da consulta: contar os registros filtrados pela data e ordenar de forma decrescente por tipo de chamado (GROUP BY e ORDER BY), exibindo apenas o mais registrado.--
SELECT 
    tipo, 
    COUNT(*) AS quantidade
FROM 
    `datario.adm_central_atendimento_1746.chamado`
WHERE 
    DATE(data_inicio) = '2023-04-01'
GROUP BY 
    tipo
ORDER BY 
    quantidade DESC LIMIT 1;
--Resposta: o chamado mais registrado foi o de "estacionamento irregular"

#PERGUNTA 3: Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?
/*Objetivo da consulta: Relacionar as duas tabelas (atendimento-1746.chamado e dados_mestres.bairro) via JOIN a partir da coluna 'id_bairro' 
  para contabilizar os chamados do dia por bairro (quando informado) e retornar os três bairros com maior número de registros/*
SELECT 
    b.nome AS nome_bairro, 
    COUNT(*) AS quantidade
FROM 
    `datario.adm_central_atendimento_1746.chamado` AS c
LEFT JOIN 
    `datario.dados_mestres.bairro` AS b 
    ON c.id_bairro = b.id_bairro
WHERE 
    DATE(c.data_inicio) = '2023-04-01'
GROUP BY 
    b.nome
ORDER BY 
    quantidade DESC
LIMIT 4; /* A consulta indica que o maior volume de chamados está concentrado em registros com bairro nulo. 
Apesar da possibilidade de aplicar 'IS NOT NULL' para excluí-los, optou-se por manter esses registros e apresentar, na sequência, os três bairros com maior número de chamados, 
proporcionando melhor contextualização dos dados.*/

/*Resposta:O maior volume de chamados não possui bairro registrado (NULL), possivelmente por se tratar de reclamações relacionadas a transporte público ou sem geo-referenciamento, 
que não estão associadas a um bairro específico.
Para chegar a essa inferência, a consulta da Pergunta 2 foi reexecutada sem o operador LIMIT, permitindo a visualização completa dos tipos de reclamações registrados no dia em questão.

Conclusão final:
Chamados sem bairro definido: 260
1º Campo Grande: 260 chamados
2º Tijuca: 100 chamados
3º Barra da Tijuca: 62 chamados
*/

#PERGUNTA 4: Qual o nome da subprefeitura com mais chamados abertos nesse dia?
--Objetivo da consulta: relacionar as duas bases via JOIN para acessar a coluna 'subprefeitura' e ordenar os resultados de forma semelhante a pergunta anterior.
SELECT 
    b.subprefeitura, 
    COUNT(*) AS quantidade
FROM 
    `datario.adm_central_atendimento_1746.chamado` AS c
LEFT JOIN 
    `datario.dados_mestres.bairro` AS b 
    ON c.id_bairro = b.id_bairro
WHERE 
    DATE(c.data_inicio) = '2023-04-01'
GROUP BY 
    b.subprefeitura
ORDER BY 
    quantidade DESC
LIMIT 1;
--Resposta: a subprefeitura com mais chamados foi a da Zona Norte, com 526 chamados.

#PERGUNTA 5: Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura? Se sim, por que?
--Objetivo da consulta: Filtrar os chamados do dia 01/04/2023 onde a coluna 'id_bairro' é nula (IS NULL), e trazer a coluna 'tipo' para entendermos o padrão os serviços que não possuem localização geográfica fixa
SELECT 
    id_chamado, 
    tipo, 
    id_bairro
FROM 
    `datario.adm_central_atendimento_1746.chamado`
WHERE 
    DATE(data_inicio) = '2023-04-01'
    AND id_bairro IS NULL;
/*Resultado: Sim. Existem chamados sem bairro associado. 
Ao analisar a consulta, notei que esses chamados se referem a trasnporte como "Veículos", "BRT (corredor expresso de ônibus)" - de maneira similar a pergunta 3 - 
ou serviços não geolocalizados como "Fiscalização Eletrônica" e "Ouvidoria - CLF".
*/
