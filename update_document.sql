CREATE OR REPLACE FUNCTION public.update_document(jobid text, documenttype text, docreceived text, docsigned boolean, docserialnumberok boolean, docinvoicenumberok boolean, docimeiok boolean, docinvoicedate text, docinvoicedateok boolean, docinvoiceprice boolean, content text, filename text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	update job_documents
	    set  b2x_job_number = jobid , 
		 document_type = documenttype, 
		 doc_received = docreceived,
		 doc_signed = docsigned,
		 doc_serial_number_ok = docserialnumberok,
		 doc_invoice_number_ok = docinvoicenumberok,
		 doc_imei_ok = docimeiok,
		 doc_invoice_date = docinvoicedate,
		 doc_invoice_date_ok = docinvoicedateok,
		 doc_invoice_price = docinvoiceprice,
		 file_content = content,
		 file_name = filename,
		 updated_on = now(),
		 updated_by = '1'
	where b2x_job_number = jobid;
	return '{"status": "pass", "message": "successfully update"}';

END;
$function$
