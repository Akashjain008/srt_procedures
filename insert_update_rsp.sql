CREATE OR REPLACE FUNCTION public.insert_update_rsp(rid integer, rspid text, rspname text, address text, email text, contactpname text, contactpphone text, contactpemail text, city text, state text, isocode text, pincode text, rspphone text, rspbcc text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
count1 integer;
    BEGIN
	count:= (select count(1) from mst_rsp where rsp_id = rspid or LOWER(rsp_name) = LOWER(rspname));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Repair Site is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_rsp(rsp_id, rsp_name, rsp_address, rsp_email, rsp_contact_person_name, 
				       rsp_contact_person_phone_number, rsp_contact_person_email, rsp_city, 
				       rsp_state, rsp_iso_code, rsp_pincode, rsp_phone_number, rsp_bcc, is_active, 
				       created_on, created_by)
			VALUES(rspid, rspname, address, email, contactpname, 
				contactpphone, contactpemail, city, 
				state, isocode, pincode, rspphone, rspbcc, isactive,
				now(), userid);
			
			return '{ "status": "pass", "message": "Repair Site Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND rid is not null) then
			count1:= (select count(1) from mst_rsp where (rsp_id = rspid or LOWER(rsp_name) = LOWER(rspname)) and id != rid);
			IF (count1 > 0) THEN
				return '{ "status": "fail", "message": "Repair Site is Already Present.", "errorCode": "COM004" }';
			ELSE
					UPDATE public.mst_rsp
					   SET rsp_id = rspid, rsp_name = rspname, rsp_address = address, rsp_email = email, rsp_contact_person_name = contactpname, 
						rsp_contact_person_phone_number = contactpphone, rsp_contact_person_email = contactpemail, rsp_city = city, 
						rsp_state = state, rsp_iso_code = isocode, rsp_pincode = pincode, rsp_phone_number = rspphone, rsp_bcc = rspbcc, 
						is_active = isactive, updated_on = now(), updated_by = userid
					 WHERE id = rid;
				return '{ "status": "pass", "message": "Repair Site Updated successfully.", "errorCode": "COM002" }';
			end if;	
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
