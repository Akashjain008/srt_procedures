CREATE OR REPLACE FUNCTION public.get_model_sku_mapping(modelid integer)
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
		SELECT ms.id as "skuId", ms.sku_code as "skuCode", ms.model_code||' - '||ms.model_description as "modelName" 
		FROM public.mst_sku ms
		JOIN mst_model_sku_mapping mpm ON mpm.sku_id = ms.id
		JOIN mst_model mm ON mm.id = mpm.model_id
		WHERE ms.is_active = TRUE AND mpm.model_id = modelid --AND LOWER(mp.part_grouping) = LOWER(partgrouping)
	)row);

	--RAISE NOTICE 'mapped=====> %', mapped;

	unmapped:= (select array_to_json(array_agg(row_to_json(row)))
	FROM (
		SELECT ms.id as "skuId", ms.sku_code as "skuCode", ms.model_code||' - '||ms.model_description as "modelName" 
		FROM mst_sku ms 
		WHERE ms.id not in (select sku_id from mst_model_sku_mapping where model_id = modelid)
		AND ms.is_active = TRUE	
		--AND LOWER(mp.part_grouping) = LOWER(partgrouping)

	)row);

	--RAISE NOTICE 'unmapped=====> %', unmapped;

	return '{ "mapped":'||coalesce(mapped, '[]')||', "unmapped":'||coalesce(unmapped, '[]')||' }';
END;
$function$
