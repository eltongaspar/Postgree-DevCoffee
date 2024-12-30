
-- Relatorios de custos para Power BI - versão testes 
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
select cbkl.dateacct as data_pagamento, cbkl.created as data_emissão, ao.ad_org_id as organizacao_cod, ao."name" as organizacao_nome, cba.c_bankaccount_id as banco_id , cba."name" as banco_nome, 
		cb.c_bpartner_id  as pareceito_id,cb."name" as parceiro_nome,
		case when (cc.c_elementvalue_id is null and cp.reversal_id is not null) or (cp.docstatus = 'RE') or (cbk.docstatus  = 'RE') or (cp.docstatus = 'RE')
						or (cbkl.description like ('%^%') or cbkl.description like ('%<%') or cbkl.description like ('%>%'))
				then -1
			when cc.c_elementvalue_id is null 
				then 0
			else cc.c_elementvalue_id
		end as centro_custo_id, 
		case when (cc."name" is null and cp.reversal_id is not null) or (cp.docstatus = 'RE') or (cbk.docstatus  = 'RE') or (cp.docstatus = 'RE')
						or (cbkl.description like ('%^%') or cbkl.description like ('%<%') or cbkl.description like ('%>%'))
			then 'ESTORNO'
			when cc."name" is null then 'ANALISAR'
			else cc."name" 
		end as centro_custo_nome,
		cc.value as cc_ref,
		case when ((cc.c_elementvalue_id is not null and cp.reversal_id is null) or (cp.docstatus not in ('RE')) or (cbk.docstatus not in ('RE')) or (cp.docstatus not in ('RE'))
								or (cbkl.description not like ('%^%') or cbkl.description not like ('%<%') or cbkl.description not like ('%>%'))) 
						and cc.c_elementvalue_id in (5041450) and cical.invoice_list is null
			then 'Analisar' 
			else 'OK'
		end as Valid_Antecipacao,
	 cdoc.c_doctype_id as dooc_id ,cdoc."name" as doc_nome,
	 cbkl.trxamt as valor , cbk.beginningbalance as saldo_inicial , cbk.endingbalance as saldo_final ,
	 cp.isreceipt movimento_id ,
	 case when cbkl.trxamt > 0 then 'Entrada'
	 		when cbkl.trxamt < 0 then 'Saida'
	 end  as Tipo_Transacao, 
	 cp.cof_creditdate, --anslise para devoluções de creditos 
	 cical.invoice_list as invoice_list,cp.docstatus doc_statusd,
	 cp.user1_id,cp.user2_id,ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,
																	cilcc.cil_cc,calant.cacicil_cc,cdoc.user1_id,cdoc.user2_id,
* from c_bankstatementline cbkl
	left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --pagamentos
	left join c_allocationline cal on cal.c_payment_id = cbkl.c_bankstatementline_id 
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
																	cilcc.cil_cc,calant.cacicil_cc,cdoc.user1_id,cdoc.user2_id ,0) --cc
	where cbkl.ad_client_id = 5000017
	--and cbkl.c_bpartner_id  = 5092534
	--and cbkl.trxamt < 0
	--and cbkl.ad_org_id  = 5000047 -- codigo empresa
	--and cbk.c_bankaccount_id In (5000219,5000392) -- bancos 5000392
	--and cp.c_invoice_id is not null
	and cbkl.isactive  = 'Y' --registro ativo
	--and cp.docstatus not in ('RE') --titulos estornados na cp payment
	and cbk.docstatus in ('CO','CL')
	--and cbkl.c_payment_id  in (5388263,5388441,5388442,5388443,5388444) --testes 
	--and cc.c_elementvalue_id not in  (0,-1)
	--and cc."name"  not in ('AÇO','TRANSFERÊNCIA')
	and cbkl.dateacct between '2024-11-01' and '2024-11-30'
	--and cc.c_elementvalue_id = 503712100
	order by cba.c_bankaccount_id,cbkl.c_bankstatementline_id ;


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






