CREATE OR REPLACE FUNCTION public.get_jod_details_new(jobid integer, roleid text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
sub_repair_status text := '';
job_data text;
consumer_data text;
logistics_data text;
status_history text;
action_log text;
device_data text;
insurance_data text;
documents_data text;
inbound_data text;
outbound_data text;
result text;
nis text:= 'Not in system';
Begin
	-- job details data
	job_data:= (SELECT array_to_json(array_agg(row)) FROM (
-- 		SELECT jh.id as "jobId", 
-- 		jh.b2x_job_number as "jobNumber", 
-- 		coalesce(jh.claim_id, 'N/A') as "externalClaimID",
-- 		coalesce(jh.rma_number, 'N/A') as "rmaId",
-- 		coalesce(jh.claim_type, 'N/A') as "claimType",
-- 		coalesce(jh.claiming_status, 'N/A') as "jobStatus",
-- 		coalesce((select status_name from mst_repair_status where customer_code = jh.repair_status::text), 'N/A') as "repairStatus",
-- 		coalesce((select customer_repair_status from mst_repair_status where customer_code = jh.repair_status::text), 'N/A') as "customerRepairStatus",
-- 		coalesce((select status_name from mst_second_status where customer_code = jh.second_repair_status::text), 'N/A') as "secondRepairStatus",
-- 		jh.created_on as "jobCreatedOn",
-- 		coalesce(jh.warranty, false) AS "warrantyStatus",
-- 		coalesce(jh.partner_id, 'N/A') as "RSP"		
-- 		FROM job_head_new jh
		SELECT jh.id as "jobId", 
		jh.b2x_job_number as "jobNumber", 
		coalesce(jh.claim_id, 'N/A') as "externalClaimID",
		coalesce(jh.rma_number, 'N/A') as "rmaId",
		coalesce(jd.file_name, 'N/A') as "fileName",
		coalesce(jh.claim_type, 'N/A') as "claimType",
		coalesce(jh.claiming_status, 'N/A') as "jobStatus",
		coalesce(rs.status_name, 'N/A') as "repairStatus",
		coalesce(rs.customer_repair_status , 'N/A') as "customerRepairStatus",
		coalesce(srs.status_name, 'N/A') as "secondRepairStatus",
		jh.created_on as "jobCreatedOn",
		coalesce(jh.warranty, false) AS "warrantyStatus",
		coalesce(jh.partner_id, 'N/A') as "RSP"		
		FROM job_head_new jh
		INNER JOIN public.job_detail_new jd on jd.id = jh.job_detail_id and jd.is_active = true
		LEFT JOIN public.mst_repair_status rs on rs.b2x_code = jh.repair_status::text and rs.is_active
		LEFT JOIN public.mst_second_status srs on srs.b2x_code = jh.second_repair_status::text and srs.is_active = true
		WHERE jh.is_active = true and jh.id = jobid	
	)row);
	
	-- consumer data for job details
	consumer_data:= (SELECT array_to_json(array_agg(row)) FROM (
		SELECT
		coalesce(tc.name, 'N/A') as "endUserName",
		coalesce(tc.address_line1, 'N/A') as "endUserAddressLine1",
		coalesce(tc.address_line2, 'N/A') as "endUserAddressLine2",
		coalesce(tc.mobile, 'N/A') as "endUserMobile",
		coalesce(tc.email, 'N/A') as "endUserEmail",
		coalesce(tc.city, 'N/A') as "endUserCity",
		coalesce(tc.state, 'N/A') as "endUserState",
		coalesce(tc.zip, 'N/A') as "endUserPostalCode",
		coalesce((SELECT name FROM mst_country WHERE iso_code = tc.country), 'N/A') as "endUserCountry"
		FROM tr_consumer tc 
		LEFT JOIN job_head_new jh ON jh.consumer_id = tc.id::text
		where tc.is_active = true and jh.is_active = true and jh.id = jobid
	)row);

	-- logistics data for job details
	logistics_data:= (SELECT array_to_json(array_agg(row)) FROM (
		-- SELECT
-- 		coalesce((SELECT logistics_name from mst_logistic_status WHERE logistics_code = jh.logistic_inbound_shipment_type::text AND logistics_type = 'Inbound' AND is_active = true),'N/A') as "inboundShipmentType",
-- 		coalesce((SELECT logistics_name from mst_logistic_status WHERE logistics_code = jh.logistic_outbound_shipment_type::text AND logistics_type = 'Outbound'  AND is_active = true),'N/A') as "outboundShipmentType",
-- 		coalesce(jd.logistic_inbound_courier_name,'N/A') as "inboundLogisticsPartner", 
-- 		coalesce(jd.logistic_outbound_courier_name,'N/A') as "outboundLogisticsPartner", 
-- 		coalesce(jd.tracking_number_in,'N/A') as "inboundTrackingNumber", 
-- 		coalesce(jd.tracking_number_out,'N/A') as "outboundTrackingNumber", 
-- 		coalesce(jh.pickup_date, null) as "inboundShipmentBegins",
-- 		coalesce(jh.rsp_date_in, null) as "inboundShipmentEnds",
-- 		coalesce(jh.order_delivery_date, null) as "outboundShipmentBegins",
-- 		coalesce(jh.completion_date, null) as "outboundShipmentEnds"
-- 		FROM job_detail_new jd
-- 		LEFT JOIN job_head_new jh ON jd.id = jh.job_detail_id
		SELECT
		coalesce(ls.logistics_name,'N/A') as "inboundShipmentType",
		coalesce(lso.logistics_name,'N/A') as "outboundShipmentType",
		coalesce(jd.logistic_inbound_courier_name,'N/A') as "inboundLogisticsPartner", 
		coalesce(jd.logistic_outbound_courier_name,'N/A') as "outboundLogisticsPartner", 
		coalesce(jh.logistic_inbound_awb,'N/A') as "inboundTrackingNumber", 
		coalesce(jh.logistic_outbound_awb,'N/A') as "outboundTrackingNumber", 
		coalesce(jh.pickup_date, null) as "inboundShipmentBegins",
		coalesce(jh.rsp_date_in, null) as "inboundShipmentEnds",
		coalesce(jh.order_delivery_date, null) as "outboundShipmentBegins",
		coalesce(jh.completion_date, null) as "outboundShipmentEnds"
		FROM job_detail_new jd
		LEFT JOIN job_head_new jh ON jd.id = jh.job_detail_id
		LEFT JOIN mst_logistic_status ls ON ls.logistics_code = jh.logistic_inbound_shipment_type::text AND ls.logistics_type = 'Inbound' AND ls.is_active = true
		LEFT JOIN mst_logistic_status lso ON lso.logistics_code = jh.logistic_outbound_shipment_type::text AND lso.logistics_type = 'Outbound' AND lso.is_active = true
		where jd.is_active = true and jh.is_active = true and jh.id = jobid
	)row);

	-- status history for job details
	status_history:= (SELECT array_to_json(array_agg(row)) FROM (
		-- SELECT
-- 		coalesce((SELECT status_name FROM mst_repair_status WHERE customer_code = jd.repair_status AND is_active = true), 'N/A') As "repairStatus",
-- 		coalesce((select customer_repair_status from mst_repair_status where customer_code = jh.repair_status::text), 'N/A') as "customerRepairStatus",
-- 		--coalesce((SELECT status_name FROM mst_second_status WHERE customer_code = jd.second_repair_status AND is_active = true), 'N/A') As "secondRepairStatus",
-- 		case when (jd.repair_status = (SELECT repair_status FROM mst_second_status WHERE customer_code = jd.second_repair_status AND is_active = true)) then 
-- 		(SELECT status_name FROM mst_second_status WHERE customer_code = jd.second_repair_status AND is_active = true) else 'N/A' end "secondRepairStatus", 
-- 		jd.created_on as "assignedOn"
-- 		FROM job_detail_new jd
-- 		LEFT JOIN job_head_new jh ON jd.id = jh.job_detail_id
		SELECT
		coalesce(rs.status_name, 'N/A') As "repairStatus",
		coalesce(rs.customer_repair_status, 'N/A') as "customerRepairStatus",
		case when (jd.repair_status = srs.repair_status) then srs.status_name  else 'N/A' end "secondRepairStatus", 
		jd.created_on as "assignedOn"
		FROM job_detail_new jd
		LEFT JOIN job_head_new jh ON jd.id = jh.job_detail_id
		LEFT JOIN public.mst_repair_status rs on rs.b2x_code = jd.repair_status::text and rs.is_active = true
		LEFT JOIN public.mst_second_status srs on srs.b2x_code = jd.second_repair_status::text and srs.is_active = true
		WHERE jd.is_active = true AND jd.job_id = jobid order by jd.id
	)row);
	
	--insurance data for job details
	insurance_data:= (SELECT array_to_json(array_agg(row)) FROM (
		SELECT
		case when jh.doc_signed = true then 'True' else 'False' end "docSigned",
		coalesce(jh.claim_checked, null) as "claimChecked",
		case when jh.accident_valid = true then 'True' else 'False' end "damagePlausible",
		case when jh.doc_serial_number_ok = true then 'True' else 'False' end "deviceSerialNumberCorrect",
		case when jh."doc_invoice_number_ok" = true then 'True' else 'False' end "deviceInvoiceNumberCorrect",
		case when jh.doc_invoice_price = true then 'True' else 'False' end "devicePurchasePriceCorrect", 
		case when jh.doc_invoice_date_ok = true then 'True' else 'False' end "devicePurchaseDateCorrect",
		case when jh.deductible_required = true then 'True' else 'False' end "deductiblePaid",
		case when jh.device_irrepairable = true then 'True' else 'False' end "deviceIrrepairable",
		coalesce(jh.device_repair_cost,'0') AS "deviceRepairCost",
		coalesce(jh.insurance_product_name,null) AS "insuranceProductName",
		coalesce(jh.insurance_policy_number,null) AS "insurancePolicyNumber",
		coalesce(jh.insurance_start_date,null) AS "insuranceStartDate",
		coalesce(jh.insurance_end_date,null) AS "insuranceEndDate"
		FROM job_head_new jh
		WHERE jh.is_active = true AND jh.id = jobid
	)row);

	--device data for job details
	device_data:= (SELECT array_to_json(array_agg(row)) FROM (
		-- SELECT
-- 		coalesce(jh.imei_number_in, 'N/A') as "imeiIn",
-- 		coalesce(jh.serial_number_in, 'N/A') as "serialNumberIn",
-- 		coalesce((SELECT string_agg(primary_code, ',') FROM job_customer_complaint where job_id = jobid and is_active = true), 'N/A') as "customerComplaintCodes",
-- 		coalesce((SELECT string_agg(primary_code, ',') FROM job_problem_found where job_id = jobid and is_active = true), 'N/A') as "problemFoundCodes",
-- 		coalesce(jd.repair_description, 'N/A') as "repairDescription",
-- 		coalesce(jh.oem_in, 'N/A') as "oemIn",
-- 		coalesce((SELECT model_name FROM mst_model WHERE model_code = jh.product_code_in AND is_active = true), 'N/A') as "modelIn",
-- 		coalesce(jh.product_code_in, 'N/A') as "modelCodeIn",
-- 		coalesce(jh.sku_in, 'N/A') as "skuIN",
-- 		coalesce(jh.imei_number_out, 'N/A') as "imeiOut",
-- 		coalesce(jh.serial_number_out, 'N/A') as "serialNumberOut",
-- 		coalesce(jh.oem_out, 'N/A') as "oemOut",
-- 		coalesce((SELECT model_name FROM mst_model WHERE model_code = jh.product_code_out AND is_active = true), 'N/A') as "modelOut"
-- 		FROM job_head_new jh
-- 		--left JOIN job_customer_complaint jcc ON jcc.job_id = jh.id
-- 		--left JOIN job_problem_found jpf ON jpf.job_id = jh.id
-- 		left JOIN job_detail_new jd ON jd.id = jh.job_detail_id
		SELECT
		coalesce(jh.imei_number_in, 'N/A') as "imeiIn",
		coalesce(jh.serial_number_in, 'N/A') as "serialNumberIn",
		coalesce((SELECT string_agg(primary_code, ',') FROM job_customer_complaint where job_id = jobid and is_active = true), 'N/A') as "customerComplaintCodes",
		coalesce((SELECT string_agg(primary_code, ',') FROM job_problem_found where job_id = jobid and is_active = true), 'N/A') as "problemFoundCodes",
		coalesce(jd.repair_description, 'N/A') as "repairDescription",
		coalesce(jh.oem_in, 'N/A') as "oemIn",
		coalesce(m.model_name, 'N/A') as "modelIn",
		coalesce(jh.product_code_in, 'N/A') as "modelCodeIn",
		coalesce(jh.sku_in, 'N/A') as "skuIN",
		coalesce(jh.imei_number_out, 'N/A') as "imeiOut",
		coalesce(jh.serial_number_out, 'N/A') as "serialNumberOut",
		coalesce(jh.oem_out, 'N/A') as "oemOut",
		coalesce(mo.model_name, 'N/A') as "modelOut"
		FROM job_head_new jh
		--left JOIN job_customer_complaint jcc ON jcc.job_id = jh.id
		--left JOIN job_problem_found jpf ON jpf.job_id = jh.id
		left JOIN job_detail_new jd ON jd.id = jh.job_detail_id
		left join mst_model m on m.model_code = jh.product_code_in and m.is_active = true
		left join mst_model mo on mo.model_code = jh.product_code_out and mo.is_active = true
		WHERE jh.is_active = true AND jd.is_active = true AND jh.id = jobid
	)row);

	--documents data for job details
	documents_data:= (SELECT array_to_json(array_agg(row)) FROM (
		SELECT
		coalesce(jdocs.file_name, 'N/A') as "fileName",
		coalesce(jdocs.document_type, 'N/A') as "documentType",
		coalesce(jdocs.file_content, 'N/A') as "fileContent"
		FROM job_documents jdocs
		LEFT JOIN job_head_new jh ON jh.b2x_job_number = jdocs.b2x_job_number
		WHERE jh.is_active = true AND jh.id = jobid
	)row);
	
	--Inbound logistic Details
		inbound_data:= (SELECT array_to_json(array_agg(row)) FROM (
		
		select "jh".id as "jobId", jtd.input_name as "inputName", 
		jtd.tracking_number as "trackingId", jd.logistic_inbound_courier_name as "courierIn", jh.logistic_inbound_awb as "awbIn", 
		jtd.status as "status", jtd.date_of_delivery  as "estimatedDelivery"
		from job_tracking_details jtd
		inner join job_head_new jh on jtd.job_id = jh.id
		inner join job_detail_new jd on jh.job_detail_id = jd.id
		where 
		status in ('In transit','Delivered/Complete','Awaiting Pickup') and input_name in ('inBound') and jtd.job_id = jobid
		
		)row);
		
		--Outbound logistic Details
		outbound_data:= (SELECT array_to_json(array_agg(row)) FROM (
		
		select "jh".id as "jobId", jtd.input_name as "inputName", 
		jtd.tracking_number as "trackingId", jd.logistic_outbound_courier_name as "courierOut", jh.logistic_outbound_awb as "awbOut", 
		jtd.status as "status", jtd.date_of_delivery as "estimatedDelivery"
		from job_tracking_details jtd
		inner join job_head_new jh on jtd.job_id = jh.id
		inner join job_detail_new jd on jh.job_detail_id = jd.id
		where 
			status in ('In transit','Delivered/Complete','Awaiting Pickup') and input_name in ('outBound') and jtd.job_id = jobid
		
		)row);
		

	result:= '{
				"job_data":' ||coalesce(job_data, '[]')||', 
				"consumer_data":' ||coalesce(consumer_data, '[]')||', 
				"logistics_data":' ||coalesce(logistics_data, '[]')||', 
				"status_history":' ||coalesce(status_history, '[]')||', 
				"device_data":' ||coalesce(device_data, '[]')||', 
				"insurance_data":' ||coalesce(insurance_data, '[]')||', 
				"documents_data":' ||coalesce(documents_data, '[]')||',
				"inbound_logistic_data":' ||coalesce(inbound_data, '[]')||',
				"outbound_logistic_data":' ||coalesce(outbound_data, '[]')||'
			 }';
	--RAISE NOTICE 'result=====: %', result;
	return result;
	
End
$function$
