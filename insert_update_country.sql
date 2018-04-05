CREATE OR REPLACE FUNCTION public.insert_update_country(country_id integer, countryname text, countryisocode text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_country where LOWER(iso_code) = LOWER(countryisocode) OR LOWER(name) = LOWER(countryname));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Country ISO Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_country(name, iso_code, is_active, created_on, created_by)
			VALUES( countryname, countryisocode, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Country Code Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND country_id is not null) then
			update_count:= (select count(1) from mst_country where LOWER(iso_code) = LOWER(countryisocode) AND id != country_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Country Code is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_country
				   SET name=countryname, iso_code=countryisocode, is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = country_id;
				return '{ "status": "pass", "message": "Country Code Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
