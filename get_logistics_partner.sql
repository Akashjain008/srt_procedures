CREATE OR REPLACE FUNCTION public.get_logistics_partner()
 RETURNS TABLE(id integer, "logisticsCode" text, "logisticsName" text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT mlp.id, mlp.partner_code, mlp.partner_name,mlp.is_active FROM mst_logistic_partner mlp where mlp.is_active = TRUE;
    END;
$function$
