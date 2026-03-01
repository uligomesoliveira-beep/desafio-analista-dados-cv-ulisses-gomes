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
--Resposta: o chamado mais registrado foi o de "estacionamento irregular", com 373 reclamações abertas.

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

/*Resposta:O maior volume de chamados não possui bairro registrado (NULL), possivelmente por se tratar de reclamações relacionadas a transporte público, que não estão associadas a um bairro específico
ou sem geo-referenciamento.
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
Ao analisar a consulta, observa-se que esses chamados se referem a trasnportes como "Veículos" e /ou "BRT (corredor expresso de ônibus)" - de maneira similar a pergunta 3 - 
ou serviços não geolocalizados como "Fiscalização Eletrônica" e "Ouvidoria - CLF".
*/

#Pergunta 6: Quantos chamados de Perturbação do sossego foram abertos nesse período (01/01/2022 a 31/12/2024)?
--Objetivo da consulta: Filtrar os chamados pelo código do chamado específico com o operador 'BETWEEN'para o período solicitado.
SELECT 
    COUNT(*) AS total_chamados_sossego
FROM 
    `datario.adm_central_atendimento_1746.chamado`
WHERE 
    id_subtipo = '5071'#chamado de perturbação ao sossego
    AND DATE(data_inicio) 
    BETWEEN '2022-01-01' AND '2024-12-31';
--Resultado: Foram 57.532 chamados do tipo perturbação de sossego (5071) entre 01/01/2022 a 31/12/2024.

#Pergunta 7: Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).
/*Objetivo da consulta: Conectar a tabela de chamados com a de eventos via 'JOIN' 
para filtrar os chamados de perturbação ao sossego nos eventos solicitados*/
SELECT
    c.id_chamado,
    c.data_inicio,
    e.evento
FROM 
    `datario.adm_central_atendimento_1746.chamado` AS c
INNER JOIN 
    `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
    ON DATE(c.data_inicio) 
    BETWEEN e.data_inicial AND e.data_final
WHERE 
    c.id_subtipo = '5071'#chamado de perturbação ao sossego
    AND DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2024-12-31';
/*Resultado: A consulta teve como resultado uma tabela com 1.365 linhas, 
em que cada linha representa um chamado de 'perturbação do sossego',
detalhando a data e hora da abertura do chamado e o a qual evento ele está atrelado.*/

#Pergunta 08: Quantos chamados desse subtipo foram abertos em cada evento?.
--Objetivo da consulta: Contar os chamados de perturbação ao sossego abertos no período de cada evento destacado.
SELECT 
    e.evento,
    COUNT(*) AS total_chamados
FROM 
    `datario.adm_central_atendimento_1746.chamado` AS c
INNER JOIN 
    `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
    ON DATE(c.data_inicio) 
    BETWEEN e.data_inicial AND e.data_final
WHERE 
    c.id_subtipo = '5071' #chamado de perturbação ao sossego
    AND DATE(c.data_inicio) 
    BETWEEN '2022-01-01' AND '2024-12-31'
GROUP BY 
    e.evento;
/*Resultado: O Rock in Rio é o evento que mais distoa dos demais com reclamações de perrturbação do sossego, 
necessitando então de um maior incremento a fiscalização desse tipo de chamado nas datas desse evento*/
    --1º Rock in Rio: 958 chamados abertos;
    --2º Carnaval: 255 chamados abertos;
    --3º Réveillon: 152 chamados abertos.

#Pergunta 09: Qual evento teve a maior média diária de chamados abertos desse subtipo?
/*Objetivo da consulta: Calcular a média diária de chamados abertos do subtipo requisitado por evento 
e retornar através do operador LIMIT apenas a maior média encontrada. 
    Inferência prévia: o carnaval apresentará a maior média por se tratar de um evento 
    com vários dias de festas espalhadas em vários polos da cidade*/
SELECT 
    e.evento,
    COUNT(*) AS total_chamados,
    DATE_DIFF(MAX(e.data_final), MAX(e.data_inicial), DAY) + 1 AS dias_de_evento,
    COUNT(*) / (DATE_DIFF(MAX(e.data_final), MAX(e.data_inicial), DAY) + 1) AS media_diaria
FROM 
    `datario.adm_central_atendimento_1746.chamado` AS c
INNER JOIN 
    `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
    ON DATE(c.data_inicio) 
    BETWEEN e.data_inicial AND e.data_final
WHERE 
    c.id_subtipo = '5071' #chamado de perturbação ao sossego
    AND DATE(c.data_inicio) 
    BETWEEN '2022-01-01' AND '2024-12-31'
GROUP BY 
    e.evento
ORDER BY 
    media_diaria DESC
LIMIT 1;
/*Resultado: Maior média de reclamações de perturbação ao sossego por evento foi o Rock in Rio (Média de 239,5 chamados por dia). 
Inferência inicial se mostrou como errada*/

#Pergunta 10: Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio)
            # e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2024.
/*Objetivo da consulta: Executar o comando 'WITH' para assim criar duas tabelas temporárias das médias diárias. 
Uma para 'MediaGeral' e outra para a 'MediaEventos' e após isso relacionar ambas pelo operador 'CROSS JOIN, 
permitindo uma comparação visual direta entre os resultados*/
WITH MediaGeral AS (
    SELECT 
        COUNT(*) / (DATE_DIFF('2024-12-31', '2022-01-01', DAY) + 1) AS media_diaria_geral
    FROM `datario.adm_central_atendimento_1746.chamado`
    WHERE id_subtipo = '5071' #chamado de perturbação ao sossego
      AND DATE(data_inicio) 
      BETWEEN '2022-01-01' AND '2024-12-31'
),
MediaEventos AS (
    SELECT 
        e.evento, 
        COUNT(*) / (DATE_DIFF(MAX(e.data_final), MAX(e.data_inicial), DAY) + 1) AS media_diaria_evento
    FROM `datario.adm_central_atendimento_1746.chamado` AS c
    INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
        ON DATE(c.data_inicio) 
        BETWEEN e.data_inicial AND e.data_final
    WHERE c.id_subtipo = '5071' #chamado de perturbação ao sossego
      AND DATE(c.data_inicio) 
      BETWEEN '2022-01-01' AND '2024-12-31'
    GROUP BY e.evento
)
SELECT #relacionando as duas tabelas para conseguir responder adequadamente a pergunta.
    me.evento, 
    me.media_diaria_evento, 
    mg.media_diaria_geral 
FROM 
    MediaEventos AS me
CROSS JOIN 
    MediaGeral AS mg;
/*Resultado: A consulta indicou uma tabela com 3 linhas, uma linha apra cada evento,
evidenciando que a média diária de reclamações de perturbação ao sossego foi de 52,49 chamados por dia ao longo desses 3 anos.
Os eventos com maior média diária de reclamações superaram em muito a média diária durante do período analisado. 

O Rock in Rio registrou uma média de 239,6 (quase 5x maior que a média diária para esse subtipo de chamado para o período observado).
O Carnval registrou uma média de (63.75, um pouco maior que a média diária calculada ao longo de 3 anos inteiros).
Com isso, observamos que o potencial que ambos eventos (Rock in Rio e Carnaval) tem de impactar negativamente a vida dos cidadãos cariocas.
Além disso, o Réveillon, com uma média de 50,66 chamados, foi o unico com uma média diária de chamados um pouco abaixo da média diária global do período, mesmo que ainda seja considerada uma média alta. 

Portanto, recomenda-se a ampla divulgação do serviço de fiscalização de perturbação do sossego, por meio da Central de Atendimento 1746, antes e durante esses eventos, especialmente no Carnaval e no Rock in Rio.
Essa divulgação deve ser intensificada em mídias tradicionais, como rádio e TV aberta, e também em canais digitais e redes sociais, incluindo a página oficial da Prefeitura e a republicação por perfis institucionais de grande alcance, como o COR-Rio no Instagram, que possui elevado engajamento e frquente acompanhamento junto à população carioca.
De forma complementar, recomenda-se a suplementação e maior integração estratégica entre as equipes de fiscalização e as responsáveis pelo tratamento e encaminhamento dos chamados durante esses eventos, com o objetivo de ampliar a eficiência operacional, reduzir o tempo de resposta e qualificar o atendimento à população.
*/


