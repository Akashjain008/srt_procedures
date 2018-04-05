CREATE OR REPLACE FUNCTION public.insert_update_missing_part(action_id integer, partcode text, oemid integer, partname text, partgrouping text, partdesc text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_part where LOWER(part_code) = LOWER(partcode) AND oem_id = oemid);
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Part Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_part(part_code, oem_id, part_name, part_grouping, part_description, is_active, created_on, created_by)
			VALUES( partcode, oemid, partname, partgrouping, partdesc, isactive, now(), userid);

			return '{ "status": "pass", "message": "Part Code Inserted successfully.", "errorCode": "COM001" }';
		-- elseif (flag = 'u' AND action_id is not null) then
-- 			update_count:= (select count(1) from mst_part where LOWER(part_code) = LOWER(partcode) AND id != action_id);
-- 			IF (update_count > 0) THEN
-- 				return '{ "status": "fail", "message": "Part Action Code is Already Present.", "errorCode": "COM004" }';
-- 			ELSE
-- 				UPDATE public.mst_part
-- 				   SET part_code=partcode, oem_id=oemid, part_name=partname, part_grouping=partgrouping, part_description=partdesc, is_active=isactive, 
-- 					updated_on=now(), updated_by=userid
-- 				 WHERE id = action_id;
-- 				return '{ "status": "pass", "message": "Part Code Updated successfully.", "errorCode": "COM002" }';
-- 			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
