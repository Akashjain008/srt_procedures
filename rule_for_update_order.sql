CREATE OR REPLACE FUNCTION public.rule_for_update_order(ordersarray text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE op_outputjson text := '';
declare recordCheck record;
declare singleorder record;
Declare dbflag boolean;
declare errorList json:= '[]';
declare adderror record;
declare error record;
declare check_rsp_id integer;
Begin

	-- Create temp table to hold json data
	drop table if exists tmp_updateorderjsondata;
	create temp table tmp_updateorderjsondata("id" serial, "orderNumber" text,"siteName" text, "customer" text, "oem" text, "salesOrderLine" integer,"line" integer,"deliveryNumber" text,"billingDocument" text,"shippingDocument" text,"materialNumber" text,"materialDescription" text,"customerRequestedDeliveryDate" date,"confirmedGoodsIssueDate" date,"requestedQuantity" integer,"confirmedQuantity" integer,"openOrdersQuantity" integer,"shippedQuantity" integer,"actualShipmentDate" date,"soldTo" text,"soldToName" text,"soldToCountry" text,"shipTo" text,"shipToName" text,"shipToCountry" text,"documentCurrency" text,"salesOrderLineNetValue" numeric,"customerReferencePO" text,"processStatusCode" text,"processStatus" text,"productTypeText" text,"orderAdministrator" text,"logisticsPartner" text,"AWB" text, "createdBy" text, "errorList" text,
		"insertedIntoDb" boolean,"uniqueId" text);

	drop table if exists tmp_errorlistjson;
	create temp table tmp_errorlistjson("id" serial,"uniqueId" text,"errorCode" text, "errorMessage" text, "errorColumn" text, "errorType" text, "successFlag" boolean );
	
	insert into tmp_updateorderjsondata("orderNumber","siteName", "customer", "oem", "salesOrderLine","line","deliveryNumber","billingDocument","shippingDocument","materialNumber","materialDescription","customerRequestedDeliveryDate","confirmedGoodsIssueDate","requestedQuantity","confirmedQuantity","openOrdersQuantity","shippedQuantity","actualShipmentDate","soldTo","soldToName","soldToCountry","shipTo","shipToName","shipToCountry","documentCurrency","salesOrderLineNetValue","customerReferencePO","processStatusCode","processStatus","productTypeText","orderAdministrator","logisticsPartner","AWB", "createdBy", "errorList" ,"insertedIntoDb","uniqueId")
	select * from json_to_recordset(ordersarray::json) as ("orderNumber" text,"siteName" text, "customer" text, "oem" text, "salesOrderLine" integer,"line" integer,"deliveryNumber" text,"billingDocument" text,"shippingDocument" text,"materialNumber" text,"materialDescription" text,"customerRequestedDeliveryDate" date,"confirmedGoodsIssueDate" date,"requestedQuantity" integer,"confirmedQuantity" integer,"openOrdersQuantity" integer,"shippedQuantity" integer,"actualShipmentDate" date,"soldTo" text,"soldToName" text,"soldToCountry" text,"shipTo" text,"shipToName" text,"shipToCountry" text,"documentCurrency" text,"salesOrderLineNetValue" numeric,"customerReferencePO" text,"processStatusCode" text,"processStatus" text,"productTypeText" text,"orderAdministrator" text,"logisticsPartner" text,"AWB" text, "createdBy" text, "errorList" text,
		"insertedIntoDb" boolean,"uniqueId" text);

	FOR singleorder IN (select * from tmp_updateorderjsondata)
	LOOP

		insert into tmp_errorlistjson("uniqueId","errorCode", "errorMessage", "errorColumn", "errorType", "successFlag")
		SELECT * from json_to_recordset(singleorder."errorList"::json) as ("uniqueId" text,"errorCode" text, "errorMessage" text, "errorColumn" text, "errorType" text, "successFlag" boolean);
		
		FOR recordCheck IN (SELECT * FROM tr_rule where is_active=true and db_level=true and event_type ='updateOrder' order by 1)
		LOOP			
					
			--=======check repair Service Partner Id rule========
			if (recordCheck."code" = 'SRTO20007') then
				if (singleorder."siteName" is not null and singleorder."siteName" != '') then
					--=======check repairServicePartnerId in table================
					check_rsp_id := (select count(1) from mst_rsp where lower(rsp_name) = lower(singleorder."siteName") and is_active = true);
					if (check_rsp_id = 0) then
						insert into tmp_errorlistjson("uniqueId","errorCode", "errorMessage", "errorColumn", "errorType", "successFlag")
						values (singleorder."uniqueId",recordCheck."code",recordCheck."name", recordCheck."column_name", recordCheck."type", false);
					end if;
				End if;
			ENd if;
		END LOOP;
		--=============insert all the error list in the variable and send to the response=============
		errorList:= (select array_to_json(array_agg(row_to_json(row)))
			    from (
				select "errorCode", "errorMessage", "errorColumn", "errorType", "successFlag" 
				from tmp_errorlistjson
			    ) row);
		
		op_outputjson := op_outputjson || ((select row_to_json(row) from (
			select singleorder."orderNumber", singleorder."siteName", singleorder."oem", singleorder."customer", singleorder."salesOrderLine",singleorder."line", singleorder."deliveryNumber", singleorder."billingDocument", singleorder."shippingDocument", singleorder."materialNumber", singleorder."materialDescription", singleorder."customerRequestedDeliveryDate", singleorder."confirmedGoodsIssueDate", singleorder."requestedQuantity", singleorder."confirmedQuantity", singleorder."openOrdersQuantity", 
            singleorder."shippedQuantity", singleorder."actualShipmentDate",singleorder."soldTo", singleorder."soldToName",singleorder."soldToCountry", singleorder."shipTo", singleorder."shipToName", singleorder."shipToCountry", singleorder."documentCurrency", singleorder."salesOrderLineNetValue", singleorder."customerReferencePO", singleorder."processStatusCode", singleorder."processStatus", singleorder."productTypeText", singleorder."orderAdministrator", singleorder."logisticsPartner",singleorder."AWB", singleorder."createdBy",
             errorList as "errorList", singleorder."insertedIntoDb"
				-- select singleorder."orderNumber" ,singleorder."siteName",singleorder."oem" ,singleorder."materialNumber" ,errorList as "errorList", singleorder."insertedIntoDb"
				) row) || ',');
		
	END LOOP;
	--RAISE NOTICE '%', op_outputjson;
	return trim(trailing ',' from op_outputjson);
End
$function$
