CREATE OR REPLACE FUNCTION public.create_job_new(arrayjobs text, filename text, b2xreqid text, channel text, username text, userid integer)
 RETURNS TABLE("claimId" text, "claimLineId" text, "errorList" json, "insertedIntoDb" boolean, "jobNumber" text, project text, "repairStatus" integer)
 LANGUAGE plpgsql
AS $function$

declare job record;
declare get_primaryCode record;
declare get_secondaryCode record;
declare get_deductible record;

declare get_jobhead_id integer;
declare get_customer_id integer;
declare get_customer_code text;
declare get_jobnumber text;
declare get_jobdetail_id integer;
declare get_model_id integer;
declare get_sku_id integer;
declare get_rsp_id text;
Begin
	-- Create temp table to hold json data
	drop table if exists tmp_jobinserteddata;
	create temp table tmp_jobinserteddata("id" serial,"job_number" text, "claim_Id" text,"claim_line_id" text, "project" text, "repair_status" integer, "error_List" json, "insertedInto_Db" boolean);
	-- Loop through jobs available in array
	FOR job IN 
		select * from json_to_recordset(arrayJobs::json) as ("claimId" text,"claimLineId" text,"claimType" text,"customerName" text,"customerEmail" text,
		"customerHomePhone" text, "customerId" text, "customerMobile" text,"customerAddressLine1" text,"customerAddressLine2" text,
		"customerCity" text,"customerZip" text,
		"customerState" text,"customerCountry" text,"damagedSku" text,"damagedModel" text,"damagedImei" text,"damagedImei2" text,"damagedSerialNumber" text,
		"repairStatus2" integer,"deviceDateOfPurchase" timestamp with time zone,"deductibleRequired" boolean,"accidentValid" boolean,"docImeiOk" boolean,
		"docInvoiceNumberOk" boolean,"docInvoicePrice" boolean,"docInvoiceDateOk" boolean,"deviceIrrepairable" boolean,
		"deviceInvoiceNumber" text,"certificateNumber" text,"insuranceCoverage" text,"accidentDescription" text,"deviceBer" boolean,
		"accidentDate" timestamp with time zone,"complaintDate" date,"customerComplaintCodePrimary" json,
		"customerComplaintCodeSecondary" json,"insuranceStartDate" timestamp with time zone,"jobCreationDate" timestamp with time zone,
		"deviceManufactureDate" timestamp with time zone,"oem" text,"popSupplier" text,"productType" text,
		"project" text,"providerOrCarrier" text,"partnerId" text, "errorList" json, 
		"custom_1" text, "custom_2" text, "custom_3" text, "custom_4" text, "custom_5" text, "custom_6" text,
		"custom_7" text, "custom_8" text, "custom_9" text, "custom_10" text,
		"repairTimestamp" timestamp with time zone, "reportDate" timestamp with time zone, "returnDate" timestamp with time zone,
		"transactionCode" integer, "deductible" json, "accidentId" text, "additionalService" text, "claimCreationDate" timestamp with time zone,
		"collectDeductible" boolean, "collectDevicePackaging" boolean, "commentary" text, "customerPassportCountry" text,
		"customerPassportNumber" text, "damagedType" text, "deviceConfiguration" text, "deviceValue" numeric(18,2), "deviceValueCurrency" text,
		"employeeNumber" text, "logisticInBoundShipmentType" integer, "insuranceBroker" text, "insuranceEndDate" timestamp with time zone,
		"loanPhone" boolean, "maxRepairCost" numeric(18,2), "maxRepairCostCurrency" text, "logisticOutBoundShipmentType" integer,
		"pickupDate" timestamp with time zone, "replacementModel" text, "replacementOem" text, "replacementSku" text,
		"replacementType" text, "salePrice" numeric(18,2), "salePriceCurrency" text, "softwareIn" text, "specialInstructions" text,
		"taxId" text, "transportInsr" boolean, "transportInsrCurrency" text, "transportInsrValue" numeric(18,2), "warranty" boolean,
		"partnerJobNumber" text, "logisticInBoundAwb" text,"logisticOutBoundAwb" text,"logisticInBoundCourierName" text,"logisticOutBoundCourierName" text, "cid" boolean,
		"billingCustomerAddressLine1" text,"billingCustomerAddressLine2" text,"billingCustomerCity" text,"billingCustomerState" text,"billingCustomerZip" text,"billingCustomerCountry" text,
		"insuranceProductName" text,"insurancePolicyNumber" text, "repairStatus" text, "street" text, "streetNumber" text, "district" text, "comments" text,
		"billingStreet" text, "billingStreetNumber" text, "billingDistrict" text, "customerLanguage" text
		, "expectedTat" text, "logisticInBoundCourierType" text, "logisticOutBoundCourierType" text)
	LOOP
		--==============insert the consumer data========
		INSERT INTO public.tr_consumer (code, name,address_line1,address_line2,zip,city,state,country,email,home_phone,mobile,is_active,
		created_on,created_by, customer_id, passport_country, passport_number,
		billing_address_line1,billing_address_line2,billing_zip,billing_city,billing_state,billing_country,
		street, street_number, district, comments, billing_street, billing_street_number, billing_district, language_code)
		values(auto_b2x_cus_number(), job."customerName",job."customerAddressLine1",job."customerAddressLine2",job."customerZip",
		job."customerCity",job."customerState",job."customerCountry",job."customerEmail",job."customerHomePhone",
		job."customerMobile",true,now(),1, job."customerId", job."customerPassportCountry", job."customerPassportNumber",
		job."billingCustomerAddressLine1",job."billingCustomerAddressLine2",job."billingCustomerCity",job."billingCustomerState",job."billingCustomerZip",job."billingCustomerCountry",
		job."street", job."streetNumber", job."district", job."comments", job."billingStreet", job."billingStreetNumber", job."billingDistrict", job."customerLanguage")
		returning id into get_customer_id;
		--==============get consumer Id from the consumer data=======
		--get_customer_code = 'CUS' || to_char(now(), 'YYYYMMDD') || TO_CHAR(get_customer_id,'fm000000');
		--==============get consumer Code and update in consumer data=======
		--UPDATE public.tr_consumer set code=get_customer_code where id=get_customer_id;
		--==============get Model id from model table=======
		if (job."damagedModel" is not null and job."damagedModel" !='') THEN
			get_model_id := (select id from mst_model where model_code = job."damagedModel" and is_active = true limit 1);
		End if;
		--==============get sku id from sku table=======
		if (job."damagedSku" is not null and job."damagedSku" !='') THEN
			get_sku_id := (select id from mst_sku where sku_code = job."damagedSku" and is_active = true limit 1);
		end if;
		--==============get rsp id base on custome country=======
		if (job."partnerId" is not null and job."partnerId" !='') THEN
			get_rsp_id:= job."partnerId";
		elseif (job."customerCountry" is not null and job."customerCountry" !='') THEN
			select rsp_id INTO get_rsp_id from mst_rsp where rsp_iso_code = job."customerCountry" and is_active = true limit 1;
		end if;
		--==============insert into job head data========
		INSERT INTO public.job_head_new(claim_id,claim_type,consumer_id, device_date_of_purchase, product_code_in_id,product_code_in, sku_in,sku_in_id,
		imei_number_in,claiming_status,
		serial_number_in,repair_status,second_repair_status, device_ber, accident_valid, doc_imei_ok, doc_invoice_number_ok, doc_invoice_price,
		doc_invoice_date_ok, device_irrepairable, insurance_coverage, certificate_number, accident_description, device_invoice_number,
		deductible_required, accident_date,complaint_date,insurance_start_date,job_creation_date,device_manufacture_date,oem_in,
		pop_supplier,product_type,project,provider_or_carrier, partner_id,
		is_active, created_on, repair_timestamp, report_date, return_date, transaction_code, imei_2_in, software_in,
		partner_job_number, accident_id, claim_creation_date, insurance_broker, insurance_end_date,
		type_in, pickup_date, product_code_out, oem_out, sku_out, type_out, warranty,
		logistic_inbound_shipment_type,logistic_outbound_shipment_type, logistic_inbound_awb, logistic_outbound_awb,
		insurance_product_name,insurance_policy_number, channel, user_name, user_id
		, expected_tat, logistic_inbound_courier_type, logistic_outbound_courier_type)
		VALUES (job."claimId",job."claimType",get_customer_id,job."deviceDateOfPurchase",get_model_id,job."damagedModel",
		job."damagedSku",get_sku_id, job."damagedImei",'Open', job."damagedSerialNumber", coalesce(job."repairStatus", '1'), job."repairStatus2", job."deviceBer",
		job."accidentValid",job."docImeiOk", job."docInvoiceNumberOk", 
		job."docInvoicePrice",job."docInvoiceDateOk", job."deviceIrrepairable", job."insuranceCoverage",job."certificateNumber", 
		job."accidentDescription", job."deviceInvoiceNumber",job."deductibleRequired",
		job."accidentDate",job."complaintDate",job."insuranceStartDate",job."jobCreationDate",job."deviceManufactureDate",job."oem",
		job."popSupplier",job."productType",job."project",job."providerOrCarrier", get_rsp_id,
		true, now(), job."repairTimestamp", job."reportDate", job."returnDate", job."transactionCode", job."damagedImei2",job."softwareIn",
		job."partnerJobNumber", job."accidentId", job."claimCreationDate", job."insuranceBroker", job."insuranceEndDate",
		job."damagedType", job."pickupDate", job."replacementModel", job."replacementOem", job."replacementSku", job."replacementType",
		job."warranty",job."logisticInBoundShipmentType", job."logisticOutBoundShipmentType",
		job."logisticInBoundAwb",job."logisticOutBoundAwb",job."insuranceProductName",job."insurancePolicyNumber", channel, userName, userId
		, job."expectedTat", job."logisticInBoundCourierType", job."logisticOutBoundCourierType")
		--==============get job id from job head table=======
		returning id into get_jobhead_id;
		--==============generate job number=======
		get_jobnumber = (select * from auto_b2x_job_number());
		--==============inser the job data in job details table=======
		INSERT INTO public.job_detail_new (job_id, repair_status, second_repair_status, is_active, created_on, 
		"custom_1", "custom_2", "custom_3", "custom_4", "custom_5", "custom_6",
		"custom_7", "custom_8", "custom_9", "custom_10",file_name,b2x_req_id,
		additional_service, collect_deductible, collect_device_packaging, commentary, device_configuration,
		device_value, device_value_currency, employee_number, loan_phone, max_repair_cost, max_repair_cost_currency,
		sale_price, sale_price_currency, special_instructions, tax_id, transport_insr, transport_insr_currency,
		transport_insr_value, logistic_inbound_courier_name, logistic_outbound_courier_name, cid, channel, user_name, user_id)
		VALUES (get_jobhead_id, coalesce(job."repairStatus", '1'), job."repairStatus2", true, now(),
		job."custom_1", job."custom_2", job."custom_3", job."custom_4", job."custom_5", job."custom_6",
		job."custom_7", job."custom_8", job."custom_9", job."custom_10",filename,b2xreqid,
		job."additionalService", job."collectDeductible", job."collectDevicePackaging", job."commentary", job."deviceConfiguration",
		job."deviceValue", job."deviceValueCurrency", job."employeeNumber", job."loanPhone", job."maxRepairCost", job."maxRepairCostCurrency",
		job."salePrice", job."salePriceCurrency", job."specialInstructions", job."taxId", job."transportInsr", job."transportInsrCurrency",
		job."transportInsrValue", job."logisticInBoundCourierName",job."logisticOutBoundCourierName", job."cid", channel, userName, userId)
		--==============get job details id from job details table=======
		returning id into get_jobdetail_id;
		--==============update job number and job details id in job head table=======
		update public.job_head_new set b2x_job_number = get_jobnumber, job_detail_id = get_jobdetail_id where id = get_jobhead_id;

		---------------------insert into customerComplaintCodePrimary table ---------------
		-- Check job customerComplaintCodePrimary - insert & disable old code
		-- if ((select count(1) from json_array_elements_text(job."customerComplaintCodePrimary")) > 0) THEN
-- 			UPDATE job_customer_complaint SET is_active = FALSE WHERE job_id = get_jobhead_id AND flag = 1;
-- 		End If;
		FOR get_primaryCode IN
			select value from json_array_elements_text(job."customerComplaintCodePrimary")
		LOOP
			insert into job_customer_complaint(job_id,primary_code,is_active,created_on,flag,job_detail_id)
			values (get_jobhead_id,get_primaryCode."value",true,now(),1,get_jobdetail_id);
		END LOOP;
		---------------------end of job_customer_complaint table ---------------

		---------------------insert into customerComplaintCodeSecondry table ---------------
		-- Check job job_customer_complaint_secondry - insert & disable old code
		-- if ((select count(1) from json_array_elements_text(job."customerComplaintCodeSecondary")) > 0) THEN
-- 			UPDATE job_customer_complaint SET is_active = FALSE WHERE job_id = get_jobhead_id AND flag = 2;
-- 		End If;
		FOR get_secondaryCode IN
			select value from json_array_elements_text(job."customerComplaintCodeSecondary")
		LOOP
			insert into job_customer_complaint(job_id,primary_code,is_active,created_on,flag,job_detail_id)
			values (get_jobhead_id,get_secondaryCode."value",true,now(),2,get_jobdetail_id);
		END LOOP;
		---------------------end of job_customer_complaint table ---------------

                 ---------------------insert into Job_deductible table ---------------                                                                                                                   
                 -- Check job deductible - insert & disable old data                                                                                                                                     
                 -- IF ((SELECT count(1) FROM json_to_record(job."deductible"::json) AS ("amount" numeric(18,2), "currency" text, "status" text,                                                         
 --                                                      "paymentMode" text, "transactionId" text, "paymentMessage" text)) > 0) THEN                                                                     
 --                      UPDATE job_deductible SET is_active = FALSE WHERE job_id = get_jobhead_id AND is_active = TRUE;                                                                                 
 --              End IF;                                                                                                                                                                                 
                 -- +++++++++++++++++++++++++++ dwductible will get saved from job/deductible api only +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++                         
                 -- FOR get_deductible IN                                                                                                                                                                
 --                      SELECT * FROM json_to_record(job."deductible"::json) AS ("amount" numeric(18,2), "currency" text, "paymentMessage" text,                                                        
 --                                                      "paymentMode" text, "status" text, "transactionId" text)                                                                                        
 --              LOOP                                                                                                                                                                                    
 --                      if((get_deductible."amount"::numeric(18,2)) > 0) then                                                                                                                           
 --                              INSERT INTO job_deductible(job_id,amount,currency,status,payment_mode,transaction_id,payment_message,is_active,created_on)                                              
 --                              VALUES(get_jobhead_id, get_deductible."amount", get_deductible."currency", get_deductible."status",get_deductible."paymentMode",                                        
 --                              get_deductible."transactionId",get_deductible."paymentMessage", true, now());                                                                                           
 --                      end if;                                                                                                                                                                         
 --              END LOOP;                                                                                                                                                                               
                 ---------------------end of job_customer_complaint table ---------------      
		
		
		insert into tmp_jobinserteddata ("job_number","claim_Id", "claim_line_id","project", "repair_status", "error_List","insertedInto_Db")
		values (get_jobnumber,job."claimId", job."claimLineId", job."project", coalesce(job."repairStatus"::integer,1), job."errorList",true);
		
	END LOOP;

	return query (select t."claim_Id", t."claim_line_id", t."error_List", t."insertedInto_Db", t."job_number", t."project", t."repair_status" from tmp_jobinserteddata t);
End
$function$
