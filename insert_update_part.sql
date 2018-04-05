CREATE OR REPLACE FUNCTION public.insert_update_part(part_id integer, partcode text, partname text, partdesc text, partgrouping text, oemid integer, partserialized boolean, repairlevel text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_part where LOWER(part_code) = LOWER(partcode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Part is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_part(part_code, part_name, part_description, part_grouping, oem_id, serialized, repair_level, is_active, created_on, created_by)
			VALUES( partcode, partname, partdesc, partgrouping, oemid, partserialized, repairlevel, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND part_id is not null) then
			update_count:= (select count(1) from mst_part where LOWER(part_code) = LOWER(partcode) AND id != part_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Part is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_part
				   SET part_code=partcode, part_name=partname, part_description=partdesc, part_grouping=partgrouping, oem_id=oemid, serialized=partserialized, 
					repair_level=repairlevel, is_active=isactive, updated_on=now(), updated_by=userid
				 WHERE id = part_id;
				return '{ "status": "pass", "message": "Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
