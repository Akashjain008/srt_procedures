CREATE OR REPLACE FUNCTION public.insert_document(jobid text, documenttype text, docreceived text, docsigned boolean, docserialnumberok boolean, docinvoicenumberok boolean, docimeiok boolean, docinvoicedate text, docinvoicedateok boolean, docinvoiceprice boolean, content text, filename text, "Url" text, "Extension" text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN

	INSERT INTO public.job_documents(b2x_job_number, document_type, doc_received, doc_signed,doc_serial_number_ok,doc_invoice_number_ok,doc_imei_ok,
	doc_invoice_date,doc_invoice_date_ok,doc_invoice_price,file_content,file_name,created_on,url,extension)
	VALUES (jobid, documenttype, coalesce(docreceived, null) ,docsigned,docserialnumberok,docinvoicenumberok,docimeiok,
	docinvoicedate ,docinvoicedateok,docinvoiceprice,content,filename,now(),"Url","Extension");

	return '{"status": "pass", "message": "successfully insert"}';

END;
$function$
