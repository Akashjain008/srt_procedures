CREATE OR REPLACE FUNCTION public.update_order(arrayorders text)
 RETURNS TABLE("orderNumber" text, "salesOrderLine" text, "materialNumber" text, "errorList" json, "insertedIntoDb" boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE order_data record;
DECLARE get_orderhead_id integer;
DECLARE get_order_id integer;
DECLARE get_order_detail_id integer;

    BEGIN
    -- Create temp table to hold json data
	drop table if exists tmp_orderinserteddata;
	create temp table tmp_orderinserteddata("id" serial,"order_number" text, "sales_order_line" text, "material_number" text, "error_List" json, "insertedInto_Db" boolean);
	
	FOR order_data IN 

		select * from json_to_recordset(arrayorders::json) as ("orderNumber" text,"siteName" text, "customer" text, "oem" text, "salesOrderLine" integer,"line" integer,"deliveryNumber" text,"billingDocument" text,"shippingDocument" text,"materialNumber" text,"materialDescription" text,"customerRequestedDeliveryDate" date,"confirmedGoodsIssueDate" date,"requestedQuantity" integer,"confirmedQuantity" integer,"openOrdersQuantity" integer,"shippedQuantity" integer,"actualShipmentDate" date,"soldTo" text,"soldToName" text,"soldToCountry" text,"shipTo" text,"shipToName" text,"shipToCountry" text,"documentCurrency" text,"salesOrderLineNetValue" numeric,"customerReferencePO" text,"processStatusCode" text,"processStatus" text,"productTypeText" text,"orderAdministrator" text,"logisticsPartner" text,"AWB" text, "createdBy" text, "errorList" json)
	
	LOOP

	--===================  check if order number exists in db ====== 

	get_order_id:= (select id from order_head where LOWER(order_number) = LOWER(order_data."orderNumber") AND LOWER(oem) = LOWER(order_data."oem") AND is_active = true);	
	
	--===================  if order doesn't exist in db insert data  ==========

	IF (get_order_id is not null) THEN

		get_orderhead_id = get_order_id;

		-- =================== update order_head ==========================
		UPDATE order_head SET site_name = order_data."siteName", customer = order_data."customer" WHERE id = get_orderhead_id;

		--===================  check if combination of order number,oem and material number exist ====== 
		get_order_detail_id:= (select id from order_detail where order_head_id = get_orderhead_id AND material_number = order_data."materialNumber" AND is_active = true);	

		--===================  if combination exists, then update is_active = false of old row  ==========
		IF (get_order_detail_id is not null) THEN

			update order_detail set is_active = false where id = get_order_detail_id;

			INSERT INTO public.order_detail(
					order_head_id, sales_order_line, line, delivery_number, billing_document, shipping_document, 
		            material_number, material_description, customer_requested_delivery_date, confirmed_goods_issue_date, requested_quantity, confirmed_quantity, open_orders_quantity, shipped_quantity, actual_shipment_date, sold_to, sold_to_name, sold_to_country, ship_to, ship_to_name,
		            ship_to_country, document_currency, sales_order_line_net_value, customer_reference_po, 
		            process_status_code, process_status, product_type_text, order_administrator, logistics_partner, awb, is_active, created_on, created_by,updated_on, updated_by
		            )
				(
				select 
					get_orderhead_id,coalesce(order_data."salesOrderLine",de."sales_order_line"), coalesce(order_data."line",de."line"), coalesce(order_data."deliveryNumber",de."delivery_number"), coalesce(order_data."billingDocument",de."billing_document"), coalesce(order_data."shippingDocument",de."shipping_document"),coalesce(order_data."materialNumber",de."material_number"), coalesce(order_data."materialDescription",de."material_description"), coalesce(order_data."customerRequestedDeliveryDate",de."customer_requested_delivery_date"), coalesce(order_data."confirmedGoodsIssueDate",de."confirmed_goods_issue_date"), coalesce(order_data."requestedQuantity",de."requested_quantity"), coalesce(order_data."confirmedQuantity",de."confirmed_quantity"), coalesce(order_data."openOrdersQuantity",de."open_orders_quantity"), coalesce(order_data."shippedQuantity",de."shipped_quantity"), coalesce(order_data."actualShipmentDate",de."actual_shipment_date"), coalesce(order_data."soldTo",de."sold_to"), coalesce(order_data."soldToName",de."sold_to_name"), coalesce(order_data."soldToCountry",de."sold_to_country"), coalesce(order_data."shipTo",de."ship_to"), coalesce(order_data."shipToName",de."ship_to_name"), coalesce(order_data."shipToCountry",de."ship_to_country"), coalesce(order_data."documentCurrency",de."document_currency"), coalesce(order_data."salesOrderLineNetValue",de."sales_order_line_net_value"), coalesce(order_data."customerReferencePO",de."customer_reference_po"), coalesce(order_data."processStatusCode",de."process_status_code"),coalesce(order_data."processStatus",de."process_status"), coalesce(order_data."productTypeText",de."product_type_text"), coalesce(order_data."orderAdministrator",de."order_administrator"), coalesce(order_data."logisticsPartner",de."logistics_partner"),coalesce(order_data."AWB",de."awb"),true,now(), order_data."createdBy", now(),order_data."createdBy"
					from order_detail de where id = get_order_detail_id
				);

		    ELSE
		    	--=================== Insert into order_detail ============

		    	INSERT INTO public.order_detail(
		            order_head_id, sales_order_line, line, delivery_number, billing_document, shipping_document, 
		            material_number, material_description, customer_requested_delivery_date, confirmed_goods_issue_date, requested_quantity, confirmed_quantity, open_orders_quantity, shipped_quantity, actual_shipment_date, sold_to, sold_to_name, sold_to_country, ship_to, ship_to_name,
		            ship_to_country, document_currency, sales_order_line_net_value, customer_reference_po, 
		            process_status_code, process_status, product_type_text, order_administrator, logistics_partner, awb, is_active, created_on, created_by
		            )
		    VALUES (get_orderhead_id, order_data."salesOrderLine", order_data."line", order_data."deliveryNumber", order_data."billingDocument", order_data."shippingDocument",order_data."materialNumber", order_data."materialDescription", order_data."customerRequestedDeliveryDate", order_data."confirmedGoodsIssueDate", order_data."requestedQuantity", order_data."confirmedQuantity", order_data."openOrdersQuantity", order_data."shippedQuantity",order_data."actualShipmentDate", order_data."soldTo",order_data."soldToName", order_data."soldToCountry", order_data."shipTo", order_data."shipToName", order_data."shipToCountry", order_data."documentCurrency", order_data."salesOrderLineNetValue", order_data."customerReferencePO",order_data."processStatusCode",order_data."processStatus", order_data."productTypeText", order_data."orderAdministrator", order_data."logisticsPartner",order_data."AWB",true,now(), order_data."createdBy");

		END IF; 
		
			

	--================= Insert into temp table ================
		insert into tmp_orderinserteddata ("order_number","sales_order_line","material_number","error_List","insertedInto_Db")	values (order_data."orderNumber",order_data."salesOrderLine", order_data."materialNumber", order_data."errorList",true);


	ELSE

	--===================  return error ==========

		insert into tmp_orderinserteddata ("order_number","sales_order_line","material_number","error_List","insertedInto_Db")	values (order_data."orderNumber",order_data."salesOrderLine",order_data."materialNumber" ,'[{ "successFlag": "fail", "errorMessage": "Order number does not exist.", "errorCode": "SRTO20001","errorColumn":"orderNumber" }]',false);


	END IF; 

	
	END LOOP;

	return query (select "order_number","sales_order_line","material_number" ,"error_List", "insertedInto_Db" from tmp_orderinserteddata);

    END;
$function$
