CREATE OR REPLACE FUNCTION public.get_all_jobs("pageIndex" integer, "pageSize" integer, "jobN" text, "imeiNumber" text, "actionStatus" text, "jobStatus" text, rsp integer, "rmaId" text, "claimT" text, "returnMethod" text, oem integer, channelname text, OUT "jobData" json[], OUT "totalRecords" integer)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
BEGIN
	"jobData":= ARRAY(SELECT row_to_json(r) 
	FROM(
		-- SELECT trh.id, trh.b2x_job_number AS "jobN", trh.imei_number_in AS "imeiNumber", trh.oem_in As "damagedManufacturer", trh.claim_id AS "claimId",
-- 		trh.product_code_in as "damagedModel", trh.claim_type as "claimType", trh.created_on as "createdOn", trh.claiming_status as "claimingStatus", 
-- 		(select status_name from mst_repair_status where customer_code = trh.repair_status::text order by id desc limit 1) as "repairStatus", 
-- 		(select customer_repair_status from mst_repair_status where customer_code = trh.repair_status::text order by id desc limit 1) as "customerRepairStatus", 
-- 		(select status_name from mst_second_status where customer_code = trh.second_repair_status::text order by id desc limit 1) as "repairStatus2",
-- 		trh.claiming_status AS "jobStatus", 
-- 		trh.oem_in as "oemName",
-- 		(select name from mst_country where iso_code = cu.country order by id desc limit 1) as "customerCountry", 
-- 		mr.rsp_name as "rspName",
-- 		mm.model_name as "modelName", mm.model_description as "modelDescription" --, trh.cid
-- 		FROM public.job_head_new trh
-- 		LEFT JOIN public.tr_consumer cu	ON trh.consumer_id::integer = cu.id
-- 		LEFT JOIN public.mst_model mm ON trh.product_code_in_id = mm.id
-- 		LEFT JOIN public.mst_oem mo ON trh.oem_in_id = mo.id
-- 		LEFT JOIN public.mst_rsp mr ON trh.partner_id = mr.rsp_id
		SELECT trh.id, trh.b2x_job_number AS "jobN", trh.imei_number_in AS "imeiNumber", trh.oem_in As "damagedManufacturer", trh.claim_id AS "claimId",
		trh.product_code_in as "damagedModel", trh.claim_type as "claimType", trh.created_on as "createdOn", trh.claiming_status as "claimingStatus", 
		rs.status_name as "repairStatus", 
		rs.customer_repair_status as "customerRepairStatus", 
		srs.status_name as "repairStatus2",
		trh.claiming_status AS "jobStatus", 
		trh.oem_in as "oemName",
		trh.rsp_date_in as "rspDateIn",
		trh.rsp_date_out as "rspDateOut",
		trh.problem_description as "problemFoundCodeDescription",
		co.name as "customerCountry", 
		mr.rsp_name as "rspName",
		(SELECT coalesce(primary_code)  
		from job_customer_complaint where job_id = trh.id and is_active = true and flag = 1 order by id limit 1) as "customerComplaintCode",
		mm.model_name as "modelName", mm.model_description as "modelDescription"--, trh.cid
		FROM public.job_head_new trh
		LEFT JOIN public.tr_consumer cu ON trh.consumer_id::integer = cu.id
		LEFT JOIN public.mst_model mm ON trh.product_code_in_id = mm.id and mm.is_active = true
		LEFT JOIN public.mst_repair_status rs on rs.b2x_code = trh.repair_status::text
		LEFT JOIN public.mst_second_status srs on srs.customer_code = trh.second_repair_status::text and srs.is_active = true
		LEFT JOIN public.mst_country co ON co.iso_code = cu.country and co.is_active = true
		LEFT JOIN public.mst_oem mo ON trh.oem_in_id = mo.id 
		LEFT JOIN public.mst_rsp mr ON trh.partner_id = mr.rsp_id
		WHERE (
			(trh.b2x_job_number = "jobN" OR "jobN" IS NULL OR "jobN" = '') AND
			(trh.imei_number_in = "imeiNumber" OR "imeiNumber" IS NULL OR "imeiNumber" = '') AND
			(LOWER(trh.repair_status) = LOWER("actionStatus") OR "actionStatus" IS NULL OR "actionStatus" = '') AND
			(trh.claim_id = "rmaId" OR "rmaId" IS NULL OR "rmaId" = '') AND
			(LOWER(trh.claiming_status) = LOWER("jobStatus") OR "jobStatus" IS NULL OR "jobStatus" = '') AND
			(mr.id = "rsp" OR "rsp" IS NULL) AND
			(LOWER(trh.claim_type) = LOWER("claimT") OR "claimT" IS NULL OR "claimT" = '') AND
			(trh.oem_in_id = "oem" OR "oem" IS NULL) AND
			(trh.channel = LOWER(channelName) OR channelName IS NULL OR channelName = '')
		      )
		ORDER BY trh.id DESC
		OFFSET "pageIndex" LIMIT "pageSize"
	)r);
	"totalRecords":= (
		SELECT count(1) FROM public.job_head_new trh
		LEFT JOIN public.mst_rsp mr ON trh.partner_id = mr.rsp_id 
		WHERE (
			(trh.b2x_job_number = "jobN" OR "jobN" IS NULL OR "jobN" = '') AND
			(trh.imei_number_in = "imeiNumber" OR "imeiNumber" IS NULL OR "imeiNumber" = '') AND
			(LOWER(trh.repair_status) = LOWER("actionStatus") OR "actionStatus" IS NULL OR "actionStatus" = '') AND
			(trh.claim_id = "rmaId" OR "rmaId" IS NULL OR "rmaId" = '') AND
			(LOWER(trh.claiming_status) = LOWER("jobStatus") OR "jobStatus" IS NULL OR "jobStatus" = '') AND
			(mr.id = "rsp" OR "rsp" IS NULL) AND
			(LOWER(trh.claim_type) = LOWER("claimT") OR "claimT" IS NULL OR "claimT" = '') AND
			(trh.oem_in_id = "oem" OR "oem" IS NULL) AND
			(trh.channel = LOWER(channelName) OR channelName IS NULL OR channelName = '')
		)
	);
END;
$function$
