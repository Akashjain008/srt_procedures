CREATE OR REPLACE FUNCTION public.insert_update_country_rsp_logistics(eid integer, repairprogramid integer, rspid integer, customerid integer, email text, serviceisocode text, logisticsid integer, logisticsaccount text, labelprint boolean, prealert boolean, servicetype text, returnservice text, serviceemail text, servicephone text, servicehours text, isactive boolean, user_id text, qry_type text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE                                                                                                                                                                       
 count integer;                                                                                                                                                                
 count1 integer;                                                                                                                                                               
 BEGIN                                                                                                                                                                         
         count:= (select count(1) from mst_repair_program_country_rsp_logistic_mapping                                                                                         
                  where (customer_id = customerid AND LOWER(service_iso_code) = LOWER(serviceisocode) AND rsp_id = rspId AND repair_program_id = repairprogramid));            
                                                                                                                                                                               
         IF NOT EXISTS(select id from mst_rsp where id = rspid) THEN                                                                                                           
                  return '{ "status": "fail", "message": "RSP id is not exists.", "errorCode": "COM005"  }';                                                                   
         ELSE                                                                                                                                                                  
         IF NOT EXISTS(select id from mst_logistic_partner where id = logisticsid) THEN                                                                                        
                   return '{ "status": "fail", "message": "Logistics id is not exists.", "errorCode": "COM006"  }';                                                            
         ELSE                                                                                                                                                                  
         IF NOT EXISTS(select id from mst_customer where id = customerid) THEN                                                                                                 
                   return '{ "status": "fail", "message": "customer id is not exists.", "errorCode": "COM007"  }';                                                             
                                                                                                                                                                               
         ELSE                                                                                                                                                                  
         IF NOT EXISTS(select iso_code from mst_country where iso_code = serviceisocode) THEN                                                                                  
                   return '{ "status": "fail", "message": "country is not exists.", "errorCode": "COM008"  }';                                                                 
                                                                                                                                                                               
         ELSE    IF (count > 0 AND qry_type = 'i') THEN                                                                                                                        
                 return '{ "status": "fail", "message": "Country RSP Logistics Mapping is Already Present.", "errorCode": "COM004"  }';                                        
         ELSE                                                                                                                                                                  
                 IF (qry_type = 'i') THEN                                                                                                                                      
                         INSERT INTO public.mst_repair_program_country_rsp_logistic_mapping(                                                                                   
                                 repair_program_id, rsp_id, customer_id, e_mail, service_iso_code, logistic_id,                                                                
                                 logistic_account, label_print, pre_alert, service_type, return_service,                                                                       
                                 service_email, service_phone, service_hours, is_active, created_on, created_by, proforma_invoice)                                             
                         VALUES(repairProgramId, rspId, customerId, email,                                                                                                     
                                 serviceISOCode, logisticsId,                                                                                                                  
                                 logisticsAccount, labelPrint,                                                                                                                 
                                 preAlert, serviceType, returnService,                                                                                                         
                                 serviceEmail, servicePhone, serviceHours,                                                                                                     
                                 isActive, now(), user_id, proformaInvoice);                                                                                                   
                                                                                                                                                                               
                         return '{ "status": "pass", "message": "Country RSP Logistics Mapping inserted successfully.", "errorCode": "COM001"  }';                             
                                                                                                                                                                               
                 ELSEIF (qry_type = 'u' AND eid != 0) THEN                                                                                                                     
                         count1:= (select count(1) from mst_repair_program_country_rsp_logistic_mapping                                                                        
                  where (customer_id = customerid AND LOWER(service_iso_code) = LOWER(serviceisocode) AND rsp_id = rspId AND repair_program_id = repairprogramid) AND id != eid);
                         IF (count1 > 0) THEN                                                                                                                                  
                                 return '{ "status": "fail", "message": "Country RSP Logistics Mapping is Already Present.", "errorCode": "COM004"  }';                        
                         ELSE                                                                                                                                                  
                                 UPDATE public.mst_repair_program_country_rsp_logistic_mapping                                                                                 
                                 SET     repair_program_id = repairProgramId, rsp_id = rspId, customer_id = customerId,                                                        
                                         e_mail=email, service_iso_code=serviceISOCode, logistic_id=logisticsId,                                                               
                                         logistic_account=logisticsAccount, label_print=labelPrint, pre_alert=preAlert,                                                        
                                         service_type=serviceType, return_service=returnService, service_email=serviceEmail,                                                   
                                         service_phone=servicePhone, service_hours=serviceHours, is_active=isActive,                                                           
                                         updated_on=now(), updated_by=user_id, proforma_invoice = proformaInvoice                                                              
                                 WHERE                                                                                                                                         
                                 id = eid;                                                                                                                                     
                                 return '{ "status": "pass", "message": "Country RSP Logistics Mapping Updated successfully.", "errorCode": "COM002"  }';                      
                         END IF;                                                                                                                                               
                 else                                                                                                                                                          
                         return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003"  }';                                                 
                 END IF;                                                                                                                                                       
         END IF;                                                                                                                                                               
 END IF;                                                                                                                                                                       
 END IF;                                                                                                                                                                       
 END IF;                                                                                                                                                                       
 END IF;                                                                                                                                                                       
 END;
$function$
