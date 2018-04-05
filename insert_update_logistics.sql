CREATE OR REPLACE FUNCTION public.insert_update_logistics(logistics_id integer, logisticscode text, logisticsname text, logisticstype text, logisticsdesc text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_logistic_status where (LOWER(logistics_code) = LOWER(logisticscode) OR LOWER(logistics_name) = LOWER(logisticsname)));

	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Logistics is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_logistic_status(logistics_code, logistics_name, logistics_type, logistics_description, is_active, created_on, created_by)
			VALUES( logisticscode, logisticsname, logisticstype, logisticsdesc, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Logistics Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND logistics_id IS NOT NULL) then
			update_count:= (select count(1) from mst_logistic_status where (LOWER(logistics_code) = LOWER(logisticscode) OR LOWER(logistics_name) = LOWER(logisticsname)) AND id != logistics_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Logistics is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_logistic_status
				   SET logistics_code=logisticscode, logistics_name=logisticsname, logistics_type=logisticstype, logistics_description=logisticsdesc, is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = logistics_id;
				return '{ "status": "pass", "message": "Logistics Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	

	END IF; 
	
    END;
$function$
