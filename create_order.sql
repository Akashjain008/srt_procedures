CREATE OR REPLACE FUNCTION public.create_order(arrayorders text)
 RETURNS TABLE("orderNumber" text, "salesOrderLine" text, "materialNumber" text, "errorList" json, "insertedIntoDb" boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE order_data record;
DECLARE get_orderhead_id integer;
DECLARE get_order_id integer;
DECLARE get_order_detail_id integer;

    BEGIN
    -- Create temp table to hold json data ritesh---
	drop table if exists tmp_orderinserteddata;
	create temp table tmp_orderinserteddata("id" serial,"order_number" text, "sales_order_line" text, "material_number" text,"error_List" json, "insertedInto_Db" boolean);
	
	FOR order_data IN 

		select * from json_to_recordset(arrayorders::json) as ("orderNumber" text,"siteName" text, "customer" text, "oem" text, "salesOrderLine" integer,"line" integer,"deliveryNumber" text,"billingDocument" text,"shippingDocument" text,"materialNumber" text,"materialDescription" text,"customerRequestedDeliveryDate" date,"confirmedGoodsIssueDate" date,"requestedQuantity" integer,"confirmedQuantity" integer,"openOrdersQuantity" integer,"shippedQuantity" integer,"actualShipmentDate" date,"soldTo" text,"soldToName" text,"soldToCountry" text,"shipTo" text,"shipToName" text,"shipToCountry" text,"documentCurrency" text,"salesOrderLineNetValue" numeric,"customerReferencePO" text,"processStatusCode" text,"processStatus" text,"productTypeText" text,"orderAdministrator" text,"logisticsPartner" text,"AWB" text, "createdBy" text, "errorList" json)
	
	LOOP

	--===================  check if order number exists in db ====== 

	get_order_id:= (select id from order_head where LOWER(order_number) = LOWER(order_data."orderNumber") AND LOWER(oem) = LOWER(order_data."oem") AND is_active = true);	
	
	--===================  if order doesn't exist in db insert data  ==========

	IF (get_order_id is not null) THEN

		get_orderhead_id = get_order_id;

	ELSE

	--===================  insert into order_head  ==========

		INSERT INTO public.order_head( order_number, site_name, customer, oem, is_active,created_on, created_by )
	    VALUES (order_data."orderNumber",order_data."siteName", order_data."customer", order_data."oem", true, now(), order_data."createdBy")
	    returning id into get_orderhead_id;

	END IF; 

	--===================  check if combination of order number and material exist ====== 
	get_order_detail_id:= (select id from order_detail where order_head_id = get_orderhead_id AND material_number = order_data."materialNumber" AND is_active = true);	

	--===================  if combination exists, then update is_active = false of old row  ==========
	IF (get_order_detail_id is not null) THEN

		update order_detail set is_active = false,updated_on = now(), updated_by = order_data."createdBy" where id = get_order_detail_id;

	END IF; 
		

--=================== Insert into order_detail ============

		INSERT INTO public.order_detail(
	            order_head_id, sales_order_line, line, delivery_number, billing_document, shipping_document, 
	            material_number, material_description, customer_requested_delivery_date, confirmed_goods_issue_date, requested_quantity, confirmed_quantity, open_orders_quantity, shipped_quantity, actual_shipment_date, sold_to, sold_to_name, sold_to_country, ship_to, ship_to_name,
	            ship_to_country, document_currency, sales_order_line_net_value, customer_reference_po, 
	            process_status_code, process_status, product_type_text, order_administrator, logistics_partner, awb, is_active, created_on, created_by
	            )
	    VALUES (get_orderhead_id, order_data."salesOrderLine", order_data."line", order_data."deliveryNumber", order_data."billingDocument", order_data."shippingDocument",order_data."materialNumber", order_data."materialDescription", order_data."customerRequestedDeliveryDate", order_data."confirmedGoodsIssueDate", order_data."requestedQuantity", order_data."confirmedQuantity", order_data."openOrdersQuantity", order_data."shippedQuantity",order_data."actualShipmentDate", order_data."soldTo",order_data."soldToName", order_data."soldToCountry", order_data."shipTo", order_data."shipToName", order_data."shipToCountry", order_data."documentCurrency", order_data."salesOrderLineNetValue", order_data."customerReferencePO",order_data."processStatusCode",order_data."processStatus", order_data."productTypeText", order_data."orderAdministrator", order_data."logisticsPartner",order_data."AWB",true,now(), order_data."createdBy");

--================= Insert into temp table ================
	insert into tmp_orderinserteddata ("order_number","sales_order_line","material_number", "error_List","insertedInto_Db")	values (order_data."orderNumber",order_data."salesOrderLine",order_data."materialNumber" ,order_data."errorList",true);

	END LOOP;

	return query (select "order_number","sales_order_line","material_number", "error_List", "insertedInto_Db" from tmp_orderinserteddata);

    END;
$function$
