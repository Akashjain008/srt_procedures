CREATE OR REPLACE FUNCTION public.insert_deductible(jobid text, claimid text, deductiblereceipt boolean, deductible_amount numeric, deductible_currency text, deductible_status text, deductible_paymentmode text, deductible_transactionid text, deductible_paymentmessage text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
jobheadid integer;
BEGIN
	jobheadid:= (select id from job_head_new where b2x_job_number = jobid AND is_active = true);

	update job_head_new 
	set deductible_receipt = deductiblereceipt,
	    updated_on =  now()
	where b2x_job_number = jobid;

	INSERT INTO public.job_deductible(job_id, amount, currency, status, payment_mode, 
		transaction_id, payment_message, is_active, created_on)
	VALUES (jobheadid, deductible_amount, deductible_currency, deductible_status, deductible_paymentmode, 
	deductible_transactionid, deductible_paymentmessage, true, now());


	return '{"status": "pass", "message": "successfully insert"}';

END;
$function$
