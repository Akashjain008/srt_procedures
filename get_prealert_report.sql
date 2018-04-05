CREATE OR REPLACE FUNCTION public.get_prealert_report(rsp_id text[])
 RETURNS json
 LANGUAGE plpgsql
AS $function$
    BEGIN
		--RAISE NOTICE '%', rsp_id;
	    RETURN (select array_to_json(array_agg(row_to_json(row)))from(
						
			  SELECT
                    jh.id as "jobId", jh.logistic_inbound_awb as "awbIn",
                    jh.b2x_job_number as "claimId", jd.logistic_inbound_courier_name as "courierIn",c.passport_number as "taxId",-- jd.tax_id as "taxId", 
                    c.name as "enduserName", c.email as "enduserEmail", c.street as "enduserStreet",
                    c.street_number as "enduserStreetNumber",
                   -- coalesce(c.address_line1, null) ||' '|| coalesce(', '|| c.address_line2, null) as "enduserAddress",
                    coalesce(c.address_line1, '') ||' '|| coalesce(', '|| c.address_line2, '') as "enduserAddress",
                    c.district as "enduserDistrict", c.city as "enduserTown", c.zip as "enduserZipCode",
                    c.comments as "comments", c.home_phone as "enduserPhone",c.mobile as "enduserMobile",
                    c.state as "enduserState", c.country as "enduserCountry", jh.imei_number_in as "imeiNumberIn",
                    jh.oem_in as "oem", jh.product_code_in as "productCodeIn", jh.project as "project",
                    jh.partner_id as "repairServicePartnerId", jh.repair_status as "repairStatusCode", 
                    jh.job_creation_date as "jobCreationDate", jh.expected_tat as "expectedTat"
                    ,(select ARRAY(
                    		select jcc1."primary_code" as "customerComplaintCodePrimary" 
							from job_head_new h 
							join job_customer_complaint jcc1 on h.id = jcc1.job_id and jcc1.flag = 1 and jcc1.is_active = true
							where h.id = jh.id)) as "customerComplaintCodePrimary"
                FROM 
                    job_head_new jh join job_detail_new jd on jh.job_detail_id = jd.id 
                    join tr_consumer c on c.id = jh.consumer_id::integer
                   -- join job_customer_complaint jcc1 on jh.id = jcc1.job_id and jcc1.flag = 1 and jcc1.is_active = true
                WHERE 
                    jh.repair_status::integer = 1 and (jh.partner_id in (select unnest(ARRAY[rsp_id])) or rsp_id is null)
                order by jh.id asc
                
	)row
	);
    END;
$function$
