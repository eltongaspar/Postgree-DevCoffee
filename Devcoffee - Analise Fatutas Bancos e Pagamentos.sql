
-- Relatorios de custos para Power BI - versão testes 
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
  					group by cbkl.c_payment_id,ci.c_invoice_id,ci.dateinvoiced,cips.duedate) --essa subquery analisa as alocações de pagamentos adiantados e retorna as datas das fatuuras 
select cbkl.dateacct as data_pagamento,coalesce(ci.dateinvoiced,cidate.dateinvoiced) as data_emissao,coalesce(cips.duedate,cidate.duedate) as data_vencimento, --datas 
		ao.ad_org_id as organizacao_cod, ao."name" as organizacao_nome, cba.c_bankaccount_id as banco_id , cba."name" as banco_nome, 
		cb.c_bpartner_id  as pareceiro_id,cb."name" as parceiro_nome,
		case when (cc.c_elementvalue_id is null and cp.reversal_id is not null) or (cp.docstatus = 'RE') or (cbk.docstatus  = 'RE') or (cp.docstatus = 'RE')
						or (cbkl.description like ('%^%') or cbkl.description like ('%<%') or cbkl.description like ('%>%'))
				then -1
			when cc.c_elementvalue_id is null 
				then 0
			else cc.c_elementvalue_id
		end as centro_custo_id, --validação de cc pelos campos das tabelas e analisa se nao e estorno
		case when (cc."name" is null and cp.reversal_id is not null) or (cp.docstatus = 'RE') or (cbk.docstatus  = 'RE') or (cp.docstatus = 'RE')
						or (cbkl.description like ('%^%') or cbkl.description like ('%<%') or cbkl.description like ('%>%'))
			then 'ESTORNO'
			when cc."name" is null then 'ANALISAR'
			else cc."name" 
		end as centro_custo_nome,
		cc.value as cc_ref,
		case when (((cc.c_elementvalue_id is not null and cp.reversal_id is null) or (cp.docstatus not in ('RE')) or (cbk.docstatus not in ('RE')) or (cp.docstatus not in ('RE'))
								or (cbkl.description not like ('%^%') or cbkl.description not like ('%<%') or cbkl.description not like ('%>%'))) 
										and cc.c_elementvalue_id in (5041450) and cical.invoice_list is null)						
					or (((cc.c_elementvalue_id is null and cp.reversal_id is null) or (cp.docstatus not in ('RE')) or (cbk.docstatus not in ('RE')) or (cp.docstatus not in ('RE'))
								or (cbkl.description not like ('%^%') or cbkl.description not like ('%<%') or cbkl.description not like ('%>%'))) 
										and cdoc.c_doctype_id in (5002293) and cical.invoice_list is null)					
			then 'Analisar' 
			else 'OK'
		end as Valid_Antecipacao,--validação de pagamentos e recebimentos antecipados
	 cdoc.c_doctype_id as dooc_id ,cdoc."name" as doc_nome,
	 cbkl.trxamt as valor , cbk.beginningbalance as saldo_inicial , cbk.endingbalance as saldo_final,
	 cp.isreceipt movimento_id,
	 case when cbkl.trxamt > 0 then 'Entrada'
	 		when cbkl.trxamt < 0 then 'Saida'
	 end  as Tipo_Transacao,
	 --cp.cof_creditdate, --anslise para devoluções de creditos 
	 cical.invoice_list as invoice_list,cp.docstatus doc_status,*
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
	where cbkl.ad_client_id = 5000017 --cliente 
	and cbkl.c_bpartner_id  In (5142112) --parceiros 
	and cbkl.isactive  = 'Y' --registro ativo
	and cbk.docstatus in ('CO','CL') --status completo 
	--and cbkl.dateacct between current_date - interval '5 years' AND current_date
	and cbkl.dateacct  between '2024-11-01' and '2024-11-30'
	order by cba.c_bankaccount_id,cbkl.c_bankstatementline_id ;
/*#####################################################################################################################################################
 A consulta SQL fornecida é uma combinação complexa de várias tabelas, CTEs e subconsultas que cria um relatório detalhado para análise de custos. Segue uma resumo funcional dividido em partes:

Objetivo Geral:
Gerar um relatório financeiro para integração com o Power BI, que inclui informações sobre pagamentos, faturas, parceiros, bancos e validações de centro de custo.
CTEs (Subconsultas Nomeadas):
cil_temp:

Busca itens de faturas (c_invoiceline) e associa os centros de custo (user1_id ou user2_id).
Resultado: Cada fatura com seu respectivo centro de custo.
cal_temp:

Analisa alocações de pagamentos antecipados, associando centros de custo usados nas faturas.
Inclui um ROW_NUMBER() para trazer apenas um registro por c_payment_id.
ci_temp:

Gera uma lista de IDs de faturas pagas com um mesmo pagamento (antecipado ou não), consolidando em uma única linha (STRING_AGG).
Campos Selecionados na Consulta Final:
Datas:

data_pagamento: Data do pagamento (linha do extrato bancário).
data_emissão: Data de emissão da fatura.
data_vencimento: Data de vencimento da fatura.
Informações Organizacionais:

ID e nome da organização (organizacao_cod, organizacao_nome).
ID e nome do banco (banco_id, banco_nome).
ID e nome do parceiro (parceiro_id, parceiro_nome).
Validação de Centro de Custo:

centro_custo_id: ID validado do centro de custo.
centro_custo_nome: Nome validado do centro de custo.
cc_ref: Referência do centro de custo.
Validações e Categorizações:

Valid_Antecipacao: Marca pagamentos antecipados como "Analisar" ou "OK".
Tipo_Transacao: Classifica transações como "Entrada" ou "Saída".
Outros Dados:

valor: Valor da transação.
saldo_inicial e saldo_final: Saldo inicial e final do extrato.
invoice_list: Lista de faturas associadas ao pagamento.
doc_status: Status do documento.
Validações e Filtros:
Validação de Centros de Custo:

Identifica erros como reversões (RE) e inconsistências em descrições.
Classifica transações como "Estorno", "Analisar" ou valida.
Filtros de Dados:

Inclui apenas registros ativos (isactive = 'Y').
Considera apenas extratos bancários com status "Completado" ou "Encerrado" (docstatus IN ('CO', 'CL')).
Filtra por datas dos últimos 5 anos.
Joins Principais:
Conexões entre tabelas de pagamentos, faturas e linhas de extrato bancário para consolidar informações financeiras.
Uso de cil_temp, cal_temp e ci_temp para enriquecer os dados com detalhes de centros de custo e pagamentos antecipados.
Associações com tabelas de elementos organizacionais (ad_org, c_bankaccount, etc.).
Ordenação:
Os resultados são ordenados por conta bancária (c_bankaccount_id) e ID da linha de extrato (c_bankstatementline_id).
Resumo Final:
Essa query:

Integra múltiplas tabelas financeiras para criar um relatório robusto de transações e centros de custo.
Implementa validações para identificar erros e inconsistências em centros de custo e pagamentos antecipados.
Está otimizada para alimentar sistemas de análise, como o Power BI, com informações detalhadas e bem categorizadas.
 #################################################################################################################################*/


-- Relatorios de custos para Power BI - versão testes -- soma  
with
	cil_temp as (select ci.c_invoice_id, 
					coalesce(cil.user1_id,cil.user2_id,0) as cil_cc
				from c_invoiceline cil --faturas linhas
					left join c_invoice ci on cil.c_invoice_id = ci.c_invoice_id --faturas
				group by ci.c_invoice_id,cil_cc), --essa subquery faz consulta dos itens da fatura e retorna centro de custo 
	cal_temp as (select cbkl.c_payment_id, 
					coalesce(ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,0) as cacicil_cc
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
				group by cal.c_payment_id) --essa subquery retorna a lista das faturas que foram pagas com o crédito antecipado em forma de linha para não somar os itens repetidos
select sum(cbkl.trxamt) as Geral,
		SUM(CASE WHEN cbkl.trxamt > 0 THEN cbkl.trxamt ELSE 0 END) AS Receita, -- Soma apenas dos valores positivos
    SUM(CASE WHEN cbkl.trxamt < 0 THEN cbkl.trxamt ELSE 0 END) AS Despesas -- Soma apenas dos valores negativos
from c_bankstatementline cbkl
	left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --pagamentos
	left join c_doctype cdoc on cdoc.c_doctype_id  = cp.c_doctype_id --tipod de documentos
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id 
	left join ad_org ao on ao.ad_org_id  = cbkl.ad_org_id -- empresas 
	left join c_bpartner cb on cb.c_bpartner_id = cbkl.c_bpartner_id --parceiros
	left join c_invoice ci on cp.c_invoice_id = ci.c_invoice_id --faturas
	left join c_invoiceline cil on cil.c_invoiceline_id = ci.c_invoice_id
	left join cil_temp cilcc on cil.c_invoice_id = ci.c_invoice_id --Itens da Fatura
	left join cal_temp calant on calant.c_payment_id = cbkl.c_payment_id -- alocação de pagamentos 
	left join ci_temp cical on cical.c_payment_id = cbkl.c_payment_id -- Faturas pagas com credito antecioado
	left join c_elementvalue cc on cc.c_elementvalue_id = coalesce(cp.user1_id,cp.user2_id,ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,
																	cilcc.cil_cc,calant.cacicil_cc,0) --cc
	where cbkl.ad_client_id = 5000017
	--and cbkl.c_bpartner_id = 5092534
	--and cbkl.ad_org_id  = 5000047 -- codigo empresa
	--and cbk.c_bankaccount_id In (5000219,5000392) -- bancos 5000392
	and cbkl.isactive  = 'Y' --registro ativo
	--and cp.docstatus not in ('RE') --titulos estornados na cp payment
	and cbk.docstatus in ('CO','CL')
	and cbkl.dateacct between '2024-11-01' and '2024-11-30';


select cp.cof_creditdate ,* from c_payment cp 
where cp.cof_creditdate is not null;






