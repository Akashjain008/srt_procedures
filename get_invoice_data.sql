CREATE OR REPLACE FUNCTION public.get_invoice_data(date_of_report timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN (select array_to_json(array_agg(row_to_json(row)))from(

		select (case when jh.insurance_Product_Name is null then 'LEN-OOW' else (concat('LEN-',jh.insurance_Product_Name,'-D')) end ) as "SalesOrderPoolId", co.country as "CustAccount",jh.imei_number_in as "CustomerRef",jd.currency as "Currency",
		co.name as "Name", concat(co.address_line1, ' ', co.address_line2) as "Street", co.zip as "Zipcode", co.city as "City", co.country as "Country", co.email as "Email",
		null as "DimO_RSP", mcc.complaint_description as "Item", 'pcs' as "SalesUnit", 1 as "qty", jd.amount as "price", jd.transaction_id as "AXRefNumber",
		null as "ConfigId", null as "inventSiteID", null as "InventLocationId", null as "SourceLine", null as "ShipToParty", null as "PurchOrderFormNum", null as "SalesTaxGroup",
		null as "ItemSalesTaxGroup", null as "SalesOrigin", null as "SalesOrderType", null as "Contract", null as "SalesTaker", to_char(jd.created_on, 'dd.mm.yyyy')  as "RqShipDate"
		from job_head_new jh
		join tr_consumer co on jh.consumer_id::integer = co.id
		join job_deductible jd on jh.id = jd.job_id
		join job_customer_complaint jcc on jcc.job_id = jh.id
		left join mst_customer_complaint mcc on mcc.b2x_code = jcc.primary_code
		where jd.is_active = true and jd.amount > 0 and mcc.complaint_description is not null
		and (jh.created_on::date = date_of_report::date)

        )row
	);
    END;
$function$
