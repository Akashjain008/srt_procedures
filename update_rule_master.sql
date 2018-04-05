CREATE OR REPLACE FUNCTION public.update_rule_master(ruleid integer, rulename text, flag text, userid text, isactive boolean)
 RETURNS json
 LANGUAGE plpgsql
AS $function$

declare count1 integer;
BEGIN
	count1:= (select count(1) from tr_rule r where r.id = ruleid);
	IF (flag = 'i') then 
		return '{ "status": "fail", "message": "Data cannot be inserted in this table. ", "errorCode": "COM003" }';
	ELSE
		if  (count1 = 0 AND flag = 'u') THEN
		return '{ "status": "fail", "message": "Not present.", "errorCode": "COM004" }';
		elseif (count1 > 0 AND flag = 'u') then
				UPDATE public.tr_rule
				   SET "name" = ruleName,is_active=isactive, updated_on=now(), updated_by=userid
				 WHERE id = ruleid;
				return '{ "status": "pass", "message": "Updated successfully.", "errorCode": "COM002" }';
		else
			return '{ "status": "fail", "message": "Invalid flag input", "errorCode": "COM003" }';
		end if;	
	END IF; 
END

$function$
