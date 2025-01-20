-- adempiere.rv_cof_relatorioregimecaixa_acero fonte

--CREATE MATERIALIZED VIEW adempiere.rv_cof_relatorioregimecaixa_acero
--TABLESPACE pg_default
--EXPLAIN (analyze,COSTS,verbose,BUFFERS,format JSON) -- ANALISE QUERY 
SELECT 'PAGAMENTO_DIRETO_COM_FINALIDADE'::text AS tipo,
    p.ad_client_id,
    p.c_payment_id,
    p.ad_org_id,
    p.c_bpartner_id,
    p.user1_id,
    p.user2_id,
    p.c_activity_id,
    p.c_charge_id,
    0 AS m_product_id,
    p.cof_c_planofinanceiro_id,
    bp.value AS chave_parceiro,
    bp.name AS nome_parceiro,
    cof_getreflistvalue('COF_C_PlanoFinanceiro'::character varying, 'AccountType'::character varying, pf.accounttype::character varying) AS tipo_plano_financeiro,
    pf.value AS chave_plano_financeiro,
    pf.name AS plano_financeiro,
    c.name AS chave_produto_finalidade,
    c.name AS produto_finalidade,
    cc.value AS chave_centro_custo,
    cc.name AS centro_custo,
    cc2.value AS chave_centro_custo2,
    cc2.name AS centro_custo2,
    a.value AS chave_atividade,
    a.name AS atividade,
    sum(
        CASE p.isreceipt
            WHEN 'Y'::bpchar THEN p.payamt
            ELSE p.payamt * '-1'::numeric
        END) AS valor_pagamento,
    p.datetrx AS paydate,
    p.datetrx AS cof_allocationdate,
    p.isreceipt
   FROM c_payment p
     LEFT JOIN c_bpartner bp ON bp.c_bpartner_id = p.c_bpartner_id --parceiros clientes fornecedores 
     LEFT JOIN c_elementvalue cc ON cc.c_elementvalue_id = p.user1_id --centro de custo 
     LEFT JOIN c_elementvalue cc2 ON cc2.c_elementvalue_id = p.user2_id --centro de custo 2
     LEFT JOIN c_activity a ON a.c_activity_id = p.c_activity_id --atividades finaceiras 
     LEFT JOIN c_charge c ON c.c_charge_id = p.c_charge_id --lançamentos específicos de cobranças ou encargos
     LEFT JOIN cof_c_planofinanceiro pf ON pf.cof_c_planofinanceiro_id = p.cof_c_planofinanceiro_id --planos financeiros 
  WHERE p.c_charge_id > 0::numeric 
  		AND (p.docstatus = ANY (ARRAY['CO'::bpchar, 'CL'::bpchar])) 
  		AND p.datetrx >= to_timestamp('2024-01-01'::text, 'YYYY-MM-DD'::text) AND p.datetrx <= to_timestamp('2024-12-31'::text, 'YYYY-MM-DD'::text) 
  		AND p.ad_client_id = 5000017::numeric
  GROUP BY 'PAGAMENTO_DIRETO_COM_FINALIDADE'::text, p.ad_client_id, p.ad_org_id, p.c_bpartner_id, p.user1_id, p.user2_id, p.c_activity_id, p.c_charge_id, 
  			0::integer, p.cof_c_planofinanceiro_id, bp.value, bp.name, pf.value, pf.name, c.name, c.name, cc.value, cc.name, cc2.value, cc2.name, a.value, 
  			a.name, (cof_getreflistvalue('COF_C_PlanoFinanceiro'::character varying, 'AccountType'::character varying, pf.accounttype::character varying)), p.datetrx, p.isreceipt,
  			 p.c_payment_id  			
UNION ALL
 SELECT 'ALOCACAO_CONTRA_FINALIDADE'::text AS tipo,
    p.ad_client_id,
    p.c_payment_id,
    p.ad_org_id,
    p.c_bpartner_id,
    p.user1_id,
    p.user2_id,
    p.c_activity_id,
    p.c_charge_id,
    0 AS m_product_id,
    p.cof_c_planofinanceiro_id,
    bp.value AS chave_parceiro,
    bp.name AS nome_parceiro,
    cof_getreflistvalue('COF_C_PlanoFinanceiro'::character varying, 'AccountType'::character varying, pf.accounttype::character varying) AS tipo_plano_financeiro,
    pf.value AS chave_plano_financeiro,
    pf.name AS plano_financeiro,
    c.name AS chave_produto_finalidade,
    c.name AS produto_finalidade,
    cc.value AS chave_centro_custo,
    cc.name AS centro_custo,
    cc2.value AS chave_centro_custo2,
    cc2.name AS centro_custo2,
    a.value AS chave_atividade,
    a.name AS atividade,
    sum(alp.amount) AS valor_pagamento,
    p.datetrx AS paydate,
    h.dateacct AS cof_allocationdate,
    p.isreceipt
   FROM c_allocationline alp
     LEFT JOIN c_allocationhdr h ON h.c_allocationhdr_id = alp.c_allocationhdr_id --alocação de pagamentos cab.
     LEFT JOIN c_payment p ON p.c_payment_id = alp.c_payment_id --pagamentos 
     LEFT JOIN c_bpartner bp ON bp.c_bpartner_id = p.c_bpartner_id --parceiros 
     LEFT JOIN c_elementvalue cc ON cc.c_elementvalue_id = p.user1_id --centro de custo
     LEFT JOIN c_elementvalue cc2 ON cc2.c_elementvalue_id = p.user2_id --centro de cuto 2
     LEFT JOIN c_activity a ON a.c_activity_id = p.c_activity_id --atividades financeiras 
     LEFT JOIN c_allocationline alc ON alc.c_charge_id 
     								IS NOT NULL AND alc.c_allocationhdr_id = alp.c_allocationhdr_id 
     								AND abs(alc.amount) = abs(alp.amount) --alocação de pagamentos linhas 
     LEFT JOIN c_charge c ON c.c_charge_id = alc.c_charge_id ----lançamentos específicos de cobranças ou encargos
     LEFT JOIN cof_c_planofinanceiro pf ON pf.cof_c_planofinanceiro_id = p.cof_c_planofinanceiro_id --plano financeiro 
  WHERE alp.c_payment_id IS NOT NULL AND alp.c_invoice_id IS NULL AND alp.c_order_id IS NULL AND alc.c_allocationline_id IS NOT NULL 
  		AND (h.docstatus = ANY (ARRAY['CO'::bpchar, 'CL'::bpchar])) 
  		AND h.dateacct >= to_timestamp('2024-01-01'::text, 'YYYY-MM-DD'::text) AND h.dateacct <= to_timestamp('2024-12-31'::text, 'YYYY-MM-DD'::text) 
  		AND p.ad_client_id = 5000017::numeric
  GROUP BY 'ALOCACAO_CONTRA_FINALIDADE'::text, p.ad_client_id, p.ad_org_id, p.c_bpartner_id, p.user1_id, p.user2_id, p.c_activity_id, p.c_charge_id, 
 		0::integer, p.cof_c_planofinanceiro_id, bp.value, bp.name, pf.value, pf.name, c.name, c.name, cc.value, cc.name, cc2.value, cc2.name, a.value, 
 		a.name, (cof_getreflistvalue('COF_C_PlanoFinanceiro'::character varying, 'AccountType'::character varying, pf.accounttype::character varying)), p.datetrx, h.dateacct, p.isreceipt, p.c_payment_id
UNION ALL
 SELECT 'ALOCACAO_FATURA'::text AS tipo,
    p.ad_client_id,
      p.c_payment_id,
    p.ad_org_id,
    p.c_bpartner_id,
    COALESCE(il.user1_id, i.user1_id, p.user1_id) AS user1_id,
    COALESCE(il.user2_id, i.user2_id, p.user2_id) AS user2_id,
    COALESCE(il.c_activity_id, i.c_activity_id, p.c_activity_id) AS c_activity_id,
    il.c_charge_id,
    il.m_product_id,
    COALESCE(i.cof_c_planofinanceiro_id, p.cof_c_planofinanceiro_id) AS cof_c_planofinanceiro_id,
    bp.value AS chave_parceiro,
    bp.name AS nome_parceiro,
    cof_getreflistvalue('COF_C_PlanoFinanceiro'::character varying, 'AccountType'::character varying, pf.accounttype::character varying) AS tipo_plano_financeiro,
    pf.value AS chave_plano_financeiro,
    pf.name AS plano_financeiro,
    COALESCE(pr.value, c.name) AS chave_produto_finalidade,
    COALESCE(pr.name, c.name, c.description) AS produto_finalidade,
    cc.value AS chave_centro_custo,
    cc.name AS centro_custo,
    cc2.value AS chave_centro_custo2,
    cc2.name AS centro_custo2,
    a.value AS chave_atividade,
    a.name AS atividade,
    sum(il.linenetamt) * max(invoicepaidtodate.valor_alocado) /
        CASE
            WHEN max(i.totallines) = 0::numeric THEN 1::numeric
            ELSE max(i.totallines)
        END AS valor_pagamento,
    p.datetrx AS paydate,
    h.dateacct AS cof_allocationdate,
    p.isreceipt
   FROM c_payment p --pagamentos 
     LEFT JOIN c_currency cur ON cur.c_currency_id = p.c_currency_id --projetos 
     LEFT JOIN c_bpartner bp ON bp.c_bpartner_id = p.c_bpartner_id --parceiros
     LEFT JOIN rv_allocation h --visao alocamentos financeiros 
     		ON h.c_payment_id = p.c_payment_id 
     		AND h.datetrx >= to_timestamp('2024-01-01'::text, 'YYYY-MM-DD'::text) 
     		AND h.datetrx <= to_timestamp('2024-12-31'::text, 'YYYY-MM-DD'::text) 
     		AND (h.docstatus = ANY (ARRAY['CO'::bpchar, 'CL'::bpchar]))
     LEFT JOIN c_invoice i ON h.c_invoice_id = i.c_invoice_id --faturas
     LEFT JOIN c_invoiceline il ON il.c_invoice_id = i.c_invoice_id AND il.isdescription = 'N'::bpchar --faturas linhas 
     LEFT JOIN m_product pr ON pr.m_product_id = il.m_product_id --produtos 
     LEFT JOIN c_charge c ON c.c_charge_id = il.c_charge_id --lançamentos específicos de cobranças ou encargos.
     LEFT JOIN c_doctype idt ON idt.c_doctype_id = i.c_doctype_id ---tipos de documentos 
     LEFT JOIN c_elementvalue cc ON cc.c_elementvalue_id = COALESCE(il.user1_id, i.user1_id, p.user1_id) --centro de custos 
     LEFT JOIN c_elementvalue cc2 ON cc2.c_elementvalue_id = COALESCE(il.user2_id, i.user2_id, p.user2_id) --centro de custos 2
     LEFT JOIN c_activity a ON a.c_activity_id = COALESCE(il.c_activity_id, i.c_activity_id, p.c_activity_id) -- atividades financeiras
     LEFT JOIN cof_c_planofinanceiro pf ON pf.cof_c_planofinanceiro_id = COALESCE(i.cof_c_planofinanceiro_id, p.cof_c_planofinanceiro_id) --plano financeiro 
     LEFT JOIN LATERAL ( SELECT al.c_invoice_id,
            				al.c_payment_id,
           					 al.c_allocationline_id,
            				sum(currencyconvert(al.amount + al.discountamt + al.writeoffamt, ah.c_currency_id, ah.c_currency_id, ah.datetrx::timestamp with time zone,
            						NULL::numeric, al.ad_client_id, al.ad_org_id)) AS valor_alocado
           				FROM c_allocationline al --alocacao de pagamentos linhas 
            	 			JOIN c_allocationhdr ah ON al.c_allocationhdr_id = ah.c_allocationhdr_id --alocacao de pagamentos 
          				WHERE ah.isactive = 'Y'::bpchar AND (ah.docstatus = ANY (ARRAY['CO'::bpchar, 'CL'::bpchar])) AND ah.dateacct < to_timestamp('2024-12-31'::text, 'YYYY-MM-DD'::text)
          				GROUP BY al.c_invoice_id, al.c_payment_id, al.c_allocationline_id) invoicepaidtodate 
          				ON invoicepaidtodate.c_invoice_id = i.c_invoice_id AND invoicepaidtodate.c_payment_id = p.c_payment_id 
          				AND invoicepaidtodate.c_allocationline_id = h.c_allocationline_id
  WHERE h.dateacct >= to_timestamp('2024-01-01'::text, 'YYYY-MM-DD'::text) AND h.dateacct <= to_timestamp('2024-12-31'::text, 'YYYY-MM-DD'::text) 
  		AND h.c_allocationhdr_id IS NOT NULL AND h.c_invoice_id IS NOT NULL AND (p.docstatus = ANY (ARRAY['CO'::bpchar, 'CL'::bpchar])) 
  		AND p.ad_client_id = 5000017::numeric
  GROUP BY 'ALOCACAO_FATURA'::text, p.ad_client_id, p.ad_org_id, p.c_bpartner_id, (COALESCE(il.user1_id, i.user1_id, p.user1_id)), 
 		(COALESCE(il.user2_id, i.user2_id, p.user2_id)), (COALESCE(il.c_activity_id, i.c_activity_id, p.c_activity_id)), il.c_charge_id, il.m_product_id, 
 		(COALESCE(i.cof_c_planofinanceiro_id, p.cof_c_planofinanceiro_id)), p.c_payment_id, i.c_invoice_id, bp.value, bp.name, pf.value, pf.name, (COALESCE(pr.value, c.name)), 
 		(COALESCE(pr.name, c.name, c.description)), cc.value, cc.name, cc2.value, cc2.name, a.value, a.name, idt.docbasetype, h.c_allocationline_id, 
 		(cof_getreflistvalue('COF_C_PlanoFinanceiro'::character varying, 'AccountType'::character varying, pf.accounttype::character varying)), p.datetrx, h.dateacct, p.isreceipt, p.c_payment_id
UNION all
 SELECT 'ANTECIPACAO'::text AS tipo,
    p.ad_client_id,
    p.c_payment_id,
    p.ad_org_id,
    p.c_bpartner_id,
    p.user1_id,
    p.user2_id,
    p.c_activity_id,
    p.c_charge_id,
    0 AS m_product_id,
    p.cof_c_planofinanceiro_id,
    bp.value AS chave_parceiro,
    bp.name AS nome_parceiro,
    cof_getreflistvalue('COF_C_PlanoFinanceiro'::character varying, 'AccountType'::character varying, pf.accounttype::character varying) AS tipo_plano_financeiro,
    pf.value AS chave_plano_financeiro,
    pf.name AS plano_financeiro,
    'ANTECIPACAO'::text AS chave_produto_finalidade,
    'PAGAMENTOS E RECEBIMENTOS ANTECIPADOS'::text AS produto_finalidade,
    cc.value AS chave_centro_custo,
    cc.name AS centro_custo,
    cc2.value AS chave_centro_custo2,
    cc2.name AS centro_custo2,
    a.value AS chave_atividade,
    a.name AS atividade,
    sum(
        CASE p.isreceipt
            WHEN 'Y'::bpchar THEN p.payamt
            ELSE p.payamt * '-1'::numeric
        END - COALESCE(paymnentopentodate.valor_aberto, 0::numeric)) AS valor_pagamento,
    p.datetrx AS paydate,
    NULL::date AS cof_allocationdate,
    p.isreceipt
   FROM c_payment p --pagamentos
     LEFT JOIN cof_c_planofinanceiro pf ON pf.cof_c_planofinanceiro_id = p.cof_c_planofinanceiro_id --plano financeiro
     LEFT JOIN c_currency cur ON cur.c_currency_id = p.c_currency_id --moedas
     LEFT JOIN c_bpartner bp ON bp.c_bpartner_id = p.c_bpartner_id --parceiros
     LEFT JOIN c_elementvalue cc ON cc.c_elementvalue_id = p.user1_id --centor de custos
     LEFT JOIN c_elementvalue cc2 ON cc2.c_elementvalue_id = p.user2_id  --centro de custos 2
     LEFT JOIN c_activity a ON a.c_activity_id = p.c_activity_id --projetos 
     LEFT JOIN LATERAL ( SELECT al.c_payment_id,
            sum(currencyconvert(COALESCE(al.amount, 0::numeric) + COALESCE(al.discountamt, 0::numeric) + COALESCE(al.writeoffamt, 0::numeric), ah.c_currency_id, ah.c_currency_id, ah.datetrx::timestamp with time zone, NULL::numeric, al.ad_client_id, al.ad_org_id)) AS valor_aberto
           FROM c_allocationline al --alocação de pagamentos linhas
             JOIN c_allocationhdr ah ON al.c_allocationhdr_id = ah.c_allocationhdr_id --alocação de pagamentos cab.
          WHERE ah.isactive = 'Y'::bpchar AND (ah.docstatus = ANY (ARRAY['CO'::bpchar, 'CL'::bpchar])) 
          AND ah.dateacct between to_timestamp('2024-01-01'::text, 'YYYY-MM-DD'::text) and to_timestamp('2024-12-31'::text, 'YYYY-MM-DD'::text)
          GROUP BY al.c_payment_id) paymnentopentodate ON paymnentopentodate.c_payment_id = p.c_payment_id
  WHERE p.datetrx >= to_timestamp('2024-01-01'::text, 'YYYY-MM-DD'::text) AND p.datetrx <= to_timestamp('2024-12-31'::text, 'YYYY-MM-DD'::text) 
  		AND (abs(p.payamt) - abs(COALESCE(paymnentopentodate.valor_aberto, 0::numeric))) <> 0::numeric AND p.c_charge_id IS NULL 
  		AND (p.docstatus = ANY (ARRAY['CO'::bpchar, 'CL'::bpchar])) AND p.ad_client_id = 5000017::numeric
  GROUP BY 'ANTECIPACAO'::text, p.ad_client_id, p.ad_org_id, p.c_bpartner_id, p.user1_id, p.user2_id, p.c_activity_id, p.c_charge_id, 0::integer, p.cof_c_planofinanceiro_id, 
  			bp.value, bp.name, pf.value, pf.name, 'ANTECIPACAO'::text, 'PAGAMENTOS E RECEBIMENTOS ANTECIPADOS'::text, cc.value, cc.name, cc2.value, cc2.name, a.value, 
  			a.name, (cof_getreflistvalue('COF_C_PlanoFinanceiro'::character varying, 'AccountType'::character varying, pf.accounttype::character varying)), p.datetrx, p.isreceipt, p.c_payment_id;
--WITH DATA;