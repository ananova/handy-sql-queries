-- Recurly functions and queries

CREATE FUNCTION parse_xml(xml xml, object varchar, attr varchar) RETURNS varchar AS $$
    SELECT CAST((xpath(object || '/' || attr || '/text()', xml))[1] AS varchar)
$$ LANGUAGE SQL;

CREATE FUNCTION get_recurly_subscription_id(xml xml) RETURNS uuid AS $$
	SELECT cast(parse_xml(xml, 'transaction', 'subscription_id') as uuid)
$$ LANGUAGE SQL;

CREATE FUNCTION get_account_code(xml xml) RETURNS uuid AS $$
	SELECT cast(parse_xml(xml, 'account', 'account_code') as uuid)
$$ LANGUAGE SQL;

CREATE FUNCTION get_subscription_amount(xml xml) RETURNS integer AS $$
	SELECT cast(parse_xml(xml, 'transaction', 'amount_in_cents') as integer)
$$ LANGUAGE SQL;

CREATE FUNCTION get_email(xml xml) RETURNS varchar AS $$
	SELECT cast(parse_xml(xml, 'account', 'email') as varchar)
$$ LANGUAGE SQL;

WITH successful_payment_notifications AS (
	SELECT 
	  get_account_code(xml)             AS recurly_account_code
	, get_recurly_subscription_id(xml)  AS recurly_subscription_id
	, get_subscription_amount(xml)      AS amount_in_cents
	, get_email(xml)                    AS email
	FROM (
	  SELECT
	    CAST(data->>'xml' AS xml) as xml
	  FROM events
	  WHERE events.type = 'recurly_successful_payment_notification_received'
	) successful_payments
)

, new_dunning_event_notifications AS (
	SELECT
	  parse_xml(xml, 'account',      'account_code')              AS account_code
	, parse_xml(xml, 'account',      'email')                     AS email
	
	, parse_xml(xml, 'invoice',      'due_at')                    AS due_at
	, parse_xml(xml, 'invoice',      'due_on')                    AS due_on
	, parse_xml(xml, 'invoice',      'dunning_events_count')      AS dunning_events_count
	, parse_xml(xml, 'invoice',      'created_at')                AS created_at
	, parse_xml(xml, 'invoice',      'updated_at')                AS updated_at
	, parse_xml(xml, 'invoice',      'origin')                    AS origin
	, parse_xml(xml, 'invoice',      'address')                   AS address
	, parse_xml(xml, 'invoice',      'balance_in_cents')          AS balance_in_cents
	, parse_xml(xml, 'invoice',      'tax_in_cents')              AS tax_in_cents
	, parse_xml(xml, 'invoice',      'subscription_id')           AS subscription_uuid
	
	, parse_xml(xml, 'subscription', 'uuid')                      AS recurly_subscription_uuid
	, parse_xml(xml, 'subscription', 'state')                     AS state
	, parse_xml(xml, 'subscription', 'plan_code')                 AS plan_code
	, parse_xml(xml, 'subscription', 'activated_at')              AS activated_at
	FROM (
	  SELECT
	    CAST(data->>'xml' AS xml) as xml
	  FROM events
	  WHERE events.type = 'recurly_new_dunning_event_notification_received'
	) dunnings_events
)

