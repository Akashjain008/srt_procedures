CREATE OR REPLACE FUNCTION public.insert_update_claim_type(claim_id integer, claimcode text, claimname text, claimdescription text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_claim_type where LOWER(claim_code) = LOWER(claimcode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Claim Type is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_claim_type(claim_code, claim_name, claim_description, is_active, created_on, created_by)
			VALUES( claimcode, claimname, claimdescription, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Claim Type Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND claim_id is not null) then
			update_count:= (select count(1) from mst_claim_type where LOWER(claim_code) = LOWER(claimcode) AND id != claim_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Claim Type is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_claim_type
				   SET claim_code=claimcode, claim_name=claimname, claim_description=claimdescription,is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = claim_id;
				return '{ "status": "pass", "message": "Claim Type Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
