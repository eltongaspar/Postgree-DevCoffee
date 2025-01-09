-- campos visiveis e mandatadorios 
SELECT e.AD_Client_ID, e.ElementType, e.Name, e.IsActive, e.IsMandatory
FROM C_AcctSchema_Element e
WHERE e.ElementType IN ('U1', 'U2');

--tipos de documentos 
select cdoc.user1_id , cdoc.user2_id,
* from c_doctype cdoc
where cdoc.c_doctype_id in (5002294,5002293,50023380,5002255);
--cdoc.user1_id  is not null 
	--or cdoc.user2_id  is not null ;

--centro de custos --exclusao da visao de bi
select cc.c_elementvalue_id ,cc."name" ,cc.value
from c_elementvalue cc 
where cc.value in ('0301','999991','999999')
	or cc.c_elementvalue_id = 5041219 ;

--5125433,5154905,5142112,5154338,5155113,5092534
--Parceiros 
select * from c_bpartner cbp
where  cbp."name" like ('%SANDRO DE SOUZA%');

-- Faturas
select ci.c_payment_id , ci.user1_id , ci.user2_id , ci.grandtotal, ci.dateinvoiced,
* from c_invoice ci
where ci.dateacct  between '2024-11-01' and '2024-11-30'
	and ci.c_bpartner_id  = 5055701;
-- c_payment_id nulo


-- Faturas linhas 
select cil.user1_id ,cil.user2_id, cil.linenetamt ,totallines,
* from c_invoiceline cil
	left join c_invoice ci on ci.c_invoice_id =cil.c_invoice_id 
where ci.dateacct between '2024-11-01' and '2024-11-30'
	and ci.c_bpartner_id = 5143868;

-- Pagamentos 
select cp.c_invoice_id , cp.c_payment_id ,cp.user1_id , cp.user2_id , cp.datetrx,cp.payamt,cp.isreceipt, cp.docstatus , cp.c_charge_id ,cp.c_invoicepayschedule_id ,
* from c_payment cp
where cp.datetrx  between '2024-11-01' and '2024-11-30'
	and cp.c_bpartner_id = 5055701
	and cp.user1_id = 5037121;

--Alocação de pagamentos linhas
 select  ca.c_allocationhdr_id,cal.c_payment_id,cal.c_invoice_id,cal.c_invoice_id,cal.c_invoicepayschedule_id,
 	cal.amount,cal.writeoffamt,cal.discountamt,
 * from c_allocationline cal
 	left join c_allocationhdr ca on cal.c_allocationhdr_id = ca.c_allocationhdr_id 
where ca.datetrx between '2024-11-01' and '2024-11-30'
	and cal.c_bpartner_id = 5055701
	and cal.c_payment_id  in (5378361,5377971,5378377);


--Alocação de pagamentos 
select * from c_allocationhdr ca
where ca.datetrx between '2024-11-01' and '2024-11-30';

--Extrato linhas
select cbkl.ad_org_id ,cbkl.c_payment_id ,cbkl.c_invoice_id ,cbkl.trxamt,
* from c_bankstatementline cbkl
where cbkl.dateacct between '2024-11-01' and '2024-11-30'
	and cbkl.isactive  = 'Y' --registro ativo
	and cbkl.c_bpartner_id  = 5055701
	and cbkl.c_payment_id  in (5378361,5377971,5378377);
 
 -- Extrato 
select * from c_bankstatement cbk
	left join c_bankstatementline cbkl on cbkl.c_bankstatement_id = cbk.c_bankstatement_id 
where cbk.dateacct between '2024-11-01' and '2024-11-30'
	and cbkl.c_bpartner_id  = 5055701
	and cbkl.c_payment_id  in (5378361,5377971,5378377);

-- agendamentos de pagamentos 
select cips.c_payment_id, ci.c_invoice_id,
* from c_invoicepayschedule cips
	left join c_invoice ci on cips.c_invoice_id = ci.c_invoice_id
where cips.duedate between '2024-11-01' and '2024-11-30'
	and ci.c_bpartner_id = 5143868
order by cips.c_invoice_id;
	--and cips.c_payment_id not in (null,0);

--Extrato linhas com inner joins para rastreamento de pagamentos antecipados 
 select ci.user1_id ,ci.user2_id , cal.amount, cbkl.trxamt,
 * from c_bankstatementline cbkl
  	left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id 
  	left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id 
  where cbkl.c_bpartner_id = 5143868 and cbkl.dateacct between '2024-11-01' and '2024-12-30';
 
--Extrato linhas com inner joins para rastreamento de pagamentos antecipados 
select cbkl.c_payment_id, cbkl.c_payment_id ,cp.c_payment_id,ci.c_invoice_id ,ci.user1_id, cp.user1_id,
	coalesce (ci.user1_id,cp.user2_id ,ci.user2_id,cp.user2_id,0) as cc_valid,cp.cof_processing3
from c_bankstatementline cbkl
  	left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id 
  	left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id 
  	left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --cbkl.c_invoice_id 
where cbkl.c_bpartner_id in (5143868)
group by cbkl.c_payment_id, cbkl.c_payment_id ,cp.c_payment_id,
		ci.c_invoice_id ,ci.user1_id,cp.c_payment_id;

--movimentações de estoques  
select * from m_inout mi 
	left join  m_inoutline mil on mil.m_inout_id = mi.m_inout_id 
where mi.c_bpartner_id in (5155113);

--movimentações de estoques  linhas
select * from m_inoutline mil
where mil.c_bpartner_id in (5155113);

-- Confrontar Pedido / Fatura
select mm.qty,mm.c_orderline_id , m_product_id , mm.m_inoutline_id , mm.c_invoiceline_id ,
* from m_matchpo mm
where mm.ad_client_id = 5000017;


-- View 
SELECT tipo, ad_client_id, ad_org_id, c_bpartner_id, user1_id, user2_id, c_activity_id, c_charge_id, m_product_id, cof_c_planofinanceiro_id, chave_parceiro, nome_parceiro, tipo_plano_financeiro, chave_plano_financeiro, plano_financeiro, chave_produto_finalidade, produto_finalidade, chave_centro_custo, centro_custo, chave_centro_custo2, centro_custo2, chave_atividade, atividade, valor_pagamento, paydate, cof_allocationdate, isreceipt
FROM adempiere.rv_cof_relatorioregimecaixa_acero;

--analise 
SELECT al.c_payment_id,
            sum(currencyconvert(COALESCE(al.amount, 0::numeric) + COALESCE(al.discountamt, 0::numeric) + COALESCE(al.writeoffamt, 0::numeric), ah.c_currency_id, ah.c_currency_id, ah.datetrx::timestamp with time zone, NULL::numeric, al.ad_client_id, al.ad_org_id)) AS valor_aberto
           FROM c_allocationline al --alocação de pagamentos linhas
             JOIN c_allocationhdr ah ON al.c_allocationhdr_id = ah.c_allocationhdr_id --alocação de pagamentos cab.
          WHERE ah.isactive = 'Y'::bpchar AND (ah.docstatus = ANY (ARRAY['CO'::bpchar, 'CL'::bpchar])) 
          AND ah.dateacct between to_timestamp('2024-11-01'::text, 'YYYY-MM-DD'::text) and to_timestamp('2024-11-30'::text, 'YYYY-MM-DD'::text)
          GROUP BY al.c_payment_id;

--analise 
select cbkl.c_payment_id,ci.c_invoice_id,ci.dateinvoiced,cips.duedate,cbkl.dateacct,cal.amount,ci.grandtotal,cbkl.trxamt,cp.payamt,
						ROW_NUMBER() OVER (PARTITION BY cbkl.c_payment_id ORDER BY cbkl.c_payment_id) AS row_number --rank e rotulos dos dados para pegar o primeiro registro na posição
  					from c_bankstatementline cbkl
  						left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id --alicação de pagamentos linhas
  						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
  						left join c_invoicepayschedule cips on cips.c_invoice_id = ci.c_invoice_id
  						left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --faturas linhas
  						left join c_payment cp on cp.c_payment_id = cal.c_payment_id 
  						left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
  					where ((cp.reversal_id is null) or (cp.docstatus not in ('RE')) or (cbk.docstatus not in ('RE')) or (cp.docstatus not in ('RE'))
								or (cbkl.description not like ('%^%') or cbkl.description not like ('%<%') or cbkl.description not like ('%>%')))
						and cbkl.c_bpartner_id in (5155113)
  					group by cbkl.c_payment_id,ci.c_invoice_id,ci.dateinvoiced,cips.duedate,cal.amount,cbkl.trxamt,cp.payamt,cbkl.dateacct;

SELECT * 
FROM information_schema.columns 
WHERE column_name = 'cof_qtdamortizacao';


-- Pagamentos Cancelamentos, Estornos e Devoluções 
select cp.c_bpartner_id, cb.name,
	sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt else 0 end) 
		as Devolucao_Estorno_Cancel,
	sum(case 
			when cp.isreceipt = 'R' and cp.payamt > 0 
			then cp.payamt else 0 end) 
		as Receita
from c_payment cp
	left join c_bpartner cb on cb.c_bpartner_id = cp.c_bpartner_id --parceiros
where cp.datetrx  between '2024-11-01' and '2024-11-30'
	and cp.c_bpartner_id in  (5125433,5154905,5142112,5154338,5155113,5092534)
group by cp.c_bpartner_id, cb.name
having sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt else 0 end)  > 0
		and sum(case 
			when cp.isreceipt = 'Y' and cp.payamt > 0 
			then cp.payamt else 0 end)  > 0 
order by cp.c_bpartner_id;

-- Pagamentos 
select cp.c_bpartner_id, cb.name,
    SUM(CASE 
            WHEN cp.isreceipt = 'N' THEN cp.payamt 
            ELSE 0 
        END) AS Devolucao_Estorno_Cancel
FROM c_payment cp
	left join c_bpartner cb on cb.c_bpartner_id = cp.c_bpartner_id --parceiros
WHERE cp.c_bpartner_id IN (
    SELECT cp.c_bpartner_id 
    FROM c_payment cp 
    WHERE isreceipt = 'Y'
)
	--and cp.c_bpartner_id in  (5125433,5154905,5142112,5154338,5155113,5092534)
	and cp.docstatus not in ('RE')
group by cp.c_bpartner_id,cb.name;

-- Relatorios de custos para Power BI - versão testes -- Devoluções cancelamentos e estornos de clientes 
--Pagamentos Cancelamentos, Estornos e Devoluções 
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
--Devoluções cancelamentos e estornos de clientes 
--Pagamentos Cancelamentos, Estornos e Devoluções 
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
					--and cbkl.description is null
			then 'Analisar' 
			else 'OK'
		end as Valid_Antecipacao,--validação de pagamentos e recebimentos antecipados
	 cdoc.c_doctype_id as dooc_id ,cdoc."name" as doc_nome,
	 cbkl.trxamt as valor , cbk.beginningbalance as saldo_inicial , cbk.endingbalance as saldo_final,
	 case 
	 	when sum(case 
					when cp.isreceipt = 'N' and cp.payamt > 0 
						then cp.payamt else 0 end) > 0
	 		then 'DCE'
	 		else 'NOT'--cp.isreceipt
	 end as movimento_id, 
	 --aqui forço os movimentos originais N(Despesa) a virar 'DCE'(Receitas), valores continuam negativo, 
	 --para abater valores das transações de estornos, 
	 --devoluções e cancelamentos de clientes para a visão de BI
	 --DCE -   devoluções, cancelamentos e estoornos
	 case when cbkl.trxamt > 0 then 'Entrada'
	 		when cbkl.trxamt < 0 then 'Saida'
	 end  as Tipo_Transacao,
	 cical.invoice_list as invoice_list,
	 cp.docstatus doc_status_pag, cp.docstatus doc_status_fatura,
	 case when ci.docstatus in ('RE') or cp.docstatus in ('RE')
	 	then 'Devolução'
	 	else ''
	 end as Devolucao,
	 dce.dce_total,
	 cbkl.trxamt,
	 case 
	 	when cbkl.trxamt  > 0 and dce.dce_total < 0 --and cical.invoice_list is null
	 		then (cbkl.trxamt + dce.dce_total)
	 	when  cbkl.trxamt  < 0
	 		then cbkl.trxamt 
	 	else cbkl.trxamt
	 end as test,
	 sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt else 0 end) *-1
		as Devolucao_Estorno_Cancel
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
	and cbkl.c_bpartner_id  In (5143868,5125433,5154905,5142112,5154338,5155113,5092534) --parceiros 
	and cbkl.isactive  = 'Y' --registro ativo
	and cbk.docstatus in ('CO','CL') --status completo 
	and cbkl.dateacct  between '2024-11-01' and '2024-11-30'
group by cbkl.dateacct,coalesce(ci.dateinvoiced,cidate.dateinvoiced),coalesce(cips.duedate,cidate.duedate), --datas 
		ao.ad_org_id,ao."name", cba.c_bankaccount_id, cba."name",
		cb.c_bpartner_id,cb."name",
		centro_custo_id,centro_custo_nome,cc_ref,Valid_Antecipacao,
		cdoc.c_doctype_id,cdoc."name",
	 	cbkl.trxamt,cbk.beginningbalance,cbk.endingbalance,
	 	cp.isreceipt,
	 	cical.invoice_list,
	 	cp.docstatus,cp.docstatus,
	 	Devolucao,
	 	dce.dce_total
having sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt else 0 end)  > 0;
