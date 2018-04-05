CREATE OR REPLACE FUNCTION public.update_deductible(jobid text, claimid text, deductiblereceipt boolean, deductible_amount numeric, deductible_currency text, deductible_status text, deductible_paymentmode text, deductible_transactionid text, deductible_paymentmessage text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
jobheadid integer;
BEGIN
	jobheadid:= (select id from job_head_new where b2x_job_number = jobid AND is_active = true);
	
	update job_head_new 
	set deductible_receipt = deductiblereceipt,
	    claim_id = claimid,
	    updated_on =  now()
	where b2x_job_number = jobid;

	UPDATE public.job_deductible
	SET amount=deductible_amount, currency=deductible_currency, status=deductible_status, payment_mode=deductible_paymentMode, 
		transaction_id=deductible_transactionId, payment_message=deductible_paymentMessage, is_active = deductiblereceipt, updated_on=now()
	WHERE job_id=jobheadid;

	return '{"status": "pass", "message": "successfully update"}';

END;
$function$
