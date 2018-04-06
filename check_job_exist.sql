CREATE OR REPLACE FUNCTION public.check_job_exist(claimid text, rspid text)
 RETURNS TABLE("claimId" integer, "rspId" text, "b2xJobNumber" text, "claimingStatus" text)
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
BEGIN
	IF EXISTS (Select 1 from mst_rsp WHERE rsp_id = rspid ) THEN
		count := (select count(*) from job_head_new 
			where LOWER(partner_id) = LOWER(rspid) 
			AND LOWER(claim_id) = LOWER(claimid) 
			AND is_active = TRUE);
		if (count >= 1) then
			RETURN QUERY select claim_id, partner_id, b2x_job_number, claiming_status from job_head_new 
			where LOWER(partner_id) = LOWER(rspid) 
			AND LOWER(claim_id) = LOWER(claimid) 
			AND is_active = TRUE;
		else
			RETURN QUERY select b2x_job_number, partner_id, b2x_job_number, claiming_status from job_head_new 
			where LOWER(partner_id) = LOWER(rspid) 
			AND LOWER(b2x_job_number) = LOWER(claimid) 
			AND is_active = TRUE;
		end if;
	
	END IF;

END;
$function$
