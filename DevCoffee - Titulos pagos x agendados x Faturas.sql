-- Empresas 
select * from ad_org ao ;

-- Extrato bancario 
select 
	cba."name" ,
* from c_bankstatement cbk 
	left join c_bankstatementline cbkl on cbk.c_bankstatement_id = cbkl.c_bankstatement_id
	left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id 
	where cbk.ad_client_id = 5000017 -- codigo cliente 
	and cbk.ad_org_id  = 5000050 -- codigo empresa
	and cbk.c_bankaccount_id = 5000220 -- bancos
	and cbk.isactive  = 'Y' --registro ativo
	and cbk.docstatus  in ('CO','CL')
	and cbk.statementdate between '2024-02-01' and '2024-02-29' --datas
	--and cbk.c_bankstatement_id = 5012848
	order by cbk.c_bankstatement_id  ;

--Extrato linhas
select cbkl.ad_org_id ,cbkl.c_payment_id ,cbkl.c_invoice_id ,cbkl.trxamt,
* from c_bankstatementline cbkl
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
where cbkl.dateacct between '2024-02-01' and '2024-02-29'
	and cbkl.isactive  = 'Y' --registro ativo
	and cbkl.ad_org_id = 5000050 -- organizacao
	and cbk.c_bankaccount_id = 5000220 -- bancos
	--and cbkl.c_bpartner_id  = 5151800;
 


--Somas 
-- Soma
--Extrato bancario linhas e demais  Joins 
select 
	SUM(cbkl.trxamt) AS Geral, -- Soma geral de todas as transações
    SUM(CASE WHEN cbkl.trxamt > 0 THEN cbkl.trxamt ELSE 0 END) AS Receita, -- Soma apenas dos valores positivos
    SUM(CASE WHEN cbkl.trxamt < 0 THEN cbkl.trxamt ELSE 0 END) AS Despesas -- Soma apenas dos valores negativos
from c_bankstatementline cbkl --extrato bancario linhas
	--left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --pagamentos 
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	--left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id --bancos 
	--left join c_invoice ci on ci.c_invoice_id = cbkl.c_invoice_id --faturas
	--left join ad_org ao on ao.ad_org_id  = ci.ad_org_id -- empresas 
	--left join c_bpartner cb on cb.c_bpartner_id = ci.c_bpartner_id --parceiros
	--left join c_elementvalue cc on cc.c_elementvalue_id = ci.user1_id  --centro de custo
	--left join c_invoicepayschedule cips on ci.c_invoice_id = cips.c_invoice_id -- agendamentos de pagamentos 
	--left join c_doctype cdoc on cdoc.c_doctype_id  = cp.c_doctype_id --tipod de documentos
	--left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --Itens da Fatura
where cbkl.ad_client_id = 5000017
	and cbkl.ad_org_id  = 5000050 -- codigo empresa
	and cbk.c_bankaccount_id = 5000220 -- bancos
	and cbkl.isactive  = 'Y' --registro ativo
	--and cbkl.trxamt < 0 --movimentos negativos pagamentos 
	and cbkl.dateacct between '2024-01-01' and '2024-01-31' --intervalos de datas
	--and cp.docstatus = 'CO' --vefica se o documento não foi estornado, na linha da conta bancaria não temos essa informação 
	--and cbkl.description is null  --titulos estornados tem esse campo = null 
	--and ci.issotrx  = 'N' -- N = contas a pagar
	--and ci.isactive  = 'Y' --registroo ativo 
	--and ci.ispaid  = 'Y' -- confirmação DE pagamento de titulo 
	--and ci.grandtotal  > 0 -- valores naiores que o 
	--and ci.updated between '2024-11-01' and '2024-11-30' --data da ultima alteração do titulo 
	--and ci.c_payment_id  is not null --validacao pagamento pelo id
	--and ci.ispayschedulevalid = 'Y' --validacao schedule
	--and ci.docstatus = 'CO' -- status documento completos 
	--and cips.dueamt > 0 --valores maiord que 0 
	--and cips.isactive = 'Y' -- registro ativo
	--and cips.ispaid  = 'Y' -- titulo pago 
	--and cips.duedate between '2024-11-01' and '2024-11-30' -- data de pagamento ou agendamento
	--and cp.isactive = 'Y' --registros ativos 
	--and cp.isreceipt  = 'N' --tipo de transação receita ou despesa 
	--and cp.isreconciled  = 'Y' -- conciliação bancária
	--and cp.c_invoice_id is not null --valida se titulos tem faturas
	--and cp.docstatus  = 'CO'--documentos com status completo 
	--and cp.dateacct  between '2024-11-01' and '2024-11-30'	 --data efetiva do pagamento
	--and cdoc.c_doctype_id not in (5002295,5002296,5002339);

--Extrato bancario linhas - Soma
select
	SUM(cbkl.trxamt) AS Geral, -- Soma geral de todas as transações
    SUM(CASE WHEN cbkl.trxamt > 0 THEN cbkl.trxamt ELSE 0 END) AS Receita, -- Soma apenas dos valores positivos
    SUM(CASE WHEN cbkl.trxamt < 0 THEN cbkl.trxamt ELSE 0 END) AS Despesas -- Soma apenas dos valores negativos
from c_bankstatementline cbkl
	--left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --pagamentos
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	--left join c_doctype cdoc on cdoc.c_doctype_id  = cbk.c_doctype_id --tipod de documentos
	where cbkl.ad_client_id = 5000017
	and cbkl.ad_org_id  = 5000050 -- codigo empresa
	and cbk.c_bankaccount_id In (5000220) -- bancos 5000392
	and cbkl.isactive  = 'Y' --registro ativo
	--and cp.docstatus not in ('RE') --titulos estornados na cp payment
	and cbkl.dateacct between '2024-01-01' and '2024-01-31';
	--and cbkl.trxamt > 0 --movimentos negativos pagamentos 
	--and cp.user1_id  not in (5041412)
	--and cbkl.c_bpartner_id in (5056231)
	 --intervalos de datas
	--and cbkl.description  is null
	--and cp.c_doctype_id not in(5002296,5002295)
	--and cp.docstatus  = 'CO'
	--and cp.c_charge_id > 0::numeric
	--and cp.docstatus in ('CO','CL');

--Extrato bancario cabecalho -- Soma	
select 
	SUM(cbk.statementdifference) AS Geral, -- Soma geral de todas as transações
    SUM(CASE WHEN cbk.statementdifference > 0 THEN cbk.statementdifference ELSE 0 END) AS Receita_Dif, -- Soma apenas dos valores positivos
    SUM(CASE WHEN cbk.statementdifference < 0 THEN cbk.statementdifference ELSE 0 END) AS Despesas_Dif, -- Soma apenas dos valores negativos
    SUM(CASE WHEN cbk.beginningbalance > 0 THEN cbk.beginningbalance ELSE 0 END) as Inicial_Pos, -- saldos iniciais 
    SUM(CASE WHEN cbk.beginningbalance < 0 THEN cbk.beginningbalance ELSE 0 END) as Inicial_Neg, -- saldos iniciais 
    SUM(CASE WHEN cbk.endingbalance > 0 THEN cbk.endingbalance ELSE 0 END) as Final_Pos, -- saldos fim 
    SUM(CASE WHEN cbk.endingbalance < 0 THEN cbk.endingbalance ELSE 0 END) as Final_Neg, -- saldos fim 
    SUM(CASE WHEN cbk.beginningbalance + cbk.endingbalance > 0 THEN cbk.endingbalance ELSE 0 END) as Saldo -- saldos iniciais - finais 
from c_bankstatement cbk 
	--left join c_bankstatementline cbkl on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato vancario linhas
	left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id --bancos 
	--left join c_bankstatementline cbkl on cbkl.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	where cbk.ad_client_id = 5000017
	and cbk.ad_org_id  = 5000050 -- codigo empresa
	and cbk.c_bankaccount_id = 5000220 -- bancos
	and cbk.isactive  = 'Y' --registro ativo
	and cbk.isactive  = 'Y' --registro ativo
	and cbk.docstatus  in ('CO','CL')
	and cbk.statementdate between '2024-01-01' and '2024-01-31' --datas;




-- Faturas a pagar 
select ci.ad_org_id , ao."name", ci.c_bpartner_id, cb."name" ,
ci.grandtotal, ci.c_invoice_id ,ci.documentno,
ci.c_payment_id, ci.user1_id, ci.ispayschedulevalid , ci.ispaid, ci.issotrx,
* from c_invoice ci
	left join c_bpartner cb on cb.c_bpartner_id = ci.c_bpartner_id --fornecedor / cliente 
	left join ad_org ao on ao.ad_org_id  = ci.ad_org_id -- empresas 
where  ci.ad_client_id = 5000017 -- codigo cliente 
	and ci.ad_org_id  = 5000049 -- codigo empresa 
	and ci.issotrx  = 'N' -- N = contas a pagar
	and ci.isactive  = 'Y' --registroo ativo 
	and ci.ispaid  = 'Y' -- confirmação de pagamento de titulo 
	and ci.grandtotal  > 0 -- valores naiores que o 
	and ci.updated between '2024-11-01' and '2024-11-30' --data da ultima alteração do titulo 
	and ci.c_payment_id  is not null --validacao pagamento pelo id
	and ci.ispayschedulevalid = 'Y' --validacao schedule
	and ci.docstatus = 'CO' --valida status de documento completo
order by ci.ad_org_id;

-- Agendamento das faturas 
select ci.ad_org_id , ao."name", ci.c_bpartner_id, cb."name" ,
	cips.c_invoice_id , cips.c_payschedule_id, cips.c_payment_id, cips.dueamt, 
	ci.ispaid,
* from c_invoicepayschedule cips
	left join c_invoice ci on ci.c_invoice_id  = cips.c_invoice_id --faturas 
	left join c_bpartner cb on cb.c_bpartner_id = ci.c_bpartner_id --fornecedor / cliente 
	left join ad_org ao on ao.ad_org_id  = ci.ad_org_id -- empresas 
where cips.ad_client_id = 5000017
	and cips.ad_org_id  = 5000049 -- codigo empresa 
	and ci.issotrx  = 'N' --titulos de contas a pagar 
	and cips.dueamt > 0 --valores maiord que 0 
	and cips.isactive = 'Y' -- registro ativo
	and cips.ispaid  = 'Y' -- titulo pago 
	and cips.duedate between '2024-11-01' and '2024-11-30';
	--and ci.ispayschedulevalid = 'Y';

-- Pagamentos 
select cp.c_charge_id,cp.isreceipt ,cb."name" , cp.c_doctype_id , cdoc."name" , cp.user1_id ,
	coalesce(ci.user1_id,0) as ci_user1_id, coalesce(cil.user1_id,0) as cil_user1_id,
	coalesce(ci.user1_id,cil.user1_id,0) as cc, cc.name,
 * from c_payment cp 
	left join c_bpartner cb on cb.c_bpartner_id = cp.c_bpartner_id --fornecedor / cliente 
	left join c_doctype cdoc on cdoc.c_doctype_id  = cp.c_doctype_id --tipos de documentos
	left join c_invoice ci on  cp.c_payment_id = ci.c_payment_id --faturas
	left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --Itens da Fatura
	left join c_elementvalue cc on cc.c_elementvalue_id = cp.user1_id --cc
	left join c_elementvalue cccp on cccp.c_elementvalue_id = ci.user1_id --cc titulos 
where cp.ad_client_id = 5000017
	--and cp.ad_org_id  = 5000049 -- codigo empresa 
	--and cp.c_payment_id  in (5378751,5379173,5381920)
	and cp.isactive = 'Y' --registros ativos 
	and cp.c_charge_id is not null
	--and cp.isreceipt  = 'Y' --tipo de transação receita ou despesa 
	and cp.isreconciled  = 'Y' -- conciliação bancária
	--and cp.c_invoice_id is not null --valida se titulos tem faturas
	and cp.docstatus  In ('CO','CL')--documentos com status completo 
	--and cp.payamt  < 0 
	and cp.dateacct  between '2024-11-01' and '2024-11-30'
	--and cp.c_doctype_id not in (5002295,5002296,5002339)
order by cp.c_doctype_id , cdoc."name";
	
--Alocação de pagamentos 
select * from c_allocationline cal
	left join c_allocationhdr ca on ca.c_allocationhdr_id = cal.c_allocationhdr_id 
	left join c_allocationline call on call.c_charge_id is not null 
									and call.c_allocationhdr_id = cal.c_allocationhdr_id 
     								and abs(call.amount) = abs(cal.amount) --alocação de pagamentos linhas 
where cal.ad_client_id = 5000017 -- cliente
		and cal.c_payment_id is not null  --valida de pagamento não é nulo 
		and cal.c_invoice_id is null --valida se a fatura é nula
		and cal.c_order_id is null --valida se a ordem é nula 
		and call.c_allocationline_id is not null 
  		and ca.docstatus in ('CO','CL')
  		and ca.dateacct between ('2024-11-01') and ('2024-11-30')


-- Titulos
-- Pagamentos 
select 
	cp.ad_org_id , ao."name", cp.c_bpartner_id, cb."name" ,
	cba.c_bankaccount_id , cba."name" ,cc.c_elementvalue_id , cc."name" , cp.isreconciled,
	cp.c_doctype_id , cdoc.name, 
	cp.payamt , cp.isreceipt , cp.dateacct , cp.c_invoice_id , cp.isactive, cp.isreconciled, cp.isallocated ,
	cp.user1_id , ci.user1_id , cc."name", cccp."name",
* from c_payment cp
	left join c_bpartner cb on cb.c_bpartner_id = cp.c_bpartner_id --fornecedor / cliente 
	left join ad_org ao on ao.ad_org_id  = cp.ad_org_id -- empresas
	left join c_invoice ci on  cp.c_payment_id = ci.c_payment_id --faturas
	left join c_elementvalue cc on cc.c_elementvalue_id = ci.user1_id --cc
	left join c_elementvalue cccp on cccp.c_elementvalue_id = ci.user1_id --cc titulos 
	left join c_invoicepayschedule cips on ci.c_invoice_id = cips.c_invoice_id --agendamentos de pagamentos 
	left join c_bankstatementline cbkl on cp.c_payment_id  = cbkl.c_payment_id --pagamentos
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id --bancos  
	left join c_doctype cdoc on cdoc.c_doctype_id  = cp.c_doctype_id --tipos de documentos 
where cp.ad_client_id = 5000017
	--and cp.ad_org_id  = 5000049 -- codigo empresa 
	and cp.isactive = 'Y' --registros ativos 
	--and cp.isreceipt  = 'Y' --tipo de transação receita ou despesa 
	and cp.isreconciled  = 'Y' -- conciliação bancária
	--and cp.c_invoice_id is not null --valida se titulos tem faturas
	and cp.docstatus  = 'CO'--documentos com status completo 
	and cp.dateacct  between '2024-11-01' and '2024-11-30';
	--and ci.issotrx  = 'N' -- N = contas a pagar
	--and ci.isactive  = 'Y' --registroo ativo 
	--and ci.ispaid  = 'Y' -- confirmação DE pagamento de titulo 
	--and ci.grandtotal  > 0 -- valores naiores que o 
	--and ci.updated between '2024-11-01' and '2024-11-30' --data da ultima alteração do titulo 
	--and ci.c_payment_id  is not null --validacao pagamento pelo id
	--and ci.ispayschedulevalid = 'Y' --validacao schedule
	--and ci.docstatus = 'CO' -- status documento completos 
	--and cips.dueamt > 0 --valores maiord que 0 
	--and cips.isactive = 'Y' -- registro ativo
	--and cips.ispaid  = 'Y' -- titulo pago 
	--and cips.duedate between '2024-11-01' and '2024-11-30' -- data de pagamento ou agendamento
	--and cp.isactive = 'Y' --registros ativos 
	--and cp.isreceipt  = 'N' --tipo de transação receita ou despesa 
	--and cp.isreconciled  = 'Y' -- conciliação bancária
	--and cp.c_invoice_id is not null --valida se titulos tem faturas
	--and cp.docstatus  = 'CO'--documentos com status completo 
	--and cp.dateacct  between '2024-11-01' and '2024-11-30'; --data efetiva do pagamento ;

	
-- Faturas sem cc
select user1_id ,* from c_invoice ci 
where ci.c_invoice_id  = 5302545;

--Faturas itens sem cc
select user1_id ,* from c_invoiceline cil 
where cil.c_invoice_id  = 5302545;

select * from c_elementvalue ce ;

-- Script com os Left Joins

-- Faturas a pagar 
select   
	ci.ad_org_id , ao."name", ci.c_bpartner_id, cb."name" ,
	ci.c_invoice_id ,ci.documentno , cp.isreconciled,
	ci.grandtotal, cips.dueamt , cp.payamt ,
	cips.duedate, cp.dateacct ,
	ci.c_payment_id, ci.user1_id, cc."name" ,
	ci.ispaid,
	case 
		when ci.ispaid = 'Y'
		then 'Pago' 
		else 'Não Pago'
	end as tipo_fat,
	ci.issotrx, 
	case 
		when ci.issotrx = 'N'
		then 'CAP' 
		else ''
	end as tipo_fat,
	coalesce(ci.user1_id,cil.user1_id,0) as cc,
	coalesce(cc."name",cccil."name",'SEM CC') as cc_des,
	ci.infnfe_id,
* from c_invoice ci
	left join ad_org ao on ao.ad_org_id  = ci.ad_org_id -- empresas 
	left join c_bpartner cb on cb.c_bpartner_id = ci.c_bpartner_id --parceiro 
	left join c_elementvalue cc on cc.c_elementvalue_id = ci.user1_id --centro de custo
	left join c_invoicepayschedule cips on ci.c_invoice_id = cips.c_invoice_id --agendamentos de pagamentos 
	left join c_payment cp on  cp.c_payment_id = ci.c_payment_id -- pagamentos de titulos
	left join c_bankstatementline cbkl on cp.c_payment_id  = cbkl.c_payment_id --pagamentos
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id --bancos
	left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --Itens da Fatura 
	left join c_elementvalue cccil on cccil.c_elementvalue_id = cil.user1_id --centro de custo fatura itens
where
	ci.ad_client_id = 5000017 -- codigo cliente 
	--and ci.ad_org_id  = 5000049 -- codigo empresa
	and ci.issotrx  = 'N' -- N = contas a pagar
	and ci.isactive  = 'Y' --registroo ativo 
	and ci.ispaid  = 'Y' -- confirmação de pagamento de titulo 
	and ci.grandtotal  > 0 -- valores naiores que o 
	and ci.updated between '2024-11-01' and '2024-11-30' --data da ultima alteração do titulo 
	and ci.c_payment_id  is not null --validacao pagamento pelo id
	and ci.ispayschedulevalid = 'Y' --validacao schedule
	and ci.docstatus = 'CO' -- status documento completos 
	and cips.dueamt > 0 --valores maiord que 0 
	and cips.isactive = 'Y' -- registro ativo
	and cips.ispaid  = 'Y' -- titulo pago 
	and cips.duedate between '2024-11-01' and '2024-11-30' -- data de pagamento ou agendamento
	and cp.isactive = 'Y' --registros ativos 
	and cp.isreceipt  = 'N' --tipo de transação receita ou despesa 
	and cp.isreconciled  = 'Y' -- conciliação bancária
	and cp.c_invoice_id is not null --valida se titulos tem faturas
	and cp.docstatus  = 'CO'--documentos com status completo 
	and cp.dateacct  between '2024-11-01' and '2024-11-30' --data efetiva do pagamento 
order by ci.c_invoice_id;

-- Bancos 
select * from c_bankaccount cba; 

-- Mapeamento Bancos/Contabil 
select * from c_bankaccount_acct cbaa ;

-- CC 
select * from c_elementvalue_trl cet;

select * from c_bankaccount cb 
where ad_org_id  = 5000047;


--Extrato bancario linhas em produção 
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
  						--cbkl.c_payment_id = 5300359
  				group by cbkl.c_payment_id, cacicil_cc), --essa subquery analisa as alocações de pagamentos adiantados e rerorna os cc usados nas faturas que usaram seus creditos 
  	ci_temp as (select 
   					cal.c_payment_id,
    				string_agg(ci.c_invoice_id::TEXT, ', ') as invoice_list
				FROM c_bankstatementline cbkl --extrato bancario linhas 
						left join c_allocationline cal on cal.c_payment_id = cbkl.c_payment_id --alocação de pagamentos 
						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
				group by cal.c_payment_id) --essa subquery retorna a lista das faturas que foram pagas com o crédito antecipado em forma de linha para não somar os itens repetidos
select
	 cbkl.dateacct ,ao.ad_org_id , ao."name", cba.c_bankaccount_id , cba."name" , cb.c_bpartner_id ,cb."name" , cc.c_elementvalue_id , cc."name" ,
	 cdoc.c_doctype_id ,cdoc."name" ,cp.user1_id ,cp.user2_id , cbkl.trxamt , cbk.beginningbalance , cbk.endingbalance ,
	 cp.isreceipt ,
	 case when cbkl.trxamt > 0 then 'Entrada'
	 		when cbkl.trxamt < 0 then 'Saida'
	 end  as Tipo_Transacao, 
	 cical.invoice_list as invoice_list,
	 cp.user1_id,cp.user2_id,ci.user1_id,ci.user2_id,cil.user1_id,cil.user2_id,cilcc.cil_cc,calant.cacicil_cc,
* from c_bankstatementline cbkl
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
	and cbkl.ad_org_id  = 5000047 -- codigo empresa
	and cbk.c_bankaccount_id In (5000210,5000219) -- bancos  5000392
	and cbkl.isactive  = 'Y' --registro ativo
	and cbkl.dateacct between '2024-11-01' and '2024-11-30'
	--and cbkl.c_bpartner_id = 5144081
	and cp.docstatus not in ('RE') --titulos estornados na cp payment
	and cc.c_elementvalue_id is null
	order by cba.c_bankaccount_id,cbkl.c_bankstatementline_id ;
	--and cbkl.trxamt > 0 --movimentos negativos pagamentos 
	--intervalos de datas
	--and cbkl.description  is null 
	--and cp.docstatus  = 'CO'
	--and cdoc.c_doctype_id not in(5002296,5002295)
	--and cp.user1_id in (5041412)
	--and cbkl.c_bpartner_id = 5056231
	--and cp.c_charge_id > 0::numeric

	
-- Pagamentos -- Soma 
select
	SUM(cp.payamt) AS Geral, -- Soma geral de todas as transações
    SUM(CASE WHEN cp.isreceipt = 'Y' THEN cp.payamt ELSE 0 END) AS Receita, -- Soma apenas dos valores positivos
    SUM(CASE WHEN cp.isreceipt = 'N' THEN cp.payamt ELSE 0 END) AS Despesas -- Soma apenas dos valores negativos
from c_payment cp 
	left join c_bpartner cb on cb.c_bpartner_id = cp.c_bpartner_id --fornecedor / cliente 
where cp.ad_client_id = 5000017
	--and cp.ad_org_id  = 5000049 -- codigo empresa 
	and cp.isactive = 'Y' --registros ativos 
	--and cp.isreceipt  = 'Y' --tipo de transação receita ou despesa 
	and cp.isreconciled  = 'Y' -- conciliação bancária
	--and cp.c_invoice_id is not null --valida se titulos tem faturas
	and cp.docstatus  In ('CO','CL')--documentos com status completo 
	and cp.c_charge_id > 0::numeric --naturezas financeiras 
	--and cp.user1_id not in (999999)
	--and cp.payamt  < 0 
	--and cp.c_doctype_id not in (5002295,5002296,5002339,5002340,5002342) --tipos de documentos 
	and cp.dateacct  between '2024-11-01' and '2024-11-30';

--Alocação de pagamentos 
select
	SUM(cal.amount) AS Geral, -- Soma geral de todas as transações
    SUM(CASE WHEN cal.amount > 0 THEN cal.amount ELSE 0 END) AS Receita, -- Soma apenas dos valores positivos
    SUM(CASE WHEN cal.amount < 0 THEN cal.amount ELSE 0 END) AS Despesas -- Soma apenas dos valores negativos
from c_allocationline cal
	left join c_allocationhdr ca on ca.c_allocationhdr_id = cal.c_allocationhdr_id 
	left join c_allocationline call on call.c_charge_id is not null 
									and call.c_allocationhdr_id = cal.c_allocationhdr_id 
     								and abs(call.amount) = abs(cal.amount) --alocação de pagamentos linhas 
where cal.ad_client_id = 5000017 -- cliente
		and cal.c_payment_id is not null  --valida de pagamento não é nulo 
		and cal.c_invoice_id is null --valida se a fatura é nula
		and cal.c_order_id is null --valida se a ordem é nula 
		and call.c_allocationline_id is not null 
  		and ca.docstatus in ('CO','CL')
  		and ca.dateacct between ('2024-11-01') and ('2024-11-30');



---- Script com os Left Joins
--Extrato bancario linhas e demais  Joins 
with 
	cil_temp as (select ci.c_invoice_id, 
					coalesce(cil.user1_id,0) as cil_cc
				from c_invoiceline cil --faturas linhas
					left join c_invoice ci on cil.c_invoice_id = ci.c_invoice_id --faturas
				group by ci.c_invoice_id,cil_cc), --essa subquery faz consulta dos itens da fatura e retorna centro de custo 
	cal_temp as (select cbkl.c_payment_id, 
					coalesce(ci.user1_id,cil.user1_id,0) as cacicil_cc
  				from c_bankstatementline cbkl
  						left join c_allocationline cal on cal.c_payment_id  = cbkl.c_payment_id --alicação de pagamentos linhas
  						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
  						left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --faturas linhas
  				group by cbkl.c_payment_id, cacicil_cc), --essa subquery analisa as alocações de pagamentos adiantados e rerorna os cc usados nas faturas que usaram seus creditos 
  	ci_temp as (select 
   					cal.c_payment_id,
    				string_agg(ci.c_invoice_id::TEXT, ', ') as invoice_list
				FROM c_bankstatementline cbkl --extrato bancario linhas 
						left join c_allocationline cal on cal.c_payment_id = cbkl.c_payment_id --alocação de pagamentos 
						left join c_invoice ci on cal.c_invoice_id = ci.c_invoice_id --faturas
				group by cal.c_payment_id) --essa subquery retorna a lista das faturas que foram pagas com o crédito antecipado em forma de linha para não somar os itens repetidos
select
	cp.ad_org_id , ao."name", cp.c_bpartner_id, cb."name" , cp.c_doctype_id , cdoc."name" ,
	cba.c_bankaccount_id , cba."name" ,
	coalesce(cp.user1_id, ci.user1_id,cil.cil_cc,cal.cacicil_cc,0), cc.name,
	cp.user1_id, cp.user2_id,
	ci.user1_id, ci.user2_id,
	cil.cil_cc,
	cal.cacicil_cc,
	cbkl.c_payment_id, cbkl.c_invoice_id , cical.invoice_list as invoice_list,
	cp.isreconciled,
	cp.payamt , cbkl.trxamt, cp.isreceipt , cp.dateacct , cp.c_invoice_id , cp.isactive, cp.isreconciled, cp.isallocated,
	cp.isreconciled,
* from c_bankstatementline cbkl --extrato bancario linhas
	left join c_payment cp on cp.c_payment_id  = cbkl.c_payment_id --pagamentos 
	left join c_bankstatement cbk on cbk.c_bankstatement_id = cbkl.c_bankstatement_id --extrato bancario 
	left join c_bankaccount cba on cba.c_bankaccount_id = cbk.c_bankaccount_id --bancos 
	left join c_invoice ci on ci.c_invoice_id = cbkl.c_invoice_id --faturas
	left join ad_org ao on ao.ad_org_id  = cbkl.ad_org_id -- empresas 
	left join c_bpartner cb on cb.c_bpartner_id = cbkl.c_bpartner_id --parceiros
	--####left join c_invoicepayschedule cips on ci.c_invoice_id = cips.c_invoice_id -- agendamentos de pagamentos 
	left join c_doctype cdoc on cdoc.c_doctype_id  = cp.c_doctype_id --tipos de documentos
	left join cil_temp cil on cil.c_invoice_id = ci.c_invoice_id --Itens da Fatura
	left join cal_temp cal on cal.c_payment_id = cbkl.c_payment_id -- alocação de pagamentos 
	left join c_elementvalue cc on cc.c_elementvalue_id = coalesce(cp.user1_id, ci.user1_id, cil.cil_cc,cal.cacicil_cc,0)  --centro de custo
	left join ci_temp cical on cical.c_payment_id = cbkl.c_payment_id -- Faturas pagas com credito antecioado
where cbkl.ad_client_id = 5000017
	and cbkl.ad_org_id  = 5000050 -- codigo empresa
	and cbk.c_bankaccount_id = 5000220 -- bancos
	--and cbkl.c_bpartner_id  = 5055671
	and cbkl.isactive  = 'Y' --registro ativo
	--and cp.c_doctype_id  in (5002294,5002293)
	--and cbkl.trxamt < 0 --movimentos negativos pagamentos 
	and cbkl.dateacct between '2024-01-01' and '2024-01-31' --intervalos de datas
	--and cp.docstatus = 'CO' --vefica se o documento não foi estornado, na linha da conta bancaria não temos essa informação 
	--and cbkl.description is null  --titulos estornados tem esse campo = null 
	--and ci.issotrx  = 'N' -- N = contas a pagar
	--and ci.isactive  = 'Y' --registroo ativo 
	--and ci.ispaid  = 'Y' -- confirmação DE pagamento de titulo 
	--and ci.grandtotal  > 0 -- valores naiores que o 
	--and ci.updated between '2024-11-01' and '2024-11-30' --data da ultima alteração do titulo 
	--and ci.c_payment_id  is not null --validacao pagamento pelo id
	--and ci.ispayschedulevalid = 'Y' --validacao schedule
	--and ci.docstatus = 'CO' -- status documento completos 
	--and cips.dueamt > 0 --valores maiord que 0 
	--and cips.isactive = 'Y' -- registro ativo
	--and cips.ispaid  = 'Y' -- titulo pago 
	--and cips.duedate between '2024-11-01' and '2024-11-30' -- data de pagamento ou agendamento
	--and cp.isactive = 'Y' --registros ativos 
	--and cp.isreceipt  = 'N' --tipo de transação receita ou despesa 
	--and cp.isreconciled  = 'Y' -- conciliação bancária
	--and cp.c_invoice_id is not null --valida se titulos tem faturas
	--and cp.docstatus  = 'CO'--documentos com status completo 
	--and cp.dateacct  between '2024-11-01' and '2024-11-30' --data efetiva do pagamento 
	--and cdoc.c_doctype_id not in (5002295,5002296) --tipos de documentos 
order by cbkl.c_bankstatementline_id ;


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
	 CONCAT(CAST(cbkl.dateacct AS TEXT), CAST(cbkl.c_bankstatementline_id AS TEXT)) AS orderby,*
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
where cbkl.dateacct between '2024-02-01' and '2024-02-29'
	and cbkl.isactive  = 'Y' --registro ativo
	and cbkl.ad_org_id = 5000050 -- organizacao
	and cbk.c_bankaccount_id = 5000220 -- bancos
	and cbkl.trxamt  = 2119.14
	--and cbkl.c_bpartner_id  = 5151800;
 
order by organizacao_cod,banco_id,orderby
--Consulta principal de receita e despesas 
--Fim
--##########################################################################################################################################


