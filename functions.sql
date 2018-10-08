-- Recurly functions and queries

CREATE FUNCTION parse_xml(xml xml, object varchar, attr varchar) RETURNS varchar AS $$
    SELECT CAST((xpath(object || '/' || attr || '/text()', xml))[1] AS varchar)
$$ LANGUAGE SQL;

CREATE FUNCTION parse_recurly_xml(data json, object varchar, attr varchar) RETURNS varchar AS $$
	SELECT CAST((xpath(object || '/' || attr || '/text()', (CAST(data->>'xml' AS xml))))[1] AS varchar)
$$ LANGUAGE SQL;

CREATE FUNCTION get_recurly_subscription_id(data json) RETURNS uuid AS $$
	SELECT cast(parse_recurly_xml(data, 'transaction', 'subscription_id') as uuid)
$$ LANGUAGE SQL;

CREATE FUNCTION get_account_code(data json) RETURNS uuid AS $$
	SELECT cast(parse_recurly_xml(data, 'account', 'account_code') as uuid)
$$ LANGUAGE SQL;

CREATE FUNCTION get_subscription_amount(data json) RETURNS integer AS $$
	SELECT cast(parse_recurly_xml(data, 'transaction', 'amount_in_cents') as integer)
$$ LANGUAGE SQL;

CREATE FUNCTION get_email(data json) RETURNS varchar AS $$
	SELECT cast(parse_recurly_xml(data, 'account', 'email') as varchar)
$$ LANGUAGE SQL;

