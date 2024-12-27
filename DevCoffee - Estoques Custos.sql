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


--Somas testes
--Pagamentos 
select * from C_Payment cp
where cp.ad_client_id = 5000017;

--Faturas 
select totallines ,grandtotal  from c_invoice ci 
where ci.ad_client_id = 5000017
and ci.c_invoice_id = 5296028;


-- Itens da Fatura 
select sum(qtyinvoiced) qtyinvoiced , sum(linenetamt) linenetamt  from  c_invoiceline ci3
where ci3.ad_client_id = 5000017
and ci3.c_invoice_id = 5296028;

-- Agendamento de pagemantos da fatura 
select sum(dueamt) dueamt ,count(cof_payscheduleno) cof_payscheduleno from c_invoicepayschedule ci2 
where ci2.ad_client_id = 5000017
and ci2.c_invoice_id = 5296028
order by 2;



DO $$
DECLARE
    var_ad_client_id INT := 5000017;
    var_invoice_id INT := 5296028;
    var_totallines INT;
    var_grandtotal NUMERIC;
BEGIN
    -- Armazenando os resultados da consulta em variáveis
    SELECT totallines, grandtotal
    INTO var_totallines, var_grandtotal
    FROM c_invoice ci
    WHERE ci.ad_client_id = var_ad_client_id
      AND ci.c_invoice_id = var_invoice_id;

    -- Exibindo os valores (para fins de debug)
    RAISE NOTICE 'Totallines: %, Grandtotal: %', var_totallines, var_grandtotal;
END $$;

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

-- join c_Order c_oderline
select issotrx, col.m_product_id ,col.c_orderline_id ,col.qtyordered as qtde_pedida , col.qtydelivered as qtde_entregue, col.qtyreserved as qtde_reserva, col.qtyinvoiced as qtde_faturada, 
col.qtyentered qtde_inserida_sistema,
col.linenetamt  as total_liquido,  col.user1_id,
* from c_order co
	left join c_orderline col on co.c_order_id  = col.c_order_id 
where issotrx = 'N' and docstatus  = 'CO' and co.isactive  = 'Y'
and  co.ad_client_id = 5000017
order by co.c_order_id ;

-- Soma dos itens comprados por produtos 
-- join c_Order c_oderline
select 
		col.m_product_id , mp."name" ,sum(col.qtyordered) as qtde_pedida , sum(col.qtydelivered) as qtde_entregue, sum(col.qtyreserved) as qtde_reserva, 
		sum(col.qtyinvoiced) as qtde_faturada, sum(col.qtyentered) qtde_inserida_sistema,
		sum(col.linenetamt)  as total_liquido
from c_order co
	left join c_orderline col on co.c_order_id  = col.c_order_id 
	left join m_product mp on col.m_product_id = mp.m_product_id 
where issotrx = 'N' and docstatus  = 'CO' and co.isactive  = 'Y'
and co.ad_client_id = 5000017
group by col.m_product_id, mp."name" 
order by col.m_product_id;


--issotrx
-- Y para oudem de vendas 
-- N para pedidos de compras

--docstatus 
--DR (Drafted): O documento está em rascunho, ainda não finalizado ou confirmado.
--CO (Completed): O documento foi completado, indicando que todas as ações necessárias foram executadas.
--AP (Approved): O documento foi aprovado por um usuário com permissão.
--NA (Not Approved): O documento foi rejeitado ou não aprovado.
--IN (Inactive): O documento foi desativado.
--CL (Closed): O documento foi fechado, e não são esperadas ações adicionais.
--VO (Voided): O documento foi anulado.
--RE (Reversed): O documento foi revertido, geralmente para corrigir erros.
--PE (Prepared): O documento foi preparado e está pronto para o próximo passo.
--IP (In Progress): O documento está em andamento.
--WP (Waiting for Payment): O documento está aguardando pagamento.
--WC (Waiting for Confirmation): O documento está aguardando confirmação.

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

-- ecebimento de materiais e expedição linhas - Soma dos itens 
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

-- Soma dos itens 
-- Confrontar Pedido / Fatura
select m_product_id, sum(mm.qty)
from m_matchpo mm
where mm.ad_client_id = 5000017
group by m_product_id
order by m_product_id;

-- Ajuste de estoque - estoque de uso interno 
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

-- Somas 
-- ordem de produçao 
select mp.m_product_id, mpp."name", sum(productionqty) from m_production mp
	left join m_product mpp on mpp.m_product_id  = mp.m_product_id 
where mp.ad_client_id = 5000017
and mp.isactive  = 'Y'
and mp.docstatus = 'CO'
group by mp.m_product_id, mpp."name"
order by mp.m_product_id ;

-- ordem de produçao linhas
select mpl.m_product_id, mpp."name", sum(mpl.qtyused) from m_productionline mpl
	left join m_product mpp on mpp.m_product_id = mpl.m_product_id 
where mpl.ad_client_id = 5000017
and mpl.isactive  = 'Y'
group by mpl.m_product_id, mpp."name"
order by mpl.m_product_id;

-- ordem de produçao linhas
select mpl.m_product_id, mpp."name", sum(mpl.movementqty) from m_productionline mpl
	left join m_product mpp on mpp.m_product_id = mpl.m_product_id 
where mpl.ad_client_id = 5000017
and mpl.isactive  = 'Y'
and mpl.movementqty > 0
group by mpl.m_product_id, mpp."name"
order by mpl.m_product_id;


-- Ordem de produção cabeçalho e linhas
select mp.m_production_id, mpl.m_production_id, mpl.m_productionline_id ,mp.m_product_id, mpp."name", mpl.m_product_id, mppl.name,
mp.productionqty, mpl.movementqty, mpl.qtyused, 
* from m_production mp
	left join m_productionline mpl on mp.m_production_id  = mpl.m_production_id
	left join m_product mppl on mppl.m_product_id = mpl.m_product_id 
	left join m_product mpp on mpp.m_product_id = mp.m_product_id 
where mp.ad_client_id = 5000017 
and mp.isactive = 'Y' 
and mpl.movementqty  < 0 
group by mp.m_production_id, mpl.m_production_id, mpl.m_productionline_id, mpp.name, mppl.name, mppl.m_product_id, mpp.m_product_id
--having count(mp.m_production_id) > 3
order by mp.m_production_id, mpl.m_product_id ; 

-- Soma
-- Ordem de produção cabeçalho e linhas
select mp.m_production_id, mpl.m_production_id, mpl.m_productionline_id ,mp.m_product_id, mpp."name", mpl.m_product_id, mppl.name,
sum(mp.productionqty) as mp_productionqty, sum(mpl.movementqty) as mpl_movementqty, sum(mpl.qtyused) as mpl_qtyused
from m_production mp
	left join m_productionline mpl on mp.m_production_id  = mpl.m_production_id
	left join m_product mppl on mppl.m_product_id = mpl.m_product_id 
	left join m_product mpp on mpp.m_product_id = mp.m_product_id 
where mp.ad_client_id = 5000017 
and mp.isactive = 'Y' 
and mpl.movementqty  < 0 
group by mp.m_production_id, mpl.m_production_id, mpl.m_productionline_id, mpp.name, mppl.name, mppl.m_product_id, mpp.m_product_id
having sum(mp.productionqty) - sum(mpl.movementqty) =  0 
order by mp.m_production_id, mpl.m_product_id ; 


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


-- estoque - soma 
select  m_product_id , sum(qtyonhand) from m_storage ms
where ms.isactive  = 'Y' and ms.qtyonhand > 0
and ms.ad_client_id = 5000017
group by m_product_id ;

-- custos geral 
select mc.m_product_id, mc.m_costelement_id , sum(mc.currentqty) as qtde_estoque, sum(currentcostprice) as custo, currentcostprice,
sum(mc.currentqty)*sum(currentcostprice) as custo_geral
from  m_cost mc
where mc.ad_client_id = 5000017 and mc.isactive  = 'Y'
and mc.currentcostprice  > 0 
and mc.currentqty > 0
and mc.m_costelement_id not in (5000084)
group by mc.m_product_id,mc.currentcostprice,mc.m_costelement_id
order by mc.m_product_id;

-- estoques qtde e valor 
select distinct ms.m_product_id, ms.qtyonhand , mc.currentqty,* from m_storage ms
	left join m_cost mc 
	on mc.m_product_id = ms.m_product_id 
where ms.isactive  = 'Y' 
and ms.qtyonhand > 0
and mc.currentcostprice  > 0
and mc.currentqty > 0 
and ms.ad_client_id  = 5000017
and mc.m_costelement_id not in (5000084)
order by ms.m_product_id;

-- estoques qtde e valor - soma 
select distinct 
	ms.m_product_id, mp."name", mc.currentcostprice,
	sum(ms.qtyonhand) as qtde_estoque , mc.currentqty as qtde_estoque_custos,
	(mc.currentqty)*(mc.currentcostprice) as estoque_custo,
	sum(ms.qtyonhand)*(mc.currentcostprice) as custos_geral,
	((mc.currentqty)*(mc.currentcostprice)) - (sum(ms.qtyonhand)*(mc.currentcostprice)) as dif_estoque_custos
from m_storage ms
	left join m_cost mc 
		on mc.m_product_id = ms.m_product_id 
	left join m_product  mp
		on mp.m_product_id  = ms.m_product_id 
where ms.isactive  = 'Y' 
	and ms.qtyonhand > 0
	and mc.currentcostprice  > 0
	and mc.currentqty > 0 
	and ms.ad_client_id  = 5000017
	and mc.m_costelement_id not in (5000084)
group by ms.m_product_id, mc.currentcostprice, mc.currentcostprice, mp."name",mc.currentqty
having ((mc.currentqty)*(mc.currentcostprice)) - (sum(ms.qtyonhand)*(mc.currentcostprice)) <> 0
order by ms.m_product_id;




