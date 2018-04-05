CREATE OR REPLACE FUNCTION public.get_orders(ordernumber text, materialnumber text, oemname text)
 RETURNS TABLE("orderNumber" text, "siteName" text, customer text, oem text, "salesOrderLine" integer, line integer, "deliveryNumber" text, "billingDocument" text, "shippingDocument" text, "materialNumber" text, "materialDescription" text, "customerRequestedDeliveryDate" date, "confirmedGoodsIssueDate" date, "requestedQuantity" integer, "confirmedQuantity" integer, "openOrdersQuantity" integer, "shippedQuantity" integer, "actualShipmentDate" date, "soldTo" text, "soldToName" text, "soldToCountry" text, "shipTo" text, "shipToName" text, "shipToCountry" text, "documentCurrency" text, "salesOrderLineNetValue" numeric, "customerReferencePO" text, "processStatusCode" text, "processStatus" text, "productTypeText" text, "orderAdministrator" text, "logisticsPartner" text, "AWB" text, "createdBy" text, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (orderNumber = 'null' AND materialNumber = 'null') THEN
	
		RETURN QUERY SELECT oh.order_number,oh.site_name, oh.customer, oh.oem,
		od.sales_order_line, od.line, od.delivery_number, od.billing_document, od.shipping_document, od.material_number, od.material_description, od.customer_requested_delivery_date, od.confirmed_goods_issue_date, od.requested_quantity,od.confirmed_quantity, od.open_orders_quantity, od.shipped_quantity, od.actual_shipment_date, od.sold_to, od.sold_to_name, od.sold_to_country, od.ship_to, od.ship_to_name,od.ship_to_country, od.document_currency, od.sales_order_line_net_value, od.customer_reference_po, od.process_status_code, od.process_status, od.product_type_text, od.order_administrator,od.logistics_partner, od.awb, od.created_by, od.created_on, od.updated_on
		FROM public.order_head oh
		LEFT JOIN order_detail od ON oh.id = od.order_head_id 
		WHERE od.is_active=true AND oh.is_active = true AND LOWER(oh.oem) = LOWER(oemname) 
		ORDER BY od.id DESC;
	ELSE 
		RETURN QUERY SELECT oh.order_number,oh.site_name, oh.customer, oh.oem,
		od.sales_order_line, od.line, od.delivery_number, od.billing_document, od.shipping_document, od.material_number, od.material_description, od.customer_requested_delivery_date, od.confirmed_goods_issue_date, od.requested_quantity,od.confirmed_quantity, od.open_orders_quantity, od.shipped_quantity, od.actual_shipment_date, od.sold_to, od.sold_to_name, od.sold_to_country, od.ship_to, od.ship_to_name,od.ship_to_country, od.document_currency, od.sales_order_line_net_value, od.customer_reference_po, od.process_status_code, od.process_status, od.product_type_text, od.order_administrator,od.logistics_partner, od.awb, od.created_by, od.created_on, od.updated_on
		FROM public.order_head oh
		LEFT JOIN order_detail od ON oh.id = od.order_head_id		
			WHERE (
				od.is_active=true AND oh.is_active = true AND LOWER(oh.oem) = LOWER(oemname) AND 
				(LOWER(oh.order_number) = LOWER(orderNumber) OR orderNumber = 'null') AND
				(LOWER(od.material_number) = LOWER(materialNumber) OR materialNumber = 'null') 								
			)
			ORDER BY od.id DESC;
	END IF;
	
END;
$function$
