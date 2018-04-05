CREATE OR REPLACE FUNCTION public.get_all_ui_jobs_list("pageIndex" integer, "pageSize" integer, "jobNumber" text, "imeiNumber" text, "actionStatus" text, "jobStatus" text, "rspId" integer, "rmaId" text, "claimType" text, "returnMethod" text, "oemId" integer, "channelName" text, OUT "jobData" json[], OUT "totalRecords" integer)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
BEGIN

if ("pageIndex" is not null and "pageSize" != 0) then

	"jobData":= ARRAY(SELECT row_to_json(r) 
	FROM(

		SELECT trh.id, trh.b2x_job_number AS "jobN", trh.imei_number_in AS "imeiNumber", trh.oem_in As "damagedManufacturer", trh.claim_id AS "claimId",
		trh.product_code_in as "damagedModel", trh.claim_type as "claimType", trh.created_on as "createdOn", trh.claiming_status as "claimingStatus", 
		rs.status_name as "repairStatus", rs.customer_repair_status as "customerRepairStatus", srs.status_name as "repairStatus2",
		trh.claiming_status AS "jobStatus", trh.oem_in as "oemName", trh.rsp_date_in as "rspDateIn", trh.rsp_date_out as "rspDateOut",
		trh.problem_description as "problemFoundCodeDescription", co.name as "customerCountry", mr.rsp_name as "rspName",
		(SELECT coalesce(primary_code)  
		from job_customer_complaint where job_id = trh.id and is_active = true and flag = 1 order by id limit 1) as "customerComplaintCode",
		mm.model_name as "modelName", mm.model_description as "modelDescription"--, trh.cid
		FROM public.job_head_new trh
		LEFT JOIN public.tr_consumer cu ON trh.consumer_id::integer = cu.id
		LEFT JOIN public.mst_model mm ON  lower(trh.product_code_in) = lower(mm.model_code) and mm.is_active = true
		--LEFT JOIN public.mst_model mm ON trh.product_code_in_id = mm.id and mm.is_active = true
		LEFT JOIN public.mst_repair_status rs on rs.b2x_code = trh.repair_status::text
		LEFT JOIN public.mst_second_status srs on srs.customer_code = trh.second_repair_status::text and srs.is_active = true
		LEFT JOIN public.mst_country co ON co.iso_code = cu.country and co.is_active = true
		LEFT JOIN public.mst_oem mo ON mm.oem_id = mo.id and mo.is_active = true
		LEFT JOIN public.mst_rsp mr ON trh.partner_id = mr.rsp_id
		WHERE (
			(trh.b2x_job_number = "jobNumber" OR "jobNumber" IS NULL OR "jobNumber" = '') AND
			(trh.imei_number_in = "imeiNumber" OR "imeiNumber" IS NULL OR "imeiNumber" = '') AND
			(LOWER(trh.repair_status) = LOWER("actionStatus") OR "actionStatus" IS NULL OR "actionStatus" = '') AND
			(trh.claim_id = "rmaId" OR "rmaId" IS NULL OR "rmaId" = '') AND
			(LOWER(trh.claiming_status) = LOWER("jobStatus") OR "jobStatus" IS NULL OR "jobStatus" = '') AND
			(mr.id = "rspId" OR "rspId" IS NULL) AND
			(LOWER(trh.claim_type) = LOWER("claimType") OR "claimType" IS NULL OR "claimType" = '') and
			(mo.id = "oemId" OR "oemId" IS NULL) AND
			(trh.channel = LOWER("channelName") OR "channelName" IS NULL OR "channelName" = '')
		      )
		ORDER BY trh.id DESC
		OFFSET "pageIndex" LIMIT "pageSize"
	)r);

	else

		"jobData":= ARRAY(SELECT row_to_json(r) 
			FROM(

			SELECT  trh.b2x_job_number AS "Job Number", trh.imei_number_in AS "IMEI Number", trh.oem_in As "Damaged Manufaturer", trh.claim_id AS "Claim Id",
			trh.product_code_in as "Damaged Model", trh.claim_type as "Claim Type", trh.created_on as "Created On", trh.claiming_status as "Claiming Status", 
			rs.status_name as "Repair Status", rs.customer_repair_status as "Customer Repair Status", srs.status_name as "Repair Status2",
			trh.claiming_status AS "Job Status", trh.oem_in as "Oem Name", trh.rsp_date_in as "Rsp DateIn", trh.rsp_date_out as "Rsp DateOur",
			trh.problem_description as "Problem Found Code Description", co.name as "Customer Country", mr.rsp_name as "Rsp Name",
			(SELECT coalesce(primary_code)  
			from job_customer_complaint where job_id = trh.id and is_active = true and flag = 1 order by id limit 1) as "Customer Complain Code",
			mm.model_name as "Model Name", mm.model_description as "Model Description"--, trh.cid
			FROM public.job_head_new trh
			LEFT JOIN public.tr_consumer cu ON trh.consumer_id::integer = cu.id
			LEFT JOIN public.mst_model mm ON  lower(trh.product_code_in) = lower(mm.model_code) and mm.is_active = true
			--LEFT JOIN public.mst_model mm ON trh.product_code_in_id = mm.id and mm.is_active = true
			LEFT JOIN public.mst_repair_status rs on rs.b2x_code = trh.repair_status::text
			LEFT JOIN public.mst_second_status srs on srs.customer_code = trh.second_repair_status::text and srs.is_active = true
			LEFT JOIN public.mst_country co ON co.iso_code = cu.country and co.is_active = true
			LEFT JOIN public.mst_oem mo ON mm.oem_id = mo.id and mo.is_active = true
			LEFT JOIN public.mst_rsp mr ON trh.partner_id = mr.rsp_id
			WHERE (
				(trh.b2x_job_number = "jobNumber" OR "jobNumber" IS NULL OR "jobNumber" = '') AND
				(trh.imei_number_in = "imeiNumber" OR "imeiNumber" IS NULL OR "imeiNumber" = '') AND
				(LOWER(trh.repair_status) = LOWER("actionStatus") OR "actionStatus" IS NULL OR "actionStatus" = '') AND
				(trh.claim_id = "rmaId" OR "rmaId" IS NULL OR "rmaId" = '') AND
				(LOWER(trh.claiming_status) = LOWER("jobStatus") OR "jobStatus" IS NULL OR "jobStatus" = '') AND
				(mr.id = "rspId" OR "rspId" IS NULL) AND
				(LOWER(trh.claim_type) = LOWER("claimType") OR "claimType" IS NULL OR "claimType" = '') and
				(mo.id = "oemId" OR "oemId" IS NULL) AND
				(trh.channel = LOWER("channelName") OR "channelName" IS NULL OR "channelName" = '')
			      )
			ORDER BY trh.id DESC
			OFFSET "pageIndex" LIMIT "pageSize"
		)r);
	
	end if;

	
	"totalRecords":= (
		SELECT count(1) FROM public.job_head_new trh
		LEFT JOIN public.tr_consumer cu ON trh.consumer_id::integer = cu.id
		LEFT JOIN public.mst_model mm ON  lower(trh.product_code_in) = lower(mm.model_code) and mm.is_active = true
		--LEFT JOIN public.mst_model mm ON trh.product_code_in_id = mm.id and mm.is_active = true
		LEFT JOIN public.mst_repair_status rs on rs.b2x_code = trh.repair_status::text
		LEFT JOIN public.mst_second_status srs on srs.customer_code = trh.second_repair_status::text and srs.is_active = true
		LEFT JOIN public.mst_country co ON co.iso_code = cu.country and co.is_active = true
		LEFT JOIN public.mst_oem mo ON mm.oem_id = mo.id and mo.is_active = true
		LEFT JOIN public.mst_rsp mr ON trh.partner_id = mr.rsp_id
		WHERE (
			(trh.b2x_job_number = "jobNumber" OR "jobNumber" IS NULL OR "jobNumber" = '') AND
			(trh.imei_number_in = "imeiNumber" OR "imeiNumber" IS NULL OR "imeiNumber" = '') AND
			(LOWER(trh.repair_status) = LOWER("actionStatus") OR "actionStatus" IS NULL OR "actionStatus" = '') AND
			(trh.claim_id = "rmaId" OR "rmaId" IS NULL OR "rmaId" = '') AND
			(LOWER(trh.claiming_status) = LOWER("jobStatus") OR "jobStatus" IS NULL OR "jobStatus" = '') AND
			(mr.id = "rspId" OR "rspId" IS NULL) AND
			(LOWER(trh.claim_type) = LOWER("claimType") OR "claimType" IS NULL OR "claimType" = '') and
			(mo.id = "oemId" OR "oemId" IS NULL) AND
			(trh.channel = LOWER("channelName") OR "channelName" IS NULL OR "channelName" = '')
		)
	);
END;
$function$
