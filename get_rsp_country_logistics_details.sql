CREATE OR REPLACE FUNCTION public.get_rsp_country_logistics_details(customerid integer, countryisocode text, repairprogramid integer, isactive boolean)
 RETURNS TABLE(id integer, "repairProgramId" integer, "repairProgram" text, "repairProgramCodeName" text, "rspId" integer, "rspName" text, "customerId" integer, "customerName" text, email text, "serviceIsoCode" text, "serviceIsoCountry" text, "logisticId" integer, "logisticName" text, "logisticAccount" text, "labelPrint" boolean, "preAlert" boolean, "serviceType" text, "returnService" text, "serviceEmail" text, "servicePhone" text, "serviceHours" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
                                                                                                                                                                                               
 DECLARE                                                                                                                                                                                       
 BEGIN                                                                                                                                                                                         
         --RAISE NOTICE 'data==>: %', customerId;                                                                                                                                              
         IF (customerId is null AND countryIsoCode = 'null' AND repairProgramId is null AND isActive is null) THEN                                                                             
                                                                                                                                                                                               
                 RETURN QUERY select mrpcrlm.id, mrpcrlm.repair_program_id, mrp.name as "repairProgram", mrp.code||' - '||mrp.name as "repairProgramCodeName",                                 
                         mrpcrlm.rsp_id, mr.rsp_name as "rspName", mrpcrlm.customer_id, mc.name as "customerName", mrpcrlm.e_mail, mrpcrlm.service_iso_code,                                   
                         mctr.iso_code||' - '||mctr.name as "serviceIsoCountry",                                                                                                               
                         mrpcrlm.logistic_id, ml.partner_name as "logisticName", mrpcrlm.logistic_account, mrpcrlm.label_print, mrpcrlm.pre_alert,                                             
                         mrpcrlm.service_type, mrpcrlm.service_email,mrpcrlm.service_phone, mrpcrlm.service_hours, mrpcrlm.is_active, mrpcrlm.created_on, mrpcrlm.updated_on,                  
                         case when mrpcrlm.return_service = 't' then true else false end return_service,mrpcrlm.proforma_invoice                                                               
                         from mst_repair_program_country_rsp_logistic_mapping mrpcrlm                                                                                                          
                         left join mst_repair_program mrp on mrp.id = mrpcrlm.repair_program_id                                                                                                
                         left join mst_rsp mr on mr.id = mrpcrlm.rsp_id                                                                                                                        
                         left join mst_logistic_partner ml on ml.id = mrpcrlm.logistic_id                                                                                                      
                         left join mst_customer mc on mc.id = mrpcrlm.customer_id                                                                                                              
                         left join mst_country mctr on mctr.iso_code = mrpcrlm.service_iso_code                                                                                                
                         ORDER BY id;                                                                                                                                                          
         ELSE                                                                                                                                                                                  
                 RETURN QUERY select mrpcrlm.id, mrpcrlm.repair_program_id, mrp.name as "repairProgram", mrp.code||' - '||mrp.name as "repairProgramCodeName",                                 
                         mrpcrlm.rsp_id, mr.rsp_name as "rspName", mrpcrlm.customer_id, mc.name as "customerName", mrpcrlm.e_mail, mrpcrlm.service_iso_code,                                   
                         mctr.iso_code||' - '||mctr.name as "serviceIsoCountry",                                                                                                               
                         mrpcrlm.logistic_id, ml.partner_name as "logisticName", mrpcrlm.logistic_account, mrpcrlm.label_print, mrpcrlm.pre_alert,                                             
                         mrpcrlm.service_type, mrpcrlm.service_email,mrpcrlm.service_phone, mrpcrlm.service_hours, mrpcrlm.is_active, mrpcrlm.created_on, mrpcrlm.updated_on,                  
                         case when mrpcrlm.return_service = 't' then true else false end return_service,mrpcrlm.proforma_invoice                                                               
                         from mst_repair_program_country_rsp_logistic_mapping mrpcrlm                                                                                                          
                         left join mst_repair_program mrp on mrp.id = mrpcrlm.repair_program_id                                                                                                
                         left join mst_rsp mr on mr.id = mrpcrlm.rsp_id                                                                                                                        
                         left join mst_logistic_partner ml on ml.id = mrpcrlm.logistic_id                                                                                                      
                         left join mst_customer mc on mc.id = mrpcrlm.customer_id                                                                                                              
                         left join mst_country mctr on mctr.iso_code = mrpcrlm.service_iso_code                                                                                                
                         WHERE (                                                                                                                                                               
                                 (mrpcrlm.customer_id = customerid OR customerid IS NULL) AND                                                                                                  
                                 (LOWER(mrpcrlm.service_iso_code) = LOWER(countryIsoCode) OR countryIsoCode IS NULL OR countryIsoCode = '' OR countryIsoCode ='null') AND                      
                                 (mrpcrlm.repair_program_id = repairProgramId OR repairProgramId IS NULL) AND                                                                                  
                                 (mrpcrlm.is_active = isActive OR isActive IS NULL)                                                                                                            
                         )                                                                                                                                                                     
                         ORDER BY id;                                                                                                                                                          
         END IF;                                                                                                                                                                               
 END;
$function$
