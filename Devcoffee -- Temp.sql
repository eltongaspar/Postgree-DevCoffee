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
	and ci.c_bpartner_id  = 5151800;
-- c_payment_id nulo


-- Faturas linhas 
select cil.user1_id ,cil.user2_id, cil.linenetamt ,totallines,
* from c_invoiceline cil
	left join c_invoice ci on ci.c_invoice_id =cil.c_invoice_id 
where ci.dateacct between '2024-11-01' and '2024-11-30'
	and ci.c_bpartner_id = 5151800;

-- Pagamentos 
select cp.c_invoice_id , cp.c_payment_id ,cp.user1_id , cp.user2_id , cp.datetrx,cp.payamt,cp.isreceipt, cp.docstatus , cp.c_charge_id ,cp.c_invoicepayschedule_id ,
* from c_payment cp
where cp.datetrx  between '2024-11-01' and '2024-11-30'
	and cp.c_bpartner_id = 5151800;

--Alocação de pagamentos linhas
 select  ca.c_allocationhdr_id,cal.c_payment_id,cal.c_invoice_id,cal.c_invoice_id,cal.c_invoicepayschedule_id,
 	cal.amount,cal.writeoffamt,cal.discountamt,
 * from c_allocationline cal
 	left join c_allocationhdr ca on cal.c_allocationhdr_id = ca.c_allocationhdr_id 
where ca.datetrx between '2024-11-01' and '2024-11-30'
	and cal.c_bpartner_id = 5151800;


--Alocação de pagamentos 
select * from c_allocationhdr ca
where ca.datetrx between '2024-11-01' and '2024-11-30';

--Extrato linhas
select cbkl.ad_org_id ,cbkl.c_payment_id ,cbkl.c_invoice_id ,cbkl.trxamt,
* from c_bankstatementline cbkl
where cbkl.dateacct between '2024-11-01' and '2024-11-30'
	and cbkl.isactive  = 'Y' --registro ativo
	and cbkl.c_bpartner_id  = 5151800;
 
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
	and ci.c_bpartner_id = 5151800
order by cips.c_invoice_id;
	--and cips.c_payment_id not in (null,0);

--Extrato linhas com inner joins para rastreamento de pagamentos antecipados 
 select ci.user1_id ,ci.user2_id , cal.amount, cbkl.trxamt,
 * from c_bankstatementline cbkl
  	left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id 
  	left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id 
  where cbkl.c_bpartner_id = 5151800 and cbkl.dateacct between '2024-11-01' and '2024-12-30';
 
--Extrato linhas com inner joins para rastreamento de pagamentos antecipados 
select cbkl.c_payment_id, cbkl.c_payment_id ,cp.c_payment_id,ci.c_invoice_id ,ci.user1_id, cp.user1_id,
	coalesce (ci.user1_id,cp.user2_id ,ci.user2_id,cp.user2_id,0) as cc_valid,cp.cof_processing3
from c_bankstatementline cbkl
  	left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id 
  	left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id 
  	left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --cbkl.c_invoice_id 
where cbkl.c_bpartner_id in (5151800)
group by cbkl.c_payment_id, cbkl.c_payment_id ,cp.c_payment_id,
		ci.c_invoice_id ,ci.user1_id,cp.c_payment_id;

--devoluções 
select * from m_rma mr;
select * from m_rmaline mrl;

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
select cp.c_bpartner_id, cb.name,cp.description,cp.docstatus,cp.reversal_id,
	sum(case 
			when cp.isreceipt = 'N' and cp.payamt > 0 
			then cp.payamt*-1 else 0 end) 
		as Devolucao_Estorno_Cancel,
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
		as Dif
from c_payment cp
	left join c_bpartner cb on cb.c_bpartner_id = cp.c_bpartner_id --parceiros
where cp.datetrx  between '2024-11-01' and '2024-11-30'
	--and cp.c_bpartner_id in  (5125433,5154905,5142112,5154338,5155113,5092534)
	and cp.docstatus not in ('RE')
	and cp.reversal_id is null
	--and (cp.description not like ('%^%') or cp.description not like ('%<%') or cp.description not like ('%>%'))
group by cp.c_bpartner_id, cb.name,cp.description,cp.docstatus,cp.reversal_id
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
order by cb.name;
