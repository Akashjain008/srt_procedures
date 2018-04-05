CREATE OR REPLACE FUNCTION public.insert_update_user(edituserid integer, firstname text, lastname text, username text, userpassword text, emailid text, contactnumber text, alternatecontactnumber text, roleid integer, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from ui_user where LOWER(login_id) = LOWER(username) AND role_id = roleid);
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "User is Already Present.", "code": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.ui_user(first_name, last_name, login_id, password, email_id, contact_num, alternate_contact_num, created_on, created_by, is_active, role_id)
			VALUES( firstname, lastname, username, userpassword, emailid, contactnumber, alternatecontactnumber, now(), userid, isactive, roleid);
			
			return '{ "status": "pass", "message": "User Inserted successfully.", "code": "COM001" }';
		elseif (flag = 'u' AND edituserid is not null) then
			update_count:= (select count(1) from ui_user where ((LOWER(login_id) = LOWER(username)) AND (role_id = roleid) AND (id != edituserid)));
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "User is Already Present.", "code": "COM004" }';
			ELSE
				UPDATE public.ui_user
				   SET first_name=firstname, last_name=lastname, login_id=username, password=userpassword, email_id=emailid,
				   contact_num=contactnumber, alternate_contact_num=alternatecontactnumber, role_id=roleid, is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = edituserid;
				return '{ "status": "pass", "message": "User Updated successfully.", "code": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "code": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
