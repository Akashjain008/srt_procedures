CREATE OR REPLACE FUNCTION public.get_model_part_mapping(modelid integer, partgrouping text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
mapped text := '';
unmapped text := '';
result text;
BEGIN
	mapped:= (select array_to_json(array_agg(row_to_json(row)))
	FROM (
		SELECT mp.id as "partId", mp.part_code as "partCode", mp.part_name as "partName" 
		FROM public.mst_part mp
		JOIN mst_model_part_mapping mpm ON mpm.part_id = mp.id
		JOIN mst_model mm ON mm.id = mpm.model_id
		WHERE  mp.is_active = TRUE AND mpm.model_id = modelid AND LOWER(mp.part_grouping) = LOWER(partgrouping)
	)row);

	--RAISE NOTICE 'mapped=====> %', mapped;

	unmapped:= (select array_to_json(array_agg(row_to_json(row)))
	FROM (
		SELECT mp.id as "partId", mp.part_code as "partCode", mp.part_name as "partName"
		FROM mst_part mp 
		WHERE mp.id not in (select part_id from mst_model_part_mapping where model_id = modelid)		
		AND LOWER(mp.part_grouping) = LOWER(partgrouping)
		AND mp.is_active = TRUE

	)row);

	--RAISE NOTICE 'unmapped=====> %', unmapped;

	return '{ "mapped":'||coalesce(mapped, '[]')||', "unmapped":'||coalesce(unmapped, '[]')||' }';
END;
$function$
