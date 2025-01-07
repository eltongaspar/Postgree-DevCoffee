--Elementos de custos 
select * from m_costelement mce;

-- ARM Cliente e Fornecedor 
select * from m_rma mr ;

-- Pagamentos alocação 
select * from c_allocationhdr ca 

--atividades financeiras 
select * from c_activity ca ;

--lançamentos específicos de cobranças ou encargos. 
select * from c_charge cc ;

--plano financeiro 
select * from cof_c_planofinanceiro ccp ;

--visao financeira de alocamentos de pagamentos 
select * from rv_allocation ra ;

-- contas bancariias 
select * from c_bankaccount cbk 
where c_bankaccount_id  In (5000219,5000392);

--empresas 
select * from ad_org ao 
where ad_org_id = 5000047;

-- estoque 
select * from m_storage ms
where ms.isactive  = 'Y' and ms.qtyonhand > 0
and ms.ad_client_id  = 5000017 ;

--Custos
select * from  m_cost mc
where mc.ad_client_id = 5000017 and mc.isactive  = 'Y'
and mc.currentcostprice  > 0 
and mc.currentqty > 0
order by mc.m_product_id;

-- Custos detalhes 
select * from m_costdetail mc
where mc.ad_client_id = 5000017 and mc.isactive  = 'Y';

select * from m_inventory mi
where mi.isactive  = 'Y' and mi.docstatus  = 'CO'
and mi.ad_client_id = 5000017;

-- Ajuste de estoque - estoque de uso interno lnhas 
select * from m_inventoryline mil
where mil.isactive  = 'Y'
and mil.ad_client_id = 5000017;

-- Soma dos itens - ajustes de inventário 
select mil.m_product_id, sum(mil.qtybook) as qtybook, sum(mil.qtycount) as qtycount
from m_inventory mi
	left join m_inventoryline mil on mil.m_inventory_id  = mi.m_inventory_id 
where mi.isactive  = 'Y' and mi.docstatus  = 'CO' and mil.isactive  = 'Y'
and mi.ad_client_id = 5000017
group by mil.m_product_id
order by mil.m_product_id;

-- Movimentações de estoque 
select * from m_movement mm
where mm.isactive  = 'Y' and mm.docstatus  = 'CO'
and mm.ad_client_id = 5000017;

-- Confirmação Movimentações de estoque --sem uso
select * from m_movementconfirm mmc
where mmc.ad_client_id = 5000017;

-- -- Confirmação Movimentações de estoque linhas  --sem uso
select * from m_movementlineconfirm mmcl
where mmcl.ad_client_id = 5000017;

-- ordem de produçao 
select * from m_production mp
where mp.ad_client_id = 5000017
and mp.isactive  = 'Y'
and mp.docstatus = 'CO';

-- ordem de produçao linhas
select mpl.m_production_id, mpl.m_productionline_id , * from m_productionline mpl
where mpl.ad_client_id = 5000017
and mpl.isactive  = 'Y'
and mpl.m_product_id = 5014780
order by mpl.m_production_id ;

-- Recebimento de materiais e expedição 
select * from m_inout mi
where issotrx = 'N' and docstatus  = 'CO' and mi.isactive  = 'Y'
and mi.ad_client_id = 5000017;

-- Recebimento de materiais e expedição linhas
select mil.c_orderline_id ,* from m_inoutline mil
where mil.ad_client_id = 5000017;

-- join m_inout mi e m_inoutline mil
select mi.m_inout_id ,mi.c_order_id ,mil.movementqty ,mil.qtyentered ,
* from m_inout mi
	left join m_inoutline mil on mi.m_inout_id  = mil.m_inout_id
where mi.issotrx = 'N' and mi.docstatus  = 'CO' and mi.isactive  = 'Y'
and mi.ad_client_id = 5000017;

-- recebimento de materiais e expedição linhas - Soma dos itens 
-- join m_inout mi e m_inoutline mil
select mil.m_product_id ,sum(mil.movementqty) as qtde_nov ,sum(mil.qtyentered) as qtde_entrada
from m_inout mi
	left join m_inoutline mil on mi.m_inout_id  = mil.m_inout_id
where mi.issotrx = 'N' and mi.docstatus  = 'CO' and mi.isactive  = 'Y'
and mi.ad_client_id = 5000017
group by mil.m_product_id ;


-- Confirmaçao de Recebimento  / Entrega -- sem uso
select * from m_inoutconfirm mi
where mi.ad_client_id = 5000017;
-- Confirmaçao de Recebimento  / Entregav linhas -- sem uso
select * from m_inoutlineconfirm mil
where mil.ad_client_id = 5000017;

-- Confrontar Pedido / Fatura
select mm.qty,mm.c_orderline_id , m_product_id , mm.m_inoutline_id , mm.c_invoiceline_id ,
* from m_matchpo mm
where mm.ad_client_id = 5000017;


-- Schemas DevCoffee
SELECT table_schema, table_name 
FROM information_schema.tables
WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;

--Taxas de impostos Brasil
select * from lbr_tax lt
where lt.ad_client_id = 5000017;

--Taxas de impostos linhas Brasil 
select * from lbr_taxline ltl
where ltl.ad_client_id = 5000017;

-- Pedido de compras / Ordens de vendas
select issotrx,* from c_order co
where issotrx = 'N' and docstatus  = 'CO'
and co.ad_client_id = 5000017;

-- Pedido de compras / Ordens de vendas linhas
select * from c_orderline col
where col.ad_client_id = 5000017;


--Faturas 
select totallines ,grandtotal ,user1_id, dateinvoiced, * from c_invoice ci 
where ci.ad_client_id = 5000017
and ci.c_invoice_id = 5313249;

-- Empresas 
select * from ad_org ao ;

-- Fornecedores / Clientes
select  cb.c_bpartner_id ,* from c_bpartner cb
where cb.ad_client_id = 5000017;

-- Itens da Fatura 
select line ,qtyinvoiced ,pricelist ,priceactual, linenetamt , user1_id,created ,* from  c_invoiceline ci3
where ci3.ad_client_id = 5000017
and ci3.c_invoice_id = 5313249;

-- Agendamento de pagemantos da fatura 
select dueamt ,cof_payscheduleno , duedate, * from c_invoicepayschedule ci2 
where ci2.ad_client_id = 5000017
and ci2.c_invoice_id = 5296028
order by 2;

-- Produdos 
select m_product_category_id as Grupo_Contabil, cof_producttype_id as tipo_produto , cof_productclass_id as classe_produto ,
cof_productgroup_id as grupo_produto,
* from m_product m
where m.ad_client_id = 5000017;

-- Categoria de produtos - grupo contabil 
select * from m_product_category mpc
where mpc.ad_client_id = 5000017;

-- Unidades de medida 
select * from c_uom cuom
where cuom.ad_client_id = 5000017;

-- Produtos COF - não usada 
select * from cof_products cp
where cp.ad_client_id = 5000017;

-- Classificação de produto
select  * from cof_productclass cpc
where cpc.ad_client_id = 5000017;

-- Tipos de produtos 
select * from cof_ProductType cp
where cp.ad_client_id = 5000017;

-- Grupos de produtos
select * from cof_productgroup cp
where cp.ad_client_id = 5000017;


-- Produtos, classes, categorias, tipos e grupos 
select mp.m_product_id, mp."name" , mp.m_product_category_id, mpc."name" , mp.cof_productclass_id , cpc.description ,
mp.cof_producttype_id , cpt."name" , mp.cof_productgroup_id , cpg."name" ,
* from m_product mp
	left join m_product_category mpc on mpc.m_product_category_id  = mp.m_product_category_id 
	left join cof_productclass cpc on cpc.cof_productclass_id  = mp.cof_productclass_id
	left join cof_producttype cpt on cpt.cof_producttype_id  = mp.cof_producttype_id
	left join cof_productgroup cpg on cpg.cof_productgroup_id  = mp.cof_productgroup_id
where mp.ad_client_id = 5000017;


-- Produtos, Categorias, Unidades de medidas
select  mp.m_product_category_id,mpc.m_product_category_id,mp."name" ,mpc."name" ,
cuom.c_uom_id, mp.c_uom_id, cuom."name" , cuom.uomsymbol ,
* from m_product mp
left join m_product_category mpc on mp.m_product_category_id = mpc.m_product_category_id
left join c_uom cuom on cuom.c_uom_id = mp.c_uom_id
where mp.ad_client_id = 5000017;
