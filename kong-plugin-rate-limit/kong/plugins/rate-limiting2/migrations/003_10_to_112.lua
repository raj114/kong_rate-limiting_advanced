return {
  postgres = {
    up = [[
      CREATE INDEX IF NOT EXISTS ratelimit_idx ON ratelimit (service_id, route_id, period_date, period, consumer_id);
    ]],
  },

  cassandra = {
    up = [[
    ]],
  },
}
