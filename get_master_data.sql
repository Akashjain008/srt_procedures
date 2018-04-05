CREATE OR REPLACE FUNCTION public.get_master_data(OUT "rspData" json[], OUT "claimTypeData" json[], OUT "repairActionData" json[], OUT "oemData" json[])
 RETURNS record
 LANGUAGE plpgsql
AS $function$

    BEGIN
	"rspData":= ARRAY(SELECT row_to_json(r) 
				FROM(SELECT DISTINCT ON (rsp_name) id, rsp_name as "rspName" FROM mst_rsp where is_active = TRUE)r);
				
 	"claimTypeData":= ARRAY(SELECT row_to_json(r) 
				FROM(SELECT DISTINCT claim_type as "claimType" FROM job_head_new where claim_type IS NOT NULL AND claim_type <> '')r);

	"repairActionData":= ARRAY(SELECT row_to_json(r) 
				FROM(SELECT DISTINCT rs.status_name as "repairStatus", rs.b2x_code as "repairStatusCode" 
					FROM job_head_new jh
					inner join mst_repair_status rs on rs.b2x_code = jh.repair_status 
					where jh.repair_status IS NOT NULL AND jh.repair_status <> '')r);

	"oemData":= ARRAY(SELECT row_to_json(r) 
				FROM(SELECT id, oem_name as "oemName" FROM mst_oem where is_active = TRUE)r);
 	
    END;
$function$
