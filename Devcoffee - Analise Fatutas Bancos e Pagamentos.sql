
-- Relatorios de custos para Power BI - versão testes 
--##########################################################################################################################################
--Inicio 
--Tabelas auxiliares temp CTE (Common Table Expression)
--EXPLAIN (analyze,COSTS,verbose,BUFFERS,format JSON) -- ANALISE QUERY 
with
	cil_temp as (select ci.c_invoice_id, 
					coalesce(cil.user1_id,cil.user2_id,0) as cil_cc
				from c_invoiceline cil --faturas linhas
					left join c_invoice ci on cil.c_invoice_id = ci.c_invoice_id --faturas
				group by ci.c_invoice_id,cil_cc), --essa subquery faz consulta dos itens da fatura e retorna centro de custo 
	cal_temp as (select cbkl.c_payment_id,
					coalesce(ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,0) as cacicil_cc,
					ROW_NUMBER() OVER (PARTITION BY cbkl.c_payment_id ORDER BY cbkl.c_payment_id) AS row_number --rank e rotulos dos dados para pegar o primeiro registro na posição
  				from c_bankstatementline cbkl
  						left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id --alicação de pagamentos linhas
  						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
  						left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --faturas linhas
  				where coalesce(ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,0) <> 0 --exclusão pagamentos que retornam dois agrupamentos e o primeiro é 0 
  				group by cbkl.c_payment_id, cacicil_cc), --essa subquery analisa as alocações de pagamentos adiantados e rerorna os cc usados nas faturas que usaram seus creditos 
  	ci_temp as (select 
   					cal.c_payment_id,
    				string_agg(ci.c_invoice_id::TEXT, ', ') as invoice_list
				FROM c_bankstatementline cbkl --extrato bancario linhas 
						left join c_allocationline cal on cal.c_payment_id = cbkl.c_payment_id --alocação de pagamentos 
						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
				group by cal.c_payment_id), --essa subquery retorna a lista das faturas que foram pagas com o crédito antecipado em forma de linha para não somar os itens repetidos
	cidate_temp as (select cbkl.c_payment_id,ci.c_invoice_id,ci.dateinvoiced,cips.duedate,
						ROW_NUMBER() OVER (PARTITION BY cbkl.c_payment_id ORDER BY cbkl.c_payment_id) AS row_number --rank e rotulos dos dados para pegar o primeiro registro na posição
  					from c_bankstatementline cbkl
  						left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id --alicação de pagamentos linhas
  						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
  						left join c_invoicepayschedule cips on cips.c_invoice_id = ci.c_invoice_id
  						left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --faturas linhas
  					group by cbkl.c_payment_id,ci.c_invoice_id,ci.dateinvoiced,cips.duedate), --essa subquery analisa as alocações de pagamentos adiantados e retorna as datas das faturas
  	dev_cancel_estorn_temp as (select cp.c_bpartner_id, cb.name,
									sum(case 
											when cp.isreceipt = 'N' and cp.payamt > 0 
											then cp.payamt else 0 end) *-1
								as dce_total
								from c_payment cp
									left join c_bpartner cb on cb.c_bpartner_id = cp.c_bpartner_id --parceiros
								--where cp.datetrx  between '2024-11-01' and '2024-11-30'
								group by cp.c_bpartner_id, cb.name
								having sum(case 
												when cp.isreceipt = 'N' and cp.payamt > 0 
													then cp.payamt 
											else 0 end)  > 0
										and sum(case 
													when cp.isreceipt = 'Y' and cp.payamt > 0 
													then cp.payamt 
												else 0 end)  > 0) --calcula cancelamentos, devoluções e estornos
--Tabelas auxiliares temp --CTE (Common Table Expression)
-- Fim 
--##########################################################################################################################################
--Inicio -
-- Consulta principal de receita e despesas 
select 	--ao."name",cba."name",cbkl.dateacct,cbk.updated,cbkl.c_bankstatementline_id,cbkl.line,cbkl.trxamt,cbk.beginningbalance,cbk.endingbalance,
		cbkl.dateacct as data_pagamento,coalesce(ci.dateinvoiced,cidate.dateinvoiced) as data_emissao,coalesce(cips.duedate,cidate.duedate) as data_vencimento, --datas 
		ao.ad_org_id as organizacao_cod, ao."name" as organizacao_nome, cba.c_bankaccount_id as banco_id , cba."name" as banco_nome, --codigos e nomes
		cb.c_bpartner_id  as pareceiro_id,cb."name" as parceiro_nome, --cod e nomes 
		case when (cc.c_elementvalue_id is null and cp.reversal_id is not null) or (cp.docstatus = 'RE') or (cbk.docstatus  = 'RE') or (cp.docstatus = 'RE')
						or (cbkl.description like ('%^%') or cbkl.description like ('%<%') or cbkl.description like ('%>%'))
				then -1
			when cc.c_elementvalue_id is null 
				then 0
			else cc.c_elementvalue_id
		end as centro_custo_id, --validação de cc pelos campos das tabelas e analisa se nao e estorno
		case when (cc."name" is null and cp.reversal_id is not null) or (cp.docstatus = 'RE') or (cbk.docstatus  = 'RE') or (cp.docstatus = 'RE')
						or (cbkl.description like ('%^%') or cbkl.description like ('%<%') or cbkl.description like ('%>%'))
						or (cp.description like ('%^%') or cp.description like ('%<%') or cp.description like ('%>%'))
			then 'ESTORNO'
			when cc."name" is null then 'ANALISAR'
			else cc."name" 
		end as centro_custo_nome, ----validação de cc pelos campos das tabelas e analisa se nao e estorno
		cc.value as cc_ref, -- cc ref ao BI 
		case when (((cc.c_elementvalue_id is not null and cp.reversal_id is null) or (cp.docstatus not in ('RE')) or (cbk.docstatus not in ('RE')) or (cp.docstatus not in ('RE'))
								or (cbkl.description not like ('%^%') or cbkl.description not like ('%<%') or cbkl.description not like ('%>%'))) 
										and cc.c_elementvalue_id in (5041450) and cical.invoice_list is null)						
					or (((cc.c_elementvalue_id is null and cp.reversal_id is null) or (cp.docstatus not in ('RE')) or (cbk.docstatus not in ('RE')) or (cp.docstatus not in ('RE'))
								or (cbkl.description not like ('%^%') or cbkl.description not like ('%<%') or cbkl.description not like ('%>%'))) 
										and cdoc.c_doctype_id in (5002293) and cical.invoice_list is null)
			then 'Analisar' 
			else 'OK'
		end as Valid_Antecipacao,--validação de pagamentos e recebimentos antecipados
	 cdoc.c_doctype_id as dooc_id ,cdoc."name" as doc_nome, --tippos docs
	 cbkl.trxamt as valor, --valor 
	 cbk.beginningbalance as saldo_inicial , cbk.endingbalance as saldo_final, --saldos de bancos 
	 cbk.endingbalance - cbk.beginningbalance as saldo_fim_inicial,
	 cbk.endingbalance - cbkl.trxamt as saldo_valor_mov,	 
	 cp.isreceipt as movimento_id, --receita Y N despesa
	 case when cbkl.trxamt > 0 then 'Entrada'
	 		when cbkl.trxamt < 0 then 'Saida'
	 end  as Tipo_Transacao,
	 cical.invoice_list as invoice_list, -- lista de faturas 
	 cp.docstatus doc_status_pag, cp.docstatus doc_status_fatura, --status documentos 
	 case when ci.docstatus in ('RE') or cp.docstatus in ('RE')
	 	then 'Devolução'
	 	else ''
	 end as Devolucao,
	 dce.dce_total as dce_total,cbkl.trxamt as cbkl_trxamt, --valores 
	 case 
	 	when cbkl.trxamt > 0 and dce.dce_total < 0
	 		then (cbkl.trxamt) + (dce.dce_total)
	 	when  cbkl.trxamt < 0
	 		then cbkl.trxamt
	 	else cbkl.trxamt
	 end as test, --analise
	 cbk.updated as data_update,
	 c_bankstatementline_id as linha_id
	 --cp.user1_id,cp.user2_id,ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id, --validação de centro de custos - usado para analises 
																--	cilcc.cil_cc,calant.cacicil_cc,cdoc.user1_id,cdoc.user2_id
from c_bankstatementline cbkl
	left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --pagamentos
	left join c_allocationline cal on cal.c_payment_id = cbkl.c_bankstatementline_id --alocação de pagamentos
	left join c_doctype cdoc on cdoc.c_doctype_id  = cp.c_doctype_id --tipos de documentos
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id --contas bancarias
	left join ad_org ao on ao.ad_org_id  = cbkl.ad_org_id -- empresas 
	left join c_bpartner cb on cb.c_bpartner_id = cbkl.c_bpartner_id --parceiros
	left join c_invoice ci on cp.c_invoice_id = ci.c_invoice_id --faturas
	left join c_invoiceline cil on cil.c_invoiceline_id = ci.c_invoice_id --faturas linhas
	left join c_invoicepayschedule cips on cips.c_invoicepayschedule_id = cp.c_invoicepayschedule_id --agendamentos de pagamentos 
	left join cil_temp cilcc on cil.c_invoice_id = ci.c_invoice_id --Itens da Faturaem cte
	left join cal_temp calant on calant.c_payment_id = cbkl.c_payment_id and calant.row_number = 1 -- alocação de pagamentos cte
	left join cidate_temp cidate on cidate.c_payment_id = cbkl.c_payment_id and cidate.row_number = 1 -- alocação de pagamentos e datas 
	left join ci_temp cical on cical.c_payment_id = cbkl.c_payment_id -- Faturas pagas com credito antecipados cte 
	left join c_elementvalue cc on cc.c_elementvalue_id = coalesce(cp.user1_id,cp.user2_id,ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,
																		cilcc.cil_cc,calant.cacicil_cc,cdoc.user1_id,cdoc.user2_id ,0) --cc valida valores de varios campos de varias tabelas
	left join dev_cancel_estorn_temp as dce on dce.c_bpartner_id = cbkl.c_bpartner_id  and cbkl.trxamt = (dce.dce_total)*-1 --valores de cancelamentos,estornos,devoluções
	where cbkl.ad_client_id = 5000017 --cliente 
	--and cbkl.c_bpartner_id  In (5143868,5125433,5154905,5142112,5154338,5155113,5092534) --parceiros 
	and cbkl.isactive  = 'Y' --registro ativo
	and cbk.docstatus in ('CO','CL') --status completo 
	--and ci.docstatus not in ('RE') --tratatiivas para gerar linhas de devoluções 
	--and cp.isreceipt = 'Y'
	--and cbkl.dateacct between current_date - interval '5 years' AND current_date
	and cbkl.dateacct  between '2024-01-01' and '2099-12-31'
order by organizacao_cod,banco_id,cbk.dateacct,cbkl.c_bankstatementline_id,cbkl.line;
--Consulta principal de receita e despesas 
--Fim
--##########################################################################################################################################

--##########################################################################################################################################
--Inicio
--Devoluções cancelamentos e estornos de clientes 
--##########################################################################################################################################
--Inicio 
--Tabelas auxiliares temp CTE (Common Table Expression)
--##########################################################################################################################################
--Inicio 
--Tabelas auxiliares temp CTE (Common Table Expression)
with
	cil_temp as (select ci.c_invoice_id, 
					coalesce(cil.user1_id,cil.user2_id,0) as cil_cc
				from c_invoiceline cil --faturas linhas
					left join c_invoice ci on cil.c_invoice_id = ci.c_invoice_id --faturas
				group by ci.c_invoice_id,cil_cc), --essa subquery faz consulta dos itens da fatura e retorna centro de custo 
	cal_temp as (select cbkl.c_payment_id,
					coalesce(ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,0) as cacicil_cc,
					ROW_NUMBER() OVER (PARTITION BY cbkl.c_payment_id ORDER BY cbkl.c_payment_id) AS row_number --rank e rotulos dos dados para pegar o primeiro registro na posição
  				from c_bankstatementline cbkl
  						left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id --alicação de pagamentos linhas
  						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
  						left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --faturas linhas
  				where coalesce(ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,0) <> 0 --exclusão pagamentos que retornam dois agrupamentos e o primeiro é 0 
  				group by cbkl.c_payment_id, cacicil_cc), --essa subquery analisa as alocações de pagamentos adiantados e rerorna os cc usados nas faturas que usaram seus creditos 
  	ci_temp as (select 
   					cal.c_payment_id,
    				string_agg(ci.c_invoice_id::TEXT, ', ') as invoice_list
				FROM c_bankstatementline cbkl --extrato bancario linhas 
						left join c_allocationline cal on cal.c_payment_id = cbkl.c_payment_id --alocação de pagamentos 
						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
				group by cal.c_payment_id), --essa subquery retorna a lista das faturas que foram pagas com o crédito antecipado em forma de linha para não somar os itens repetidos
	cidate_temp as (select cbkl.c_payment_id,ci.c_invoice_id,ci.dateinvoiced,cips.duedate,
						ROW_NUMBER() OVER (PARTITION BY cbkl.c_payment_id ORDER BY cbkl.c_payment_id) AS row_number --rank e rotulos dos dados para pegar o primeiro registro na posição
  					from c_bankstatementline cbkl
  						left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id --alicação de pagamentos linhas
  						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
  						left join c_invoicepayschedule cips on cips.c_invoice_id = ci.c_invoice_id
  						left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --faturas linhas
  					group by cbkl.c_payment_id,ci.c_invoice_id,ci.dateinvoiced,cips.duedate), --essa subquery analisa as alocações de pagamentos adiantados e retorna as datas das faturas
  	dev_cancel_estorn_temp as (select cp.c_bpartner_id, cb.name,
									sum(case 
											when cp.isreceipt = 'N' and cp.payamt > 0 
											then cp.payamt else 0 end) *-1
								as dce_total
								from c_payment cp
									left join c_bpartner cb on cb.c_bpartner_id = cp.c_bpartner_id --parceiros
								where cp.datetrx  between '2024-11-01' and '2024-11-30'
								group by cp.c_bpartner_id, cb.name
								having sum(case 
												when cp.isreceipt = 'N' and cp.payamt > 0 
													then cp.payamt 
											else 0 end)  > 0
										and sum(case 
													when cp.isreceipt = 'Y' and cp.payamt > 0 
													then cp.payamt 
												else 0 end)  > 0) --calcula cancelamentos, devoluções e estornos
--Tabelas auxiliares temp --CTE (Common Table Expression)
-- Fim 
--##########################################################################################################################################
--Devoluções cancelamentos e estornos de clientes 
--Pagamentos Cancelamentos, Estornos e Devoluções 
select cb.c_bpartner_id,cb."name",
	sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt*-1 else 0 end) 
		as Despesas,
	sum(case 
			when cp.isreceipt = 'Y' and cp.payamt > 0 
			then cp.payamt else 0 end) 
		as Receita,
	sum(case 
			when cp.isreceipt = 'Y' and cp.payamt > 0 
			then cp.payamt else 0 end) - 
	sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt else 0 end)
	as Dirença
from c_bankstatementline cbkl
	left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --pagamentos
	left join c_allocationline cal on cal.c_payment_id = cbkl.c_bankstatementline_id --alocação de pagamentos
	left join c_doctype cdoc on cdoc.c_doctype_id  = cp.c_doctype_id --tipos de documentos
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id --contas bancarias
	left join ad_org ao on ao.ad_org_id  = cbkl.ad_org_id -- empresas 
	left join c_bpartner cb on cb.c_bpartner_id = cbkl.c_bpartner_id --parceiros
	left join c_invoice ci on cp.c_invoice_id = ci.c_invoice_id --faturas
	left join c_invoiceline cil on cil.c_invoiceline_id = ci.c_invoice_id --faturas linhas
	left join c_invoicepayschedule cips on cips.c_invoicepayschedule_id = cp.c_invoicepayschedule_id --agendamentos de pagamentos 
	left join c_elementvalue cc on cc.c_elementvalue_id = coalesce(cp.user1_id,cp.user2_id,ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,
																		cdoc.user1_id,cdoc.user2_id ,0) --cc valida valores de varios campos de varias tabelas
	where cbkl.ad_client_id = 5000017 --cliente 
	--and cbkl.c_bpartner_id  In (5143868,5125433,5154905,5142112,5154338,5155113,5092534) --parceiros 
	and cbkl.isactive  = 'Y' --registro ativo
	and cbk.docstatus in ('CO','CL') --status completo 
	and cbkl.dateacct  between '2024-11-01' and '2024-11-30'
group by cb.c_bpartner_id,cb."name"
having sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt else 0 end)  > 0
		and sum(case 
			when cp.isreceipt = 'Y' and cp.payamt > 0 
			then cp.payamt else 0 end)  > 0
		and sum(case 
			when cp.isreceipt = 'Y' and cp.payamt > 0 
			then cp.payamt else 0 end) -
		sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt else 0 end) 	> 0
order by cb."name";

--Devoluções cancelamentos e estornos de clientes 
--Pagamentos Cancelamentos, Estornos e Devoluções
--Fim
/*#####################################################################################################################################################
 --Descrição
 Relatório Técnico: Análise da Query SQL com CTE (Common Table Expression)

Visão Geral

Este documento tem como objetivo explicar, de forma técnica e detalhada, a query SQL fornecida. Esta consulta foi projetada para gerar relatórios de custos para integração com o Power BI. O código utiliza expressões de tabela comum (CTEs) para organizar os dados de forma modular e eficiente antes de realizar a consulta principal.

Estrutura Geral da Query

1. CTEs (Tabelas Auxiliares)

As CTEs são utilizadas para simplificar a leitura e reutilização de subconsultas. Elas ajudam a dividir a lógica complexa em blocos menores e mais compreensíveis. Abaixo, cada CTE é descrita:

1.1 cil_temp

Retorna os centros de custo associados aos itens de fatura.

Lógica:

Faz uma junção entre c_invoiceline (itens da fatura) e c_invoice (faturas).

Seleciona o centro de custo (colunas user1_id ou user2_id) e agrupa por c_invoice_id.

1.2 cal_temp

Identifica centros de custo associados a pagamentos antecipados.

Lógica:

Junta várias tabelas relacionadas a pagamentos e faturas.

Usa a função ROW_NUMBER para obter o registro relevante.

Exclui registros com centros de custo nulos.

1.3 ci_temp

Cria uma lista de faturas pagas com créditos antecipados.

Lógica:

Agrega os IDs de faturas usando STRING_AGG para retornar uma lista concatenada.

1.4 cidate_temp

Retorna as datas de emissão e vencimento das faturas associadas a pagamentos.

Lógica:

Inclui a função ROW_NUMBER para garantir que os registros relevantes sejam capturados.

1.5 dev_cancel_estorn_temp

Calcula valores relacionados a cancelamentos, devoluções e estornos.

Lógica:

Filtra pagamentos no período especificado (01/11/2024 a 30/11/2024).

Agrega os valores de devoluções e cancelamentos.

2. Consulta Principal

2.1 Primeira Parte

Objetivo: Listar receitas e despesas.

Colunas Selecionadas:

Datas relevantes: pagamento, emissão e vencimento.

Detalhes da organização e parceiros.

Validação de centros de custo e antecipações.

Classificação de transações como "Entrada" ou "Saída".

Identifica devoluções e estornos.

2.2 Segunda Parte (UNION ALL)

Objetivo: Incluir dados relacionados a devoluções, cancelamentos e estornos de clientes.

Diferenciação:

Movimentos originais de despesas (isreceipt = 'N') são tratados como receitas (isreceipt = 'Y') para ajuste dos relatórios no BI.

Principais Funções e Técnicas Utilizadas

Funções de Janela

ROW_NUMBER() OVER (PARTITION BY ...):

Cria uma numeração para registros dentro de cada grupo, permitindo selecionar o registro relevante.

Agregações e Agrupamentos

STRING_AGG:

Concatena vários valores em uma única string.

SUM e CASE:

Calculam valores condicionais, como totais de cancelamentos e devoluções.

Validações Condicionais

Utilização extensiva de CASE para:

Validar centros de custo.

Classificar transações.

Identificar registros a serem analisados.

Filtros Aplicados

Atividade do Cliente:

Apenas registros do cliente com ad_client_id = 5000017 são incluídos.

Status do Documento:

Inclui documentos com status ('CO', 'CL').

Período:

Considera transações entre 01/11/2024 e 30/11/2024.

Exclusões:

Exclui registros não ativos (isactive = 'N') e transações com centros de custo nulos, dependendo do contexto.

Observações Importantes

Modularidade:

O uso de CTEs torna a query mais legível e permite reutilização de código em várias partes da consulta principal.

Desempenho:

Para grandes volumes de dados, pode ser necessária a otimização adicional, como índices em colunas usadas em joins e filtros.

Flexibilidade:

A query é extensível, permitindo ajustes para atender às necessidades específicas do relatório no Power BI.

Conclusão

Esta query é uma solução robusta para geração de relatórios financeiros com integração ao Power BI. A organização em CTEs facilita a manutenção e ampliação do código, 
enquanto as técnicas de validação e agregação garantem consistência nos dados apresentados.
 Recomenda-se revisitar periodicamente os filtros e joins para assegurar que a query continue eficiente e alinhada com os requisitos do negócio.
 Fim
 #########################################################################################################################*/



