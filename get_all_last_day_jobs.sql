CREATE OR REPLACE FUNCTION public.get_all_last_day_jobs(date_of_report timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN (select array_to_json(array_agg(row_to_json(row)))from(
		select jh."b2x_job_number",jh."accident_date",jh."logistic_inbound_awb",jh."logistic_outbound_awb",jh."damaged_board_serial_number",jh."replacement_board_serial_number",
		jh."claim_id",jh."complaint_date",jh."rsp_date_in",jh."rsp_date_out",jh."escalated_rsp",jh."imei_2_in",jh."imei_2_out",jh."imei_number_in",jh."imei_number_out",jh."item_code_out",
		jh."job_creation_date",jh."device_manufacture_date",jh."oem_in",jh."oem_out",jh."logistic_inbound_shipment_type",jh."logistic_outbound_shipment_type",jh."pickup_arranged_date",
		jh."pickup_date",jh."pop_date",jh."pop_supplier",jh."product_code_in",jh."product_code_out",jh."sku_in",jh."sku_out",jh."product_type",jh."product_version_in",
		jh."product_version_out",jh."project",jh."provider_or_carrier",jh."quotation_start_date",jh."quotation_end_date",jh."quotation_status_code",jh."repair_status",
		jh."second_repair_status",jh."repair_timestamp",jh."report_date",jh."return_date",jh."rma_number",jh."serial_number_in",jh."serial_number_out",jh."shipped_from",
		jh."shipped_to",jh."shop_in_date",jh."shop_out_date",jh."software_in",jh."software_out",jh."solution_awaited_code",jh."special_project_number",jh."support_partner_ticket_id",
		jh."transaction_code",jh."warranty",jh."warranty_number",jh."device_ber",jh."certificate_number",jh."device_invoice_number",jh."claim_type",jh."claiming_status",
		jh."send_pre_alert_flag",jh."partner_id",jh."device_date_of_purchase",jh."completion_date",jh."deductible_amount",jh."deductible_amount_currency",jh."deductible_receipt",
		jh."deductible_required",jh."device_irrepairable",jh."doc_imei_ok",jh."doc_invoice_date",jh."doc_invoice_date_ok",jh."doc_invoice_number_ok",jh."doc_invoice_price",
		jh."doc_received",jh."doc_serial_number_ok",jh."doc_signed",jh."insurance_coverage",jh."device_repair_cost",jh."accident_description",jh."problem_description",
		jh."accident_valid",jh."customer_visit_date",jh."partner_job_number",jh."accident_id",jh."claim_creation_date",jh."insurance_broker",jh."insurance_end_date",
		jh."type_in",jh."type_out",jh."insurance_product_name",jh."insurance_policy_number", jd."repair_description",jd."logistic_inbound_courier_name",
		jd."logistic_outbound_courier_name",jd."logistics_type_in",jd."logistics_type_out",jd."shipment_status_in",jd."shipment_status_out",jd."tracking_number_in",
		jd."tracking_number_out",jd."repair_status_update",jd."repair_status_2_update",jd."additional_service",jd."collect_deductible",jd."collect_device_packaging",
		jd."commentary",jd."device_configuration",jd."device_value",jd."device_value_currency",jd."employee_number",jd."loan_phone",jd."max_repair_cost",jd."max_repair_cost_currency",
		jd."sale_price",jd."sale_price_currency",jd."special_instructions",jd."tax_id",jd."transport_insr",jd."transport_insr_currency",jd."transport_insr_value",
		jd."quotation_currency",jd."quotation_amount",jd."cid",jd."custom_1",jd."custom_2",jd."custom_3",jd."custom_4",jd."custom_5",jd."custom_6",jd."custom_7",jd."custom_8",
		jd."custom_9",jd."custom_10", c."customer_id",c."code" as "b2x_customer_code",c."name",c."address_line1",c."address_line2",c."address_line3",c."zip",c."city",c."state",
		c."country",c."billing_address_line1",c."billing_address_line2",c."billing_address_line3",c."billing_zip",c."billing_city",c."billing_state",c."billing_country",c."email",
		c."home_phone",c."mobile",c."passport_country",c."passport_number", jcc1."primary_code" as "customer_complaint_code_primary", 
		jcc2."primary_code" as "customer_complaint_code_secondary", jpf1."primary_code" as "problem_found_code_primary", jpf2."primary_code" as "problem_found_code_secondary",
		jac."action_code", jpc."action_reason_code",jpc."action_remarks",jpc."delivery_date",jpc."delivery_number",jpc."fault_code",jpc."field_bulletin_number",jpc."material_number",
		jpc."material_serial_number",jpc."payer",jpc."quantity_exchanged",jpc."quantity_replaced",jpc."root_cause",jpc."technician_id",jpc."reference_designator_number",
		jpc."mandatory",jpc."damaged_material_number",jpc."damaged_material_serial_number", jq."problem_found_code",jq."amount",jq."tax",jq."currency", jdd."amount",
		jdd."currency",jdd."status",jdd."payment_mode",jdd."transaction_id",jdd."payment_message", jpa."material_number",jpa."quantity_missing", jdocs."doc_received",
		jdocs."doc_signed",jdocs."doc_serial_number_ok",jdocs."doc_invoice_number_ok",jdocs."doc_imei_ok",jdocs."doc_invoice_date",jdocs."doc_invoice_date_ok",
		jdocs."doc_invoice_price",jdocs."file_name",jdocs."url",jdocs."extension" 
		FROM job_head_new jh join job_detail_new jd on jh.job_detail_id = jd.id 
		join tr_consumer c on c.id = jh.consumer_id::integer 
		left join job_customer_complaint jcc1 on jh.id = jcc1.job_id and jcc1.flag = 1 and jcc1.is_active = true
		left join job_customer_complaint jcc2 on jh.id = jcc2.job_id and jcc2.flag = 2 and jcc2.is_active = true 
		left join job_problem_found jpf1 on jh.id = jpf1.job_id and jpf1.flag = 1 and jpf1.is_active = true 
		left join job_problem_found jpf2 on jh.id = jpf2.job_id and jpf2.flag = 2 and jpf2.is_active = true 
		left join job_action_code jac on jh.id = jac.job_id and jac.is_active = true 
		left join job_part_conusmed_new jpc on jh.id = jpc.job_id and jpc.is_active = true 
		left join job_quotation jq on jh.id = jq.job_id 
		left join job_deductible jdd on jh.id = jdd.job_id 
		left join job_part_awainting jpa on jh.id = jpa.job_id and jpa.is_active = true 
		left join job_documents jdocs on jh.b2x_job_number = jdocs.b2x_job_number 
		where (jh.created_on::date = (TIMESTAMP 'yesterday')::date)
		and jh.repair_status = '1'
		order by jh."b2x_job_number", jh.id
	)row
	);
    END;
$function$
