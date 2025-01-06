-- Script Contas a pagar 
select  ci.c_invoice_id ,extract(month from ci.created) as mes_fat, extract(year from ci.created) as ano_fat, 
extract(month from ci2.duedate) as mes_agendamento, extract(year from ci2.duedate) as ano_agendamento,
ci.documentno ,ci.c_bpartner_id ,ci.user1_id,ci3.user1_id,
ci.grandtotal ,ci.totallines , ci2.dueamt,
-- aqui somo todos os valores dos itens de pagamento por doc
round((select sum(linenetamt) from c_invoiceline cil
		where cil.c_invoice_id = CI.c_invoice_id),2) as total_itens,
-- aqui somo os valores dos agendamentos por doc
round((select sum(dueamt) from c_invoicepayschedule ci2
		where ci2.c_invoice_id = CI.c_invoice_id
		/*and ci2.duedate between '2024-01-01' and '2024-12-31'*/),2) as total_agendado,
--aqui somo as qtde de agendamentos 
round((select count(cof_payscheduleno) from c_invoicepayschedule ci2
		where ci2.c_invoice_id = CI.c_invoice_id),2) as qtde_agendados,
(select count(distinct ci3.user1_id) from c_invoiceline ci3
		where CI3.c_invoice_id = CI.c_invoice_id ) as count_cc_itens,
case --aqui valido faturaxitens pag
	when ci.grandtotal <> round((select sum(linenetamt) from c_invoiceline cil
									where cil.c_invoice_id = CI.c_invoice_id),2)
	then 'XXXXXXX'
	else 'VVVVVVV'
end as FaturaxItens,
case --aqui valido os cc fatxitens pag
	when ci.user1_id <> ci3.user1_id 
	then 'XXXXXXX'
	else 'VVVVVVV'
end as Valid_CC,
case --aqui valido valores faturaxagendamento
	when ci.grandtotal <> round((select sum(dueamt) from c_invoicepayschedule ci2
									where ci2.c_invoice_id = CI.c_invoice_id),2) 
	then 'XXXXXXX'
	else 'VVVVVVV'
end as FaturaxAgendado,
cb."name" , CI.docstatus , ci3.pricelist , ci3.linenetamt ,ci3.linetotalamt, --CI2.duedate
-- em testes 
round((select (sum(linenetamt)) / (sum(qtyinvoiced)) from c_invoiceline cil
		where cil.c_invoice_id = CI.c_invoice_id),2) as total_perct_item,
-- em testes 
round((select sum(qtyinvoiced) from c_invoiceline cil
		where cil.c_invoice_id = CI.c_invoice_id),2) as total_percent_rateio,
case -- aqui valido se existe algum cc em braco 
	when ci.user1_id is null  and ci3.user1_id is null
	then 'XXXXXXX'
	else 'VVVVVVV'
end as valid_cc,
ci3.m_product_id,mp.name,
mp.m_product_category_id,mpc.m_product_category_id,mp."name" ,mpc."name" ,
cuom.c_uom_id, mp.c_uom_id, cuom."name" , cuom.uomsymbol
from c_invoice ci -- Fatura
	left join c_bpartner cb on cb.c_bpartner_id = ci.c_bpartner_id --Fornecedores/Clientes
    left join c_invoiceline ci3 on CI3.c_invoice_id = CI.c_invoice_id --Itens da Fatura
    left join c_invoicepayschedule ci2 on CI2.c_invoice_id = CI.c_invoice_id --Agendamento da fatura 
    left join m_product mp on mp.m_product_id = ci3.m_product_id --Produtos 
    left join m_product_category mpc on mp.m_product_category_id = mpc.m_product_category_id --Categorias de produtos
left join c_uom cuom on cuom.c_uom_id = mp.c_uom_id 
where ci.ad_client_id = 5000017
and ci.created between '2024-11-01' and '2024-11-30'
and ci2.duedate between '2024-11-01' and '2024-11-30'
and ci.issotrx = 'N'
and ci.docstatus = 'CO'
--and mp.m_product_id is null
and cb.c_bpartner_id not in (5133417,5071953,5132880,5132869,5071952,5056739,5055921,5055764)
--and ci.c_invoice_id In (5296028,5295114)
group by ci.c_invoice_id, ci3.user1_id, cb.name, ci3.pricelist, ci3.linenetamt,
ci3.linetotalamt, ci2.dueamt,
extract(month from ci.created), extract(year from ci.created),
extract(month from ci2.duedate), extract(year from ci2.duedate),
ci3.m_product_id,mp.name,
mp.m_product_category_id,mpc.m_product_category_id,mp."name" ,mpc."name" ,
cuom.c_uom_id, mp.c_uom_id, cuom."name" , cuom.uomsymbol
order by 1,2,3,4,5;


-- Mehorias com AI 
with total_itens as (
    select c_invoice_id, sum(linenetamt) as total_itens, sum(qtyinvoiced) as total_qty
    from c_invoiceline
    group by c_invoice_id
),
total_agendado as (
    select c_invoice_id, sum(dueamt) as total_agendado, count(cof_payscheduleno) as qtde_agendados
    from c_invoicepayschedule
    group by c_invoice_id
)
select 
    ci.c_invoice_id,
    extract(month from ci.created) as mes_fat,
    extract(year from ci.created) as ano_fat,
    extract(month from ci2.duedate) as mes_agendamento,
    extract(year from ci2.duedate) as ano_agendamento,
    ci.documentno, cb."name", 
    ci.grandtotal, ci.totallines,
    ti.total_itens,
    ta.total_agendado,
    ta.qtde_agendados,
    case 
        when ci.grandtotal <> ti.total_itens then 'XXXXXXX'
        else 'VVVVVVV'
    end as FaturaxItens,
    case 
        when ci.grandtotal <> ta.total_agendado then 'XXXXXXX'
        else 'VVVVVVV'
    end as FaturaxAgendado
from c_invoice ci
left join total_itens ti on ti.c_invoice_id = ci.c_invoice_id
left join total_agendado ta on ta.c_invoice_id = ci.c_invoice_id
left join c_invoicepayschedule ci2 on ci2.c_invoice_id = ci.c_invoice_id
left join c_bpartner cb on cb.c_bpartner_id = ci.c_bpartner_id
where ci.ad_client_id = 5000017
and ci.created between '2024-11-01' and '2024-11-30'
and ci2.duedate between '2024-11-01' and '2024-11-30'
and ci.docstatus = 'CO'
order by 1, 2;



-- Script Contas a pagar - ajustes
-- aqui somo todos os valores  e contagem dos itens de pagamento por doc
-- o sub sql é usado apenas uma vez por tabela e concentrada todas informações da mesma a fim de economizar tempo e recursos do servidor 
-- SQL Server lida bem com vários sun selects paginando e fazendo joins 
-- Postgree não funciona bem com vários sub sqls, tendo que realizar a pesquisa em um único sbu select e fazer um join com a pesquisa principal
with 
nf_itens_temp as (select cil.c_invoice_id, sum(cil.linenetamt) as total_itens, count(distinct cil.user1_id) as count_cc_itens
				from c_invoiceline cil
				group by cil.c_invoice_id ),
-- aqui somo os valores, contagem dos itens dos agendamentos por doc
agend_pag_temp as (select cis.c_invoice_id, sum(dueamt) as total_agend, count(cof_payscheduleno) as qtde_agend
				from c_invoicepayschedule cis
				group by cis.c_invoice_id)
select  
	ci.c_invoice_id ,
	extract(month from ci.created) as mes_fat, 
	extract(year from ci.created) as ano_fat, 
	extract(month from cis.duedate) as mes_agendamento, 
	extract(year from cis.duedate) as ano_agendamento,
	ci.documentno ,ci.c_bpartner_id ,
	coalesce(ci.user1_id,0) as ci_user1_id, coalesce(cil.user1_id,0) as cil_user1_id,
	coalesce(ci.user1_id,cil.user1_id,0) as cc,
	ci.grandtotal ,ci.totallines , cis.dueamt,
	agend_pag.total_agend,
	nf_itens.total_itens, 
case --aqui valido faturaxitens pag
	when ci.grandtotal <> nf_itens.total_itens then 'XXXXXXX'
	else 'VVVVVVV'
end as FaturaxItens,
case --aqui valido os cc fatxitens pag
	when ci.user1_id <> cil.user1_id 
	then 'XXXXXXX'
	else 'VVVVVVV'
end as Valid_CC,
case --aqui valido valores faturaxagendamento
	when ci.grandtotal <> agend_pag.total_agend
		then 'XXXXXXX'
		else 'VVVVVVV'
end as FaturaxAgendado,
cb."name" , CI.docstatus , cil.pricelist , cil.linenetamt ,cil.linetotalamt,
case -- aqui valido se existe algum cc em braco 
	when ci.user1_id is null  and cil.user1_id is null
	then 'XXXXXXX'
	else 'VVVVVVV'
end as valid_cc,
	cil.m_product_id,mp."name",
	mp.m_product_category_id,mpc.m_product_category_id,mp."name" ,mpc."name" ,
	cuom.c_uom_id, mp.c_uom_id, cuom."name" , cuom.uomsymbol
from c_invoice ci -- Fatura
	left join c_bpartner cb on cb.c_bpartner_id = ci.c_bpartner_id --Fornecedores/Clientes
	left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id --Itens da Fatura
	left join c_invoicepayschedule cis on cis.c_invoice_id = ci.c_invoice_id --Agendamento da fatura 
 	left join m_product mp on mp.m_product_id = cil.m_product_id --Produtos 
 	left join m_product_category mpc on mp.m_product_category_id = mpc.m_product_category_id --Categorias de produtos
	left join c_uom cuom on cuom.c_uom_id = mp.c_uom_id --unidades de madidas
	left join nf_itens_temp nf_itens on nf_itens.c_invoice_id = ci.c_invoice_id -- aqui ligo as tabelas temporarias no inicio with de sub consultas para ligar as principais 
	left join agend_pag_temp agend_pag on agend_pag.c_invoice_id = ci.c_invoice_id
where ci.ad_client_id = 5000017
	and ci.created between '2024-11-01' and '2024-11-30'
	and cis.duedate between '2024-11-01' and '2024-11-30'
	and ci.issotrx = 'N'
	and ci.docstatus = 'CO'
	--and mp.m_product_id is null
	and cb.c_bpartner_id not in (5133417,5071953,5132880,5132869,5071952,5056739,5055921,5055764)
	--and ci.c_invoice_id In (5296028,5295114)
group by 
	ci.c_invoice_id, cil.user1_id, cb.name, cil.pricelist, cil.linenetamt,
	cil.linetotalamt, cis.dueamt,
	extract(month from ci.created), extract(year from ci.created),
	extract(month from cis.duedate), extract(year from cis.duedate),
	cil.m_product_id,mp.name,
	mp.m_product_category_id,mpc.m_product_category_id,mp."name" ,mpc."name" ,
	cuom.c_uom_id, mp.c_uom_id, cuom."name" , cuom.uomsymbol,
	agend_pag.total_agend,nf_itens.total_itens
order by 1,2,3,4,5;



-- Consolidar CTEs e alinhar aliasesq
with nf_itens as (
    select
        cil.c_invoice_id,
        sum(cil.linenetamt) as total_itens,
        count(distinct cil.user1_id) as count_cc_itens
    from c_invoiceline cil
    group by cil.c_invoice_id
),
agend_pag as (
    select
        cis.c_invoice_id,
        sum(cis.dueamt) as total_agend,
        count(cis.cof_payscheduleno) as qtde_agend
    from c_invoicepayschedule cis
    group by cis.c_invoice_id
)
select  
    ci.c_invoice_id,
    extract(month from ci.created) as mes_fat, 
    extract(year from ci.created) as ano_fat, 
    extract(month from cis.duedate) as mes_agendamento, 
    extract(year from cis.duedate) as ano_agendamento,
    ci.documentno,
    ci.c_bpartner_id,
    ci.user1_id,
    ci.grandtotal,
    ci.totallines,
    cis.dueamt,
    cb."name",
    ci.docstatus,
    mp.name as product_name,
    case 
        when ci.grandtotal <> nf.total_itens then 'XXXXXXX'
        else 'VVVVVVV'
    end as faturaxitens,
    case 
        when ci.user1_id <> cil.user1_id then 'XXXXXXX'
        else 'VVVVVVV'
    end as valid_cc
    from c_invoice ci
left join nf_itens nf on nf.c_invoice_id = ci.c_invoice_id
left join agend_pag ag on ag.c_invoice_id = ci.c_invoice_id
left join c_bpartner cb on cb.c_bpartner_id = ci.c_bpartner_id
left join c_invoiceline cil on cil.c_invoice_id = ci.c_invoice_id
left join c_invoicepayschedule cis on cis.c_invoice_id = ci.c_invoice_id
left join m_product mp on mp.m_product_id = cil.m_product_id
where ci.ad_client_id = 5000017
  and ci.created between '2024-11-01' and '2024-11-30'
  and cis.duedate between '2024-11-01' and '2024-11-30'
  and ci.issotrx = 'N'
  and ci.docstatus = 'CO'
  and cb.c_bpartner_id not in (5133417, 5071953, 5132880, 5132869, 5071952, 5056739, 5055921, 5055764)
order by 1, 2, 3, 4, 5;


/*
select * from c_invoiceline ci3
where ci3.c_invoice_id = 5296028;
--and CI.documentno ='1005961'
--and ci.user1_id is null

select ci.c_invoice_id ,ci.created ,ci.documentno ,ci.c_bpartner_id ,ci.grandtotal ,ci.grandtotal ,ci.user1_id  
from c_invoice ci
where ci.ad_client_id =5000017 and ci.documentno ='1005961';

select ci.c_invoice_id ,ci.created ,ci.documentno ,ci.c_bpartner_id ,ci.grandtotal ,ci.grandtotal ,ci.user1_id  
from c_invoice ci
where ci.ad_client_id =5000017 and ci.documentno ='';
--and ci.user1_id is null  and ci3.user1_id is null*/



