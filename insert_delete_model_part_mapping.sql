CREATE OR REPLACE FUNCTION public.insert_delete_model_part_mapping(modelid integer, partid integer[], userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
i integer;
BEGIN
	FOREACH i IN ARRAY partid
	LOOP
		count:= (select count(1) from mst_model_part_mapping where (model_id = modelid AND part_id = i));
	END LOOP;

	IF (count > 0  AND flag = 'mapped') THEN
		return '{ "status": "fail", "message": "Mapping is Already Present.", "errorCode": "COM006"  }';
	ELSE
		IF (flag = 'mapped') THEN
			FOREACH i IN ARRAY partid
			LOOP
				INSERT INTO public.mst_model_part_mapping(model_id, part_id, created_on, created_by)
				VALUES (modelid, i, now(), userid);
			END LOOP;
			return '{ "status": "pass", "message": "Mapping Inserted successfully.", "errorCode": "COM007" }';
		ELSEIF (flag = 'unmapped') THEN
			FOREACH i IN ARRAY partid
			LOOP
				DELETE FROM public.mst_model_part_mapping WHERE part_id = i AND model_id = modelid;
			END LOOP;
			return '{ "status": "pass", "message": "Mapping Delete successfully.", "errorCode": "COM005" }';
		ELSE
			return '{ "status": "fail", "message": "Invalid flag input", "errorCode": "COM003" }';
		END IF;
	END IF;
END;
$function$
