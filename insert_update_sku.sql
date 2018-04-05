CREATE OR REPLACE FUNCTION public.insert_update_sku(sku_id integer, modelcode text, modelname text, modeldescription text, skucode text, oemid integer, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_sku where LOWER(model_code) = LOWER(modelcode) OR LOWER(sku_code) = LOWER(skucode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Model Code or SKU Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_sku(model_code, model_name, model_description, sku_code, oem_id, is_active, created_on, created_by)
			VALUES( modelcode, modelname, modeldescription, skucode, oemid, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND sku_id is not null) then
			update_count:= (select count(1) from mst_sku where (LOWER(model_code) = LOWER(modelcode) OR LOWER(sku_code) = LOWER(skucode)) AND id != sku_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "SKU is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_sku
				   SET model_code = modelcode, model_name=modelname, model_description=modeldescription, is_active=isactive, updated_on=now(), updated_by=userid
				 WHERE id = sku_id;
				return '{ "status": "pass", "message": "Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
