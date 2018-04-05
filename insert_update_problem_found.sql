CREATE OR REPLACE FUNCTION public.insert_update_problem_found(problem_id integer, b2xcode text, customercode text, problemdescription text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_problem_found where LOWER(b2x_code) = LOWER(b2xcode));
	IF (count > 0 AND flag = 'i' ) THEN
		return '{ "status": "fail", "message": "Problem Found B2X Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_problem_found(b2x_code, customer_code, problem_description, is_active, created_on, created_by)
			VALUES( b2xcode, customercode, problemdescription, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Problem Found Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND problem_id is not null) then
			update_count:= (select count(1) from mst_problem_found where LOWER(b2x_code) = LOWER(b2xcode) AND id != problem_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Problem Found is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_problem_found
				   SET b2x_code=b2xcode, customer_code=customercode, problem_description=problemdescription, is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = problem_id;
				return '{ "status": "pass", "message": "Problem Found Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
