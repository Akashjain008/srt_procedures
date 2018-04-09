CREATE OR REPLACE FUNCTION public.authenticate(login int4, pass text, OUT "userData" json[], OUT pages json[], OUT "innerPages" json[], OUT projects json[])
 RETURNS record
 LANGUAGE plpgsql
AS $function$
    BEGIN
	"userData" := ARRAY(SELECT row_to_json(r) FROM(SELECT id, role_id as "roleId", login_id as "loginId", first_name || ' ' || last_name as name
 			 FROM ui_user
 			 WHERE LOWER("login_id") = LOWER(login) AND password = pass)r);

	"pages" := ARRAY(SELECT row_to_json(r) FROM(SELECT page_header_order, array_agg(page_url), page_under, icon
			FROM mst_page
			WHERE is_active = TRUE	AND role_id = (SELECT role_id FROM ui_user WHERE LOWER(login_id) = LOWER(login) AND password = pass) 
			AND "level" = 1	
			GROUP BY page_under, icon, page_header_order)r);

			RAISE NOTICE '%',"pages";

	"innerPages" := ARRAY(SELECT row_to_json(r) FROM(SELECT  array_agg(page_url)
			FROM mst_page
			WHERE is_active = TRUE	AND role_id = (SELECT role_id FROM ui_user WHERE LOWER(login_id) = LOWER(login) AND password = pass) 
			AND "level" = 2)r);

	"projects" :=   ARRAY(SELECT row_to_json(r) FROM(
				select array_agg(lower(p.project_name)) as "projectName"
				from ui_user u
				left join user_project_mapping upm on u.id = upm.user_id
				left join mst_project p on p.id = upm.project_id

				where LOWER(u.login_id) = LOWER(login)
				AND u.password = pass
				AND u.is_active = true
				AND p.is_active = true
			)r);
    END;
$function$
