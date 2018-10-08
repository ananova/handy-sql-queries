WITH successful_payment_notifications AS (
  SELECT
    CAST(data->>'xml' AS xml) as xml
  FROM events
  WHERE events.type = 'recurly_successful_payment_notification_received'
)

SELECT 
  get_account_code(xml)             AS recurly_account_code
, get_recurly_subscription_id(xml)  AS recurly_subscription_id
, get_subscription_amount(xml)      AS amount_in_cents
, get_email(xml)                    AS email
FROM successful_payment_notifications

