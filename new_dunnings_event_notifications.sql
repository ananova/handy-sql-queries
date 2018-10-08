WITH new_dunning_event_notifications AS (
  SELECT
    CAST(data->>'xml' AS xml) as xml
  FROM events
  WHERE events.type = 'recurly_new_dunning_event_notification_received'
)

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
FROM new_dunning_event_notifications

