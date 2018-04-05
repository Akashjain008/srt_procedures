CREATE OR REPLACE FUNCTION public.get_sqs_config(api text)
 RETURNS TABLE("queueUrl" text, "userId" text, "accessId" text, "accessKey" text, region text, project text)
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
BEGIN
	return query
	select q.queue_url, q.user_id, q.access_id, q.access_key, q.region, q.project
	from mst_sqs_config q
	where LOWER(q.api_name) = LOWER(api)
	and is_active = true;
END;
$function$
