CREATE OR REPLACE FUNCTION public.get_claim_data(from_date_of_report timestamp with time zone, to_date_of_report timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN (select array_to_json(array_agg(row_to_json(row)))from(
			select
			(select array_to_string(ARRAY(select distinct action_code::text from job_action_code where job_id = jh.id and is_active= true), ', ')) as "Action Code",
			(select array_to_string(ARRAY(select distinct mac.customer_action_code::text from job_action_code jac
			left join mst_action_code mac on jac.action_code = mac.b2x_action_code 
			where jac.job_id = jh.id and jac.is_active= true and mac.is_active = true), ', ')) as "Client Action Code",
			coalesce("pc"."action_reason_code", null) as "Action Reason Code",
			coalesce("jh"."logistic_inbound_awb", null) as "AWB In",
			coalesce("jh"."logistic_outbound_awb",null) as "AWB Out",
			coalesce("jh"."damaged_board_serial_number",null) AS "Board Serial Number In",
			coalesce("jh"."replacement_board_serial_number",null) AS "Board Serial Number Out",
			coalesce("jh"."b2x_job_number",null) AS "Claim ID",
			null AS "ClaimLine ID",
			coalesce("jd"."logistic_inbound_courier_name",null) as "Courier In", 
			coalesce("jd"."logistic_outbound_courier_name",null) as "Courier Out",
			coalesce(to_char("jh"."rsp_date_in"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "Date In",
			coalesce(to_char("jh"."rsp_date_out"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "Date Out",
			coalesce("jh"."imei_number_in",null) as "IMEI Number In",
			coalesce("jh"."imei_number_out",null) as "IMEI Number Out",
			coalesce("pc"."material_number", null) as "Material Number",
			coalesce("pc"."material_serial_number", null) as "Material serial number",
			coalesce(Upper("jh"."oem_in"),null) as "OEM",
			coalesce("jh"."logistic_outbound_shipment_type",null) AS "Outbound Shipment Type",
			coalesce("pc"."payer", null) as "Payer",
			--coalesce(pf.primary_code, null) as "Problem Found Code",
			(select array_to_string(ARRAY(select distinct primary_code::text from job_problem_found where job_id = jh.id and is_active= true), ', ')) as "Problem Found Code",
			(select array_to_string(ARRAY(select distinct mpf.customer_code::text from job_problem_found jpf
			left join mst_problem_found mpf on jpf.primary_code = mpf.b2x_code
			where jpf.job_id = jh.id and jpf.is_active= true and mpf.is_active = true ), ', ')) as "Client Problem Found Code",
			coalesce("jh"."product_code_in",null) as "Product Code In",
			coalesce("jh"."product_code_out",null) as "Product Code Out",
			coalesce("jh"."product_type",null) as "Product Type",
			coalesce(Upper("jh"."project"),null) as "Project",
			coalesce("pc"."quantity_replaced", 0) as "Quantity Replaced",
			coalesce("jd"."quotation_amount",0) as "Quotation Amount",
			coalesce("jd"."quotation_currency",null) as "Quotation Currency",
			coalesce("jh"."partner_id",null) as "Repair Service Partner ID",
			coalesce("jh"."repair_status",null) as "Repair Status Code",
			coalesce(to_char("jh"."completion_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "Repair Timestamp",
			coalesce(to_char("jh"."report_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "Report Date",
			coalesce("jh"."second_repair_status",null) as "Second Status",
			coalesce("jh"."serial_number_in",null) as "Serial Number In",
			coalesce("jh"."serial_number_out",null) as "Serial Number Out",
			coalesce("jh"."transaction_code",null) as "Transaction Code",
			coalesce(tc.cust_transaction_code,null) as "Client Transaction Code"
			FROM job_head_new jh
			inner Join "job_detail_new" jd ON jd.id=jh.job_detail_id
			LEFT JOIN job_part_conusmed_new pc on pc.job_id =jh.id and pc.is_active = true
			inner join mst_transaction_code tc on jh.transaction_code = tc.b2x_transaction_code and tc.is_active = true
			where jh.repair_status= '90' and jh.updated_on::date  between from_date_of_report::date and to_date_of_report::date
	)row
	);
    END;
$function$
