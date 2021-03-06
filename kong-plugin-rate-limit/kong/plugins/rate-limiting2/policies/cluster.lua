-------------------------------------
-- It performs operation on database and returns response to the ratelimiting handler
-- @author : Rajendra Garade
-------------------------------------

local timestamp = require "kong.tools.timestamp"
local cassandra = require "cassandra"


local kong = kong
local concat = table.concat
local pairs = pairs
local floor = math.floor
local fmt = string.format


return {
  cassandra = {
    increment = function(connector, limits, identifier, current_timestamp, service_id, route_id, value)
      local periods = timestamp.get_timestamps(current_timestamp)

      for period, period_date in pairs(periods) do
        if limits[period] then
          local res, err = connector:query([[
            UPDATE ratelimit
               SET value = value + ?
             WHERE identifier = ?
               AND period = ?
               AND period_date = ?
               AND service_id = ?
               AND route_id = ?
          ]], {
            cassandra.counter(value),
            identifier,
            period,
            cassandra.timestamp(period_date),
            cassandra.uuid(service_id),
            cassandra.uuid(route_id),
          })
          if not res then
            kong.log.err("cluster policy: could not increment cassandra counter for period '",
                         period, "': ", err)
          end
        end
      end

      return true
    end,
    find = function(connector, identifier, period, current_timestamp, service_id, route_id)
      local periods = timestamp.get_timestamps(current_timestamp)

      local rows, err = connector:query([[
        SELECT value
          FROM ratelimit
         WHERE identifier = ?
           AND period = ?
           AND period_date = ?
           AND service_id = ?
           AND route_id = ?
      ]], {
        identifier,
        period,
        cassandra.timestamp(periods[period]),
        cassandra.uuid(service_id),
        cassandra.uuid(route_id),
      })

      if not rows then
        return nil, err
      end

      if #rows <= 1 then
        return rows[1]
      end

      return nil, "bad rows result"
    end,
  },
  postgres = {
    increment = function(connector, limits, identifier, current_timestamp, service_id, route_id, consumer_id, value)
      local buf = { "BEGIN" }
      local len = 1
      local periods = timestamp.get_timestamps(current_timestamp)

      for period, period_date in pairs(periods) do
          if type(limits[period]) == "number" then
            len = len + 1
            buf[len] = fmt([[
              INSERT INTO "ratelimit" ("identifier", "period", "period_date", "service_id", "route_id", "consumer_id", "value")
                   VALUES ('%s', '%s', TO_TIMESTAMP('%s') AT TIME ZONE 'UTC', '%s', '%s', '%s', %d)
              ON CONFLICT ("identifier", "period", "period_date", "service_id", "route_id", "consumer_id") DO UPDATE
                      SET "value" = "ratelimit"."value" + EXCLUDED."value"
            ]], identifier, period, floor(period_date / 1000), service_id, route_id, consumer_id, value)
          end
      end

      if len > 1 then
        local sql
        if len == 2 then
          sql = buf[2]

        else
          buf[len + 1] = "COMMIT;"
          sql = concat(buf, ";\n")
        end

        local res, err = connector:query(sql)
        if not res then
          return nil, err
        end
      end

      return true
    end,
    find = function(connector, identifier, period, current_timestamp, service_id, route_id, consumer_id)
      local periods = timestamp.get_timestamps(current_timestamp)

      local sql = fmt([[
        SELECT "value"
          FROM "ratelimit"
         WHERE "identifier" = '%s'
           AND "period" = '%s'  
           AND "period_date" = TO_TIMESTAMP('%s') AT TIME ZONE 'UTC'
           AND "service_id" = '%s'
           AND "route_id" = '%s'
           AND "consumer_id" = '%s'
         LIMIT 1;
      ]], identifier, period, floor(periods[period] / 1000), service_id, route_id, consumer_id)

      local res, err = connector:query(sql)
      if not res or err then
        return nil, err
      end

      return res[1]
    end,

    find_parent_config = function(connector,parent_consumer_id)

      local sql = fmt([[
        SELECT "config"
        FROM "plugins"
        WHERE "consumer_id" = '%s';
      ]],parent_consumer_id)
      
      local res, err = connector:query(sql)
      if not res or err or res == nil then
        return nil, err
      end
    
      return res[1]
    end,
  },
}
