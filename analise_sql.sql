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

#PERGUNTA 6: Quantos chamados de Perturbação do sossego foram abertos nesse período (01/01/2022 a 31/12/2024)?
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

#PERGUNTA 7: Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).
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

#PERGUNTA 08: Quantos chamados desse subtipo foram abertos em cada evento?.
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

#PERGUNTA 09: Qual evento teve a maior média diária de chamados abertos desse subtipo?
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

#PERGUNTA 10: Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio)
/* Objetivo da consulta: 
Estruturar a análise em 3 etapas lógicas:
Primeiro, calcular a média diária geral de chamados ao longo dos três anos (2022 a 2024. 
Em seguida, será isolada cada edição anual dos eventos (ex: Carnaval 2022, Carnaval 2023) para calcular a duração exata em dias e o volume de chamados de cada período. 
Depois, essas edições são agrupadas  por evento, somando-se todos os chamados e todos os dias de duração para extrair uma média diária única. 
Por fim, as métricas consolidadas são cruzadas com a média geral.
*/

--Primeira etapa: cálculo da média diária geral dos 3 anos de reclamações de perturbação do sossego:
WITH MediaGeral AS (
    SELECT 
        COUNT(*) / 1096.0 AS media_diaria_geral -- Quantidade de dias entre 01/01/2022 e 31/12/2024: 1096
    FROM `datario.adm_central_atendimento_1746.chamado`
    WHERE id_subtipo = '5071' 
      AND DATE(data_inicio) 
      BETWEEN '2022-01-01' AND '2024-12-31'
),
ChamadosPorEdicao AS (
    -- Segunda etapa: Contar os chamados para cada ano por evento
    SELECT 
        e.evento, 
        e.data_inicial,
        e.data_final,
        COUNT(c.id_chamado) AS total_chamados_edicao,
        DATE_DIFF(e.data_final, e.data_inicial, DAY) + 1 AS dias_edicao
    FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
    INNER JOIN `datario.adm_central_atendimento_1746.chamado` AS c
        ON DATE(c.data_inicio) 
        BETWEEN e.data_inicial AND e.data_final
    WHERE c.id_subtipo = '5071'
      AND DATE(c.data_inicio) 
      BETWEEN '2022-01-01' AND '2024-12-31'
    GROUP BY e.evento, e.data_inicial, e.data_final
),
MediaConsolidada AS (
    -- Terceira etapa: Compila os chamados e os dias de todas as ocorrências dos eventos para gerar média única.
    SELECT 
        evento, 
        SUM(total_chamados_edicao) / SUM(dias_edicao) AS media_diaria_evento
    FROM ChamadosPorEdicao
    GROUP BY evento
)
SELECT 
    mc.evento, 
    ROUND(mc.media_diaria_evento, 2) AS media_diaria_evento, 
    ROUND(mg.media_diaria_geral, 2) AS media_diaria_geral
FROM MediaConsolidada AS mc
CROSS JOIN MediaGeral AS mg
ORDER BY mc.media_diaria_evento DESC;
/* Resultado: A consulta indicou uma tabela com 3 linhas, uma linha para cada evento, evidenciando que a média diária geral de reclamações de perturbação ao sossego foi de 52,49 chamados por dia ao longo desses 3 anos. 
Os eventos com maior média diária de reclamações superaram a média diária do período analisado. O Rock in Rio registrou uma média de 136,86 chamados por dia (mais de 2,5 vezes a média diária geral para esse subtipo de chamado no período observado). 
O Carnaval registrou uma média de 63,75 chamados por dia, valor acima da média diária calculada ao longo dos 3 anos. Com isso, observamos o potencial que ambos os eventos (Rock in Rio e Carnaval) têm de impactar negativamente a vida dos cidadãos cariocas. 
Além disso, o Réveillon, com uma média de 50,67 chamados por dia, foi o único com média diária ligeiramente abaixo da média global do período (52,49), ainda que permaneça em patamar elevado. 
Portanto, recomenda-se a ampla divulgação do serviço de fiscalização de perturbação do sossego, por meio da Central de Atendimento 1746, antes e durante esses eventos, especialmente no Carnaval e no Rock in Rio. 
Essa divulgação deve ser intensificada em mídias tradicionais, como rádio e TV aberta, e também em canais digitais e redes sociais, incluindo a página oficial da Prefeitura e a republicação por perfis institucionais de grande alcance, como o COR-Rio no Instagram, que possui elevado engajamento e frequente acompanhamento junto à população carioca. 
De forma complementar, recomenda-se a suplementação e maior integração estratégica entre as equipes de fiscalização e as responsáveis pelo tratamento e encaminhamento dos chamados durante esses eventos, com o objetivo de ampliar a eficiência operacional, reduzir o tempo de resposta e qualificar o atendimento à população. */