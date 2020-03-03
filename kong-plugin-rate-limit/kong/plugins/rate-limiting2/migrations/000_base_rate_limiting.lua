return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "ratelimit" (
        "identifier"   TEXT                         NOT NULL,
        "period"       TEXT                         NOT NULL,
        "period_date"  TIMESTAMP WITH TIME ZONE     NOT NULL,
        "service_id"   UUID                         NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::UUID,
        "route_id"     UUID                         NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::UUID,
        "consumer_id"  UUID                         NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::UUID,
        "value"        INTEGER,

        PRIMARY KEY ("identifier", "period", "period_date", "service_id", "route_id", "consumer_id")
      );
    ]],
  },

  cassandra = {
    up = [[
      CREATE TABLE IF NOT EXISTS ratelimit(
        route_id    uuid,
        service_id  uuid,
        period_date timestamp,
        period      text,
        identifier  text,
        value       counter,
        consumer_id text,
        PRIMARY KEY ((route_id, service_id, identifier, period_date, period, consumer_id))
      );
    ]],
  },
}
