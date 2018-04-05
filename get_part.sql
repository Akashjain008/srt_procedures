CREATE OR REPLACE FUNCTION public.get_part(partcode text, partname text, partdesc text, partgrouping text, oemid integer, partserialized boolean, repairlevel text, isactive boolean)
 RETURNS TABLE("partId" integer, "partCode" text, "partName" text, "partDesc" text, "partGrouping" text, "oemId" integer, "oemName" text, serialized boolean, "repairLevel" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (partcode = 'null' AND partname = 'null' AND partdesc = 'null' AND partgrouping = 'null' AND partserialized is null AND repairlevel = 'null' AND oemid is null AND isActive is null) THEN
	
		RETURN QUERY SELECT p.id, p.part_code, p.part_name, p.part_description, p.part_grouping, p.oem_id, o.oem_name, p.serialized, p.repair_level, 
			p.is_active, p.created_on, p.updated_on
			FROM public.mst_part p
			left join mst_oem o on o.id = p.oem_id
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT p.id, p.part_code, p.part_name, p.part_description, p.part_grouping, p.oem_id, o.oem_name, p.serialized, p.repair_level, 
			p.is_active, p.created_on, p.updated_on
			FROM public.mst_part p
			left join mst_oem o on o.id = p.oem_id
			WHERE (
				(LOWER(p.part_code) = LOWER(partcode) OR partcode = 'null') AND
				(LOWER(p.part_name) = LOWER(partname) OR partname = 'null') AND
				(LOWER(p.part_description) = LOWER(partdesc) OR partdesc = 'null') AND
				(LOWER(p.part_grouping) = LOWER(partgrouping) OR partgrouping = 'null') AND
				(p.oem_id = oemid OR oemid IS NULL) AND
				(p.serialized = partserialized OR partserialized IS NULL) AND
				(LOWER(p.repair_level) = LOWER(repairlevel) OR repairlevel = 'null') AND
				(p.is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
