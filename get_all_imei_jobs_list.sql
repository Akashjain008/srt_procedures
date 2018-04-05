CREATE OR REPLACE FUNCTION public.get_all_imei_jobs_list("imeiNumber" text, "serialNumber" text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare 
data text;
BEGIN
		
	if ("imeiNumber" is not null or "serialNumber" is not null) then
	
		data := (
			SELECT array_to_json(array_agg(row)) 
			FROM (
			
					SELECT trh.id, trh.b2x_job_number AS "jobN", trh.imei_number_in AS "imeiNumber", trh.oem_in As "damagedManufacturer", 
					trh.claim_id AS "claimId", trh.product_code_in as "damagedModel", trh.claim_type as "claimType", 
					trh.created_on as "createdOn", trh.claiming_status as "claimingStatus", rs.status_name as "repairStatus", 
					rs.customer_repair_status as "customerRepairStatus", srs.status_name as "repairStatus2",
					trh.claiming_status AS "jobStatus", trh.oem_in as "oemName", co.name as "customerCountry", 
					mr.rsp_name as "rspName", mm.model_name as "modelName", mm.model_description as "modelDescription"--, trh.cid
					FROM public.job_head_new trh
					LEFT JOIN public.tr_consumer cu ON trh.consumer_id::integer = cu.id
					LEFT JOIN public.mst_model mm ON trh.product_code_in_id = mm.id and mm.is_active = true
					LEFT JOIN public.mst_repair_status rs on rs.customer_code = trh.repair_status::text
					LEFT JOIN public.mst_second_status srs on srs.customer_code = trh.second_repair_status::text and srs.is_active = true
					LEFT JOIN public.mst_country co ON co.iso_code = cu.country and co.is_active = true
					LEFT JOIN public.mst_oem mo ON trh.oem_in_id = mo.id 
					LEFT JOIN public.mst_rsp mr ON trh.partner_id = mr.rsp_id
					WHERE (
						(trh.imei_number_in = "imeiNumber" OR "imeiNumber" IS NULL OR "imeiNumber" = '') AND
						(trh.serial_number_in = "serialNumber" OR "serialNumber" IS NULL OR "serialNumber" = '')
					      )
					ORDER BY trh.id desc
					
				)row
			);
		
			return '{"data":' ||coalesce(data, '[]')||', "message": ""}';
		
		else
		
			return '{"data": "[]", "message": "Invalid imeiNumber or serialNumber"}';
		
		end if;

END;
$function$
