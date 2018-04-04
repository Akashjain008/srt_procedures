CREATE OR REPLACE FUNCTION public.auto_b2x_cus_number1()
 RETURNS character varying
 LANGUAGE sql
AS $function$
select 'B2XCUST' || nextval('seq_auto_cus_id')
$function$
