CREATE OR REPLACE FUNCTION public.get_model_master()
 RETURNS TABLE("modelId" integer, "modelCode" text, "modelDesc" text)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT id, model_code, model_description FROM public.mst_model where is_active = TRUE;
    END;
$function$
