CREATE OR REPLACE FUNCTION public.get_currency()
 RETURNS TABLE(id integer, currency text, code text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY select mc.id, mc.currency, mc.code, mc.is_active from mst_currency mc where mc.is_active = TRUE;
    END;
$function$
