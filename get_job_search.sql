CREATE OR REPLACE FUNCTION public.get_job_search(jobnumber text, imeinumber text, phonenumber text, emailid text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE repairStatus text = null;
repairStatusOrig text := '';
jobid integer;
data1 text;
data2 text;	
data3 text;
data4 text;
data5 text;
data6 text;
data7 text;
data8 text;
data9 text;
data10 text;
data11 text;
data12 text;
data13 text;
b2xQuotation text;
customerComplaintDetails text;
problemFoundDetails text;
totalPaidAmount numeric(18,2);
totalScreeningAmount numeric(18,2);
totalRepairCost numeric(18,2);
additionalRepairCost numeric(18,2);
result text;
nis text:= ' (Not in system)';
got boolean := false;
Begin

	if ((jobnumber is not null and jobnumber != 'null') and got = false) then
		jobid := (select id from job_head_new where lower(b2x_job_number) = lower(jobnumber) limit 1);
		got := true;
		--RAISE NOTICE 'jobid := % 1 %', jobid, got;
	elseif ((imeinumber is not null and imeinumber != 'null') and got = false) then
		jobid := (select id from job_head_new where imei_number_in = imeinumber order by id desc limit 1);
		got := true;
		--RAISE NOTICE 'jobid := % 2 %', jobid, got;
	elseif ((phonenumber is not null and phonenumber != 'null') and got = false) then
		jobid := (
			select jh.id from job_head_new jh
			join tr_consumer c on jh.consumer_id = c.id
			where c.mobile = phonenumber order by c.id desc limit 1
		);
		got := true;
		--RAISE NOTICE 'jobid := % 3 %', jobid, got;
	elseif ((emailid is not null and emailid != 'null') and got = false) then
		jobid := (
			select jh.id from job_head_new jh
			join tr_consumer c on jh.consumer_id = c.id
			where lower(c.email) = lower(emailid) order by c.id desc limit 1
		);
		got := true;
		--RAISE NOTICE 'jobid := % 4 %', jobid, got;
	elseif (got = false) then
		jobid := 0;
		--RAISE NOTICE 'jobid := % 5 %', jobid, got;
	End if;
	if (jobid > 0) then

		data1:= (SELECT array_to_json(array_agg(row)) FROM (
	
			SELECT "jh"."b2x_job_number" as "jobNumber",
			--coalesce("jh"."job_detail_id",null) as "jobDetailId",
			coalesce(to_char("jh"."accident_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "accidentDate",
			coalesce("jh"."accident_description",null) as "accidentDescription",
			coalesce("jh"."damaged_board_serial_number",null) AS "damagedBoardSerialNumber",
			coalesce("jh"."replacement_board_serial_number",null) AS "replacementBoardSerialNumber",
			coalesce("jh"."certificate_number",null) as "certificateNumber",
			coalesce("jh"."claim_id",null) AS "claimId",
			coalesce("jh"."claiming_status",null) as "claimingStatus",
			
			coalesce("jh"."claim_type",null) AS "claimType",
			coalesce("ct"."claim_description",null) as "claimTypeDescription",
			coalesce("ct"."cust_claim_code",null) as "customerClaimType",
			coalesce("ct"."cust_claim_name",null) as "customerClaimTypeDescription",
			
			coalesce("jh"."complaint_date",null) AS "complaintDate",
			coalesce(to_char("jh"."customer_visit_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "customerVisitDate",

			coalesce("cus"."customer_id",null)as "customerId", 
			coalesce("cus"."name",null)as "customerName", 
			coalesce("cus"."mobile",null)as "customerMobile", 
			coalesce("cus"."home_phone",null)as "customerHomePhone", 
			coalesce("cus"."email",null)as "customerEmail",
			coalesce("cus"."comments", null) as "comments",
			
			-- consumer address
			coalesce("cus"."address_line1",null)as "customerAddressLine1",
			coalesce("cus"."address_line2",null)as "customerAddressLine2",
			coalesce("cus"."street_number", null) as "streetNumber",
			coalesce("cus"."street", null) as "street",
			coalesce("cus"."district", null) as "district",
			coalesce("cus"."city",null)as "customerCity", 
			coalesce("cus"."state",null)as "customerState", 
			coalesce("cus"."zip",null)as "customerZip",
			coalesce(upper("cus"."language_code"),'EN')as "customerLanguage",
			coalesce("cm"."name",null)as "customerCountry", 
			coalesce("cm"."iso_code",null)as "customerCountryCode",
			
			--billing address details
			coalesce("cus"."billing_address_line1",null)as "billingCustomerAddressLine1",
			coalesce("cus"."billing_address_line2",null)as "billingCustomerAddressLine2",
			coalesce("cus"."billing_street_number", null) as "billingStreetNumber",
			coalesce("cus"."billing_street", null) as "billingStreet",
			coalesce("cus"."billing_district", null) as "billingDistrict",
			coalesce("cus"."billing_city",null)as "billingCustomerCity", 
			coalesce("cus"."billing_state",null)as "billingCustomerState", 
			coalesce("cus"."billing_zip",null)as "billingCustomerZip",
			coalesce("cm1"."name",null)as "billingCustomerCountry", 
			coalesce("cm1"."iso_code",null)as "billingCustomerCountryCode",

			coalesce("jh"."imei_number_in",null) as "damagedImei",
			coalesce("jh"."imei_2_in",null) as "damagedImei2",
			coalesce("jh"."product_code_in",null) as "damagedModel",
			coalesce("m"."model_description",null) as "damagedModelDescription", -- model description
			coalesce("jh"."serial_number_in",null) as "damagedSerialNumber",
			coalesce("jh"."sku_in",null) as "damagedSku",
			coalesce("jh"."type_in",null) as "damagedType",
			coalesce("jh"."device_invoice_number",null) as "deviceInvoiceNumber",
			coalesce("jh"."type_out",null) as "replacementType",
			coalesce(to_char("jh"."device_date_of_purchase"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "deviceDateOfPurchase",
			coalesce("jh"."device_ber",null) as "deviceBer",
			case when "jh"."device_irrepairable" = '1' then True else False end "deviceIrrepairable", 
			coalesce("jh"."doc_imei_ok",null) as "docImeiOk",
			
			coalesce("jh"."insurance_coverage",null) as "insuranceCoverage",
			coalesce(to_char("jh"."insurance_start_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "insuranceStartDate",
			coalesce(to_char("jh"."insurance_end_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "insuranceEndDate",
			coalesce("jh"."insurance_broker",null) as "insuranceBroker",
			
			coalesce("jh"."insurance_product_name",null) as "insuranceProductName",
			coalesce("jh"."insurance_policy_number",null) as "insurancePolicyNumber",
			
			coalesce(to_char("jh"."job_creation_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "jobCreationDate",
			coalesce(to_char("jh"."device_manufacture_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "deviceManufactureDate",
			coalesce("jh"."oem_in",null) as "oem",
			coalesce("jh"."oem_out",null) as "replacementOem",
			coalesce("jh"."pop_supplier",null) as "popSupplier",
			coalesce("jh"."product_type",null) as "productType",
			coalesce("jh"."project",null) as "project",
			coalesce("jh"."provider_or_carrier",null) as "providerOrCarrier",
			coalesce("jh"."partner_id",null) as "partnerId",
			coalesce("rsp"."rsp_name",null) as "partnerName",
			coalesce(to_char("jh"."report_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "reportDate",
			
			coalesce("jh"."transaction_code",null) as "transactionCode",
			coalesce("tc"."b2x_transaction_description",null) as "transactionDescription",
			coalesce("tc"."cust_transaction_code",null) as "customerTransactionCode",
			coalesce("tc"."cust_transaction_description",null) as "customerTransactionDescription",
			
			coalesce("jh"."repair_status",null) as "repairStatusId",
			coalesce("rs"."status_name",null) as "repairStatus",
			coalesce("jh"."second_repair_status",null) as "repairStatus2Id",
			coalesce("srs"."status_name",null) as "repairStatus2",
			coalesce("rs"."customer_code",null) as "customerRepairStatusId",
			coalesce("rs"."customer_repair_status",null) as "customerRepairStatus",
			
			coalesce("jh"."logistic_inbound_awb",null) as "logisticInBoundAwb",
			coalesce("jh"."logistic_outbound_awb",null) AS "logisticOutBoundAwb",
			coalesce("trd"."logistic_inbound_courier_name",null) as "logisticInBoundCourierName", 
			coalesce("trd"."logistic_outbound_courier_name",null) as "logisticOutBoundCourierName",
			(select status from job_tracking_details where job_id = jh.id and status in ('In transit') 
			and input_name in ('inBound') and latest_update = true and is_active = true limit 1) as "inBoundTrackingStatus",
			(select status from job_tracking_details where  status in ('In transit','Delivered/Complete') 
			and input_name in ('outBound') and latest_update = true and is_active = true limit 1) as "outBoundTrackingStatus",

			coalesce(to_char("jh"."rsp_date_in"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "rspDateIn",
			coalesce(to_char("jh"."rsp_date_out"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "rspDateOut",

			coalesce("jh"."document_type",null) as "documentType",
			coalesce("jh"."consumer_id",null) as "consumerId",
			coalesce("jh"."escalated_repair_type",null) as "escalatedRepairType",
			coalesce("jh"."escalated_rsp",null) as "escalatedRsp",
			coalesce("jh"."imei_number_out",null) as "replacementImei",
			coalesce("jh"."imei_2_out",null) as "replacementImei2",
			coalesce("jh"."item_code_out",null) as "itemCodeOut",
			coalesce(to_char("jh"."pickup_arranged_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "pickupArrangedDate",
			coalesce(to_char("jh"."pickup_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "pickupDate",
			coalesce("jh"."pop_date",null) as "popDate",
			coalesce("jh"."product_code_out",null) as "replacementModel",
			coalesce("m1"."model_description",null) as "replacementModelDescription",
			coalesce("jh"."sku_out",null) as "replacementSku",
			coalesce("jh"."product_version_in",null) as "productVersionIn",
			coalesce("jh"."product_version_out",null) as "productVersionOut",
			coalesce(to_char("jh"."qa_timepstamp"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "qaTimestamp",
			coalesce(to_char("jh"."quotation_start_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "quotationStartDate",
			coalesce(to_char("jh"."quotation_end_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "quotationEndDate",
			coalesce("jh"."quotation_status_code",null) as "quotationStatusCode",
			coalesce("trd"."quotation_currency",null) as "quotationCurrency",
			coalesce("trd"."quotation_amount",0) as "quotationAmount",

			coalesce(to_char("jh"."repair_timestamp"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "repairTimestamp",
			coalesce(to_char("jh"."return_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "returnDate",
			coalesce("jh"."rma_number",null) as "rmaNumber",
			coalesce("jh"."serial_number_out",null) as "replacementSerialNumber",
			coalesce("jh"."shipped_from",null) as "shippedFrom",
			coalesce("jh"."shipped_to",null) as "shippedTo",
			coalesce("jh"."shop_id",null) as "shopId",
			coalesce(to_char("jh"."shop_in_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "shopInDate",
			coalesce(to_char("jh"."shop_out_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "shopOutDate",
			coalesce("jh"."software_in",null) as "softwareIn",
			coalesce("jh"."software_out",null) as "softwareOut",
			coalesce("jh"."solution_awaited_code",null) as "solutionAwaitedCode",
			coalesce("jh"."special_project_number",null) as "specialProjectNumber",
			coalesce("jh"."support_partner_ticket_id",null) as "supportPartnerTicketId",
			coalesce("jh"."warranty_number",null) as "warrantyNumber",
			coalesce("jh"."send_pre_alert_flag",null) as "sendPreAlertFlag",
			coalesce("jh"."deductible_receipt",null) as "deductibleReceipt",
			coalesce("jh"."doc_invoice_date",null) as "docInvoiceDate",
			coalesce("jh"."doc_received",null) as "docReceived",
			coalesce(to_char("jh"."created_on"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "jobCreatedOn",
			coalesce("jh"."claim_checked",null) as "claimChecked", 
			coalesce(to_char("jh"."completion_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "completionDate",
			coalesce("jh"."order_delivery_date",null) as "orderDeliveryDate",
			coalesce("jh"."partner_job_number",null) as "partnerJobNumber", 
			coalesce("jh"."accident_id",null) as "accidentId", 
			coalesce(to_char("jh"."claim_creation_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "claimCreationDate",
			
			coalesce("cus"."passport_country",null)as "customerPassportCountry",
			coalesce("cus"."passport_number",null)as "customerPassportNumber", 
			coalesce(to_char("trd"."repair_status_update"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "repairStatusUpdate",
			coalesce(to_char("trd"."repair_status_2_update"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "repairStatus2Update",
			coalesce("trd"."remarks",null) as "remarks", 
			coalesce(to_char("trd"."created_on"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "createdOn",
			coalesce("jh"."warranty",null) AS "warranty", 
			case when "jh"."accident_valid" = '1' then True else 'False' end "accidentValid",
			case when "jh"."doc_serial_number_ok" = '1' then True else False end "deviceSerialNumberCorrect", 
			case when "jh"."doc_invoice_number_ok" = '1' then True else False end "docInvoiceNumberOK",
			case when "jh"."doc_invoice_price" = '1' then True else False end "docInvoicePrice", 
			case when "jh"."doc_invoice_date_ok" = '1' then True else False end "docInvoiceDateOK",
			case when "jh"."doc_signed" = '1' then True else False end "docSigned", 
			case when "jh"."deductible_required" = '1' then True else False end "deductibleRequired",
			coalesce("trd"."repair_description",null) as "repairDescription", 
			coalesce("jh"."problem_description",null) AS "problemDescription",
			coalesce("mrp"."name",null) AS "repairProgram",
			coalesce("jh"."device_repair_cost",'0') AS "deviceRepairCost",
			coalesce("jh"."logistic_inbound_shipment_type",null) AS "logisticInBoundShipmentType",
			coalesce("jh"."logistic_outbound_shipment_type",null) AS "logisticOutBoundShipmentType",
			coalesce("trd"."additional_service",null) AS "additionalService",
			coalesce("trd"."collect_deductible",null) AS "collectDeductible",
			coalesce("trd"."collect_device_packaging",null) AS "collectDevicePackaging",
			coalesce("trd"."commentary",null) AS "commentary",
			coalesce("trd"."device_configuration",null) AS "deviceConfiguration",
			coalesce("trd"."device_value",null) AS "deviceValue",
			coalesce("trd"."device_value_currency",null) AS "deviceValueCurrency",
			coalesce("trd"."employee_number",null) AS "employeeNumber",
			coalesce("trd"."loan_phone",null) AS "loanPhone",
			coalesce("trd"."max_repair_cost",null) AS "maxRepairCost",
			coalesce("trd"."max_repair_cost_currency",null) AS "maxRepairCostCurrency",
			coalesce("trd"."sale_price",null) AS "salePrice",
			coalesce("trd"."sale_price_currency",null) AS "salePriceCurrency",
			coalesce("trd"."special_instructions",null) AS "specialInstructions",
			coalesce("trd"."tax_id",null) AS "taxId",
			coalesce("trd"."transport_insr",null) AS "transportInsr",
			coalesce("trd"."transport_insr_currency",null) AS "transportInsrCurrency",
			coalesce("trd"."transport_insr_value",null) AS "transportInsrValue",
			coalesce("trd"."cid",null) AS "cid",
			coalesce("trd"."custom_1",null) as custom_1,
			coalesce("trd"."custom_2",null) as custom_2,
			coalesce("trd"."custom_3",null) as custom_3,
			coalesce("trd"."custom_4",null) as custom_4 ,
			coalesce("trd"."custom_5",null) as custom_5,
			coalesce("trd"."custom_6",null) as custom_6,
			coalesce("trd"."custom_7",null) as custom_7,
			coalesce("trd"."custom_8",null) as custom_8,
			coalesce("trd"."custom_9",null) as custom_9,
			coalesce("trd"."custom_10",null) as custom_10,
			coalesce(trd.file_name, null) as file_name,
			coalesce(jh.expected_tat, null) as "expectedTat",
			coalesce(jh.logistic_inbound_courier_type, null) as "logisticInBoundCourierType",
			coalesce(jh.logistic_outbound_courier_type, null) as "logisticOutBoundCourierType"
			From "job_head_new" jh
			Left Join "job_detail_new" trd ON trd.id=jh.job_detail_id
			-- Left Join "job_customer_complaint" jcc ON jcc.job_id=jh.id
			left JOIN "tr_consumer" cus ON cus.id = CAST(jh.consumer_id AS INTEGER)
			left JOIN "mst_country" cm ON cm.iso_code = cus.country
			left JOIN "mst_country" cm1 ON cm1.iso_code = cus.billing_country
			left join "mst_repair_program" mrp on jh.insurance_coverage = mrp.code
			left join "mst_repair_status" rs on CAST(jh.repair_status AS INTEGER) = CAST(rs."b2x_code" AS INTEGER)
			left join "mst_second_status" srs on CAST(jh.second_repair_status AS INTEGER) = CAST(srs."b2x_code" AS INTEGER)
			left join "mst_transaction_code" tc on CAST(jh.transaction_code AS INTEGER) = CAST(tc."b2x_transaction_code" AS INTEGER)
			left join "mst_claim_type" ct on lower(jh.claim_type) = lower(ct.claim_code)
			left JOIN "mst_rsp" rsp ON rsp.rsp_id = jh.partner_id
			left JOIN "mst_model" m ON m.model_code = jh.product_code_in
			left JOIN "mst_model" m1 ON m1.model_code = jh.product_code_out
			--left join "mst_oem" oe on "jh"."oem_id"="oe"."id"
			WHERE  jh.id = jobid and jh.is_active= true and trd.is_active= true 

		)row);

	--================get problem_found primary details============
	data2:= (SELECT array_to_json(array_agg(row)) FROM (

			SELECT distinct coalesce(pf.primary_code, pf.primary_code || (nis)) as "problemFoundCode"
			FROM job_head_new jh 
			inner join job_problem_found pf on pf.job_id = jh.id and pf.is_active = true and pf.flag = 1
			WHERE jh.id = jobid and jh.is_active = true
		 
		)row) ;

	--================get problem_found secondary details============
	data5:= (SELECT array_to_json(array_agg(row)) FROM (

			select distinct coalesce(pf.primary_code, pf.primary_code || (nis)) as "problemFoundCode"
			FROM job_head_new jh 
			inner join job_problem_found pf on pf.job_id = jh.id and pf.is_active = true and pf.flag = 2
			WHERE jh.id = jobid and jh.is_active = true
		 
		)row) ;

	--================get tr_job_part_consumed details============
	data3:= (SELECT array_to_json(array_agg(row)) FROM (

			SELECT 
			--coalesce(pc.action_code,null) as "actionCode",
			coalesce("pc"."action_reason_code", null) as "actionReason",	
			coalesce("pc"."action_remarks", null) as "actionRemarks",
			coalesce("pc"."delivery_number", null) as "deliveryNumber",
			coalesce(to_char("pc"."delivery_date"::timestamptz, 'yyyy-MM-dd"T"HH:MI:ss.MSZ'),null) as "deliveryDate",
			coalesce("pc"."reference_designator_number", null) as "designatorNumber",
			coalesce("pc"."fault_code", null) as "faultCode",
			coalesce("pc"."field_bulletin_number", null) as "fieldBulletinId",
			coalesce("pc"."mandatory", null) as "mandatory",
			-- coalesce("mp"."damaged_material_number", "pc"."part_code" || (nis)) as "materialNumber",
			coalesce("pc"."material_number", null) as "materialNumber",
			coalesce("pc"."material_serial_number", null) as "materialSerialNumber",
			coalesce("pc"."damaged_material_number", null) as "damagedMaterialNumber",
			coalesce("pc"."damaged_material_serial_number", null) as "damagedMaterialSerialNumber",
			coalesce("pc"."quantity_replaced", 0) as "quantityReplaced",
			coalesce("pc"."quantity_exchanged", 0) as "quantityExchanged",
			coalesce("pc"."root_cause", null) as "rootCause",
			coalesce("pc"."payer", null) as "payer",
			coalesce("pc"."technician_id", null) as "technicianId"
			FROM job_head_new jh
			LEFT JOIN job_part_conusmed_new pc on pc.job_id =jh.id and pc.is_active = true
			LEFT JOIN mst_part mp ON mp.id=pc.id
			WHERE jh.id = jobid and jh.is_active = true
			
		)row);
		
	--================get tr_job_part_awaiting details============
	data4:= (SELECT array_to_json(array_agg(row)) FROM (
	
			SELECT
			material_number as "materialNumber",
			coalesce(jpa.quantity_missing, 0) as "quantityAwaiting"
			FROM job_head_new jh
			join job_part_awainting jpa on jpa.job_id =jh.id and jpa.is_active = true
			WHERE jh.id = jobid and jh.is_active = true
			
		)row) ;

	--================get job deductible details============
	data6:= (SELECT array_to_json(array_agg(row)) FROM (

			SELECT coalesce("jd"."amount",null) AS "amount",
			coalesce("jd"."currency",null) AS "currency",
			coalesce("jd"."payment_message",null) AS "paymentMessage",
			coalesce("jd"."payment_mode",null) AS "paymentMode",
			coalesce("jd"."status",null) AS "status",
			coalesce("jd"."transaction_id",null) AS "transactionId"
			FROM job_head_new jh 
			join job_deductible jd on jd.job_id=jh.id --and jd.is_active = true
			WHERE jh.id = jobid and jd.is_active=true and jh.is_active = true
		)row);

	--================get customer Complaint Code Primary details============
	data7:= (SELECT array_to_json(array_agg(row)) FROM (

			SELECT coalesce(jcc.primary_code, jcc.primary_code || (nis)) as "customerComplaintCode"
			FROM job_head_new jh 
			inner join job_customer_complaint jcc on jcc.job_id = jh.id and jcc.is_active = true and jcc.flag = 1
			WHERE jh.id = jobid and jh.is_active = true
		 
		)row) ;

	--================get MDS customer Complaint Code Primary details============
	data12:= (SELECT array_to_json(array_agg(row)) FROM (

			select distinct coalesce(ccc.customer_code, ccc.customer_code || (nis)) as "mdsCustomerComplaintCode"
			FROM job_head_new jh 
			inner join job_customer_complaint jcc on jcc.job_id = jh.id and jcc.is_active = true and jcc.flag = 1
			left join mst_customer_complaint ccc on jcc.primary_code = ccc.b2x_code
			WHERE jh.id = jobid and jh.is_active = true
		 
		)row) ;

	--================get customer Complaint Code Secondary details============
	data8:= (SELECT array_to_json(array_agg(row)) FROM (

			select distinct coalesce(jcc.primary_code, jcc.primary_code || (nis)) as "customerComplaintCode"
			FROM job_head_new jh 
			inner join job_customer_complaint jcc on jcc.job_id = jh.id and jcc.is_active = true and jcc.flag = 2
			WHERE jh.id = jobid and jh.is_active = true
			
		)row) ;

	--================get action Code details============
	data9:= (SELECT array_to_json(array_agg(row)) FROM (
			select distinct coalesce(jcc.action_code, jcc.action_code || (nis)) as "actionCode"
			FROM job_head_new jh
			inner join job_action_code jcc on jcc.job_id = jh.id and jcc.is_active = true 
			WHERE jh.id = jobid and jh.is_active = true
		)row) ;

	--================get customer action Code details============
	data13:= (SELECT array_to_json(array_agg(row)) FROM (
			select distinct coalesce(ac.customer_action_code, ac.customer_action_code || (nis)) as "customerActionCode"
			FROM job_head_new jh
			inner join job_action_code jcc on jcc.job_id = jh.id and jcc.is_active = true 
			left join mst_action_code ac on jcc.action_code = ac.b2x_action_code
			WHERE jh.id = jobid and jh.is_active = true
		)row) ;

	--================get customer problem_found primary details============
	data10:= (SELECT array_to_json(array_agg(row)) FROM (

			select distinct coalesce(mpf.customer_code, mpf.customer_code || ('Not in system')) as "customerProblemFoundCode"
			FROM job_head_new jh 
			inner join job_problem_found pf on pf.job_id = jh.id and pf.is_active = true and pf.flag = 1 
			inner join mst_problem_found mpf on mpf.b2x_code = pf.primary_code and mpf.is_active = true
			WHERE jh.id = jobid and jh.is_active = true
		 
		)row) ;

	--================get customer problem_found secondary details============
	data11:= (SELECT array_to_json(array_agg(row)) FROM (

			select distinct coalesce(mpf.customer_code, mpf.customer_code || ('Not in system')) as "customerProblemFoundCode"
			FROM job_head_new jh 
			inner join job_problem_found pf on pf.job_id = jh.id and pf.is_active = true and pf.flag = 2
			inner join mst_problem_found mpf on mpf.b2x_code = pf.primary_code and mpf.is_active = true
			WHERE jh.id = jobid and jh.is_active = true
		 
		)row) ;
	-- get job id
	--jobId := (select id from job_head_new where b2x_job_number = jobNumber);

	-- get customer complaint details
	customerComplaintDetails := (SELECT array_to_json(array_agg(row)) FROM (
		select distinct jpf.primary_code as "code", 
		mcc.complaint_description as "description",
		coalesce(mapc.b2x_cost, 0) as "amount",
		coalesce(mapc.b2x_tax, 0) as "tax",
		mapc.currency
		from job_head_new jh
		join mst_rsp rsp on jh.partner_id = rsp.rsp_id
		join tr_consumer tc on jh.consumer_id::integer = tc.id
		join job_customer_complaint jpf on jh.id = jpf.job_id
		left join mst_customer_complaint mcc on mcc.b2x_code = jpf.primary_code
		left join map_rsp_country_problem_cost mapc on 
		(mapc.category = coalesce(mcc.group_symptom, 'Others')) and 
		mapc.model_code = jh.product_code_in and 
		mapc.country_iso_code = tc.country
		--left join map_rsp_country_problem_cost mapc on jpf.primary_code = mapc.problem_found_code and mapc.country_iso_code = rsp.rsp_iso_code
		where jh.id = jobId and jpf.is_active = true and jpf.flag = 1
	)row);

	-- get problem found details
	problemFoundDetails := (SELECT array_to_json(array_agg(row)) FROM (
		select distinct jq.problem_found_code as "code",
		mpf.problem_description as "description",
		jq.amount, 
		jq.tax 
		from job_quotation jq left join  mst_problem_found mpf on mpf.b2x_code = jq.problem_found_code
		where jq.job_id = jobId AND jq.is_active = true
	)row);

	-- get total paid amount
	totalPaidAmount := (select coalesce(SUM(amount),0) from job_deductible where job_id = jobId and is_active = true);

	-- get total repair cost
	totalRepairCost := ( select coalesce(sum(amount + tax),0) from job_quotation where job_id = jobId AND is_active = true);

	-- get screening cost
	totalScreeningAmount := (select coalesce(sum(a.b2x_cost + a.b2x_tax),0) 
		from map_rsp_country_problem_cost a 
		inner join job_head_new b on a.model_code = b.product_code_in
		inner join mst_rsp c on b.partner_id = c.rsp_id
		where 
		lower(a.category) = 'screening' AND a.is_active = true and b.is_active = true
		and c.id = a.rsp_id
		and b.id = jobId 
	);

	--RAISE NOTICE 'scrCost:= % paidCost: % repairCost: %', totalScreeningAmount, totalPaidAmount, totalRepairCost;
	
	if( totalRepairCost <= 0) then
		totalScreeningAmount :=0;
	end if;
	-- get additional repair cost
	additionalRepairCost := (totalRepairCost + totalScreeningAmount) - totalPaidAmount;
	
	-- get b2x quotation details
	b2xQuotation := '[{ "customerComplaintDetails" : ' || coalesce(customerComplaintDetails, '[]')||',
		   "problemFoundDetails" : ' || coalesce(problemFoundDetails, '[]')||', "totalPaidAmount" : '|| coalesce(totalPaidAmount, 0) ||',
		   "totalRepairCost" : '|| coalesce(totalRepairCost,0) ||', "additionalRepairCost" : ' || coalesce(additionalRepairCost, 0) || '}]';
		   
	result:= '{"table1":' ||coalesce(data1, '[]')||', "table2":'||coalesce(data2, '[]')||', "table3":'||coalesce(data3, '[]')||', 
		   "table4":' ||coalesce(data4, '[]')||', "table5":'||coalesce(data5, '[]')||', "table6":'||coalesce(data6, '[]')||',
		   "table7":' ||coalesce(data7, '[]')||', "table8":'||coalesce(data8, '[]')||', "table9":'||coalesce(data9, '[]')||',
		   "table10":'||coalesce(data10,'[]')||', "table11":'||coalesce(data11, '[]')||', "table12":'||coalesce(data12, '[]')||',
		   "table13":'||coalesce(data13, '[]')||',"b2xQuotation":'|| coalesce(b2xQuotation, '[]') ||'}';
	
	else

		result:= '{"error" : { "code" : "200", "message": "No job details found in system" } }';
		
	End if;

	RAISE NOTICE 'result=====: %', result;
	return result;
	
end
$function$
