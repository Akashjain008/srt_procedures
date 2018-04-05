CREATE OR REPLACE FUNCTION public.get_customer_mapping_data(pageindex integer, pagesize integer, customerid integer, countryid integer, languageid integer, repairprogramid integer, isactive boolean)
 RETURNS TABLE(id integer, "customerId" integer, "customerName" text, "customerCode" text, "countryId" integer, "countryName" text, "isoCode" text, "countryCodeName" text, "currencyId" integer, "languageId" integer, "languageCode" text, language text, "languageCodeName" text, "repairProgramId" integer, "repairProgramCode" text, "repairProgramName" text, "repairProgramCodeName" text, "repairProgramDescription" text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY
	SELECT 
	  map.id,
	  map.customer_id,
	  mst_customer.name As "customerName",
	  mst_customer.code As "customerCode",
	  map.country_id,
	  mst_country.name As "countryName",
	  mst_country.iso_code,
	  mst_country.iso_code || ' - ' || mst_country.name as "countryCodeName",
	  map.currency_id,
-- 	  mst_currency.code As currency_code,
-- 	  mst_currency.currency,
	  map.language_id,
	  mst_language.code As "languageCode",
	  mst_language.name As "language",
	  mst_language.code ||' - '|| mst_language.name as "languageCodeName",
	  map.repair_program_id,
	  mst_repair_program.code As "repairProgramCode",
	  mst_repair_program.name As "repairProgramName",
	   mst_repair_program.code ||' - '||  mst_repair_program.name as "repairProgramCodeName",
	  mst_repair_program.description As "repairProgramDescription",
	  map.is_active
	FROM
	  public.map_customer_country_currency_language_repair_program map join
	  public.mst_country on map.country_id = mst_country.id join
-- 	  public."mstCurrency" on map."currencyId" = "mstCurrency".id join
	  public.mst_customer on map.customer_id = mst_customer.id join
	  public.mst_language on map.language_id = mst_language.id join
	  public.mst_repair_program on map.repair_program_id = mst_repair_program.id	  
	WHERE (map.customer_id = customerId or customerId is null) 
	AND (map.country_id = countryId or countryId is null) 
	AND (map.repair_program_id = repairProgramId or repairProgramId is null)
	AND (map.language_id = languageid or languageid is null)
	AND (map.is_active = isactive or isactive is null)
	ORDER BY 1;
	--OFFSET pageIndex LIMIT pageSize;
    END;
$function$
