CREATE OR REPLACE FUNCTION public.get_sku_master()
 RETURNS TABLE("skuId" integer, "skuCode" text, "modelName" text)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT id, sku_code, model_code||' - '||model_description FROM public.mst_sku where is_active = TRUE;
    END;
$function$
