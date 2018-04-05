CREATE OR REPLACE FUNCTION public.insert_update_model(model_id integer, modelcode text, modelname text, modeldescription text, devicetype text, oemid integer, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_model where LOWER(model_code) = LOWER(modelcode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Model Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_model(model_code, model_name, model_description, device_type, oem_id, is_active, created_on, created_by)
			VALUES( modelcode, modelname, modeldescription, devicetype, oemid, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Model Master Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND model_id is not null) then
			update_count:= (select count(1) from mst_model where LOWER(model_code) = LOWER(modelcode) AND id != model_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Model is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_model
				   SET model_name=modelname, model_description=modeldescription, is_active=isactive, updated_on=now(), updated_by=userid
				 WHERE id = model_id;
				return '{ "status": "pass", "message": "Model Master Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
