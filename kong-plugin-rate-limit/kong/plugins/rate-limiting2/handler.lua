-- RateLimiting Handler
-------------------------------------
-- 
-- @author : Rajendra Garade
-------------------------------------

local timestamp = require "kong.tools.timestamp"
local policies = require "kong.plugins.rate-limiting2.policies"
local BasePlugin = require "kong.plugins.base_plugin"
local RateLimitingHandler = BasePlugin:extend()
local access = require "kong.plugins.rate-limiting2.handler"

local c_id 

local kong = kong
local ngx = ngx
local max = math.max
local time = ngx.time
local floor = math.floor
local pairs = pairs
local tostring = tostring
local timer_at = ngx.timer.at


local EMPTY = {}
local EXPIRATIONS = policies.EXPIRATIONS


local RATELIMIT_LIMIT     = "RateLimit-Limit"
local RATELIMIT_REMAINING = "RateLimit-Remaining"
local RATELIMIT_RESET     = "RateLimit-Reset"
local RETRY_AFTER         = "Retry-After"


local X_RATELIMIT_LIMIT = {
  second = "X-RateLimit-Limit-Second",
  minute = "X-RateLimit-Limit-Minute",
  hour   = "X-RateLimit-Limit-Hour",
  day    = "X-RateLimit-Limit-Day",
  month  = "X-RateLimit-Limit-Month",
  year   = "X-RateLimit-Limit-Year",
}

local X_RATELIMIT_REMAINING = {
  second = "X-RateLimit-Remaining-Second",
  minute = "X-RateLimit-Remaining-Minute",
  hour   = "X-RateLimit-Remaining-Hour",
  day    = "X-RateLimit-Remaining-Day",
  month  = "X-RateLimit-Remaining-Month",
  year   = "X-RateLimit-Remaining-Year",
}


local RateLimitingHandler = {}

RateLimitingHandler.PRIORITY = 901
RateLimitingHandler.VERSION = "2.1.0"


local function get_identifier(config)
  local identifier

  if config.limit_by == "service" then
    identifier = ""
  elseif config.limit_by == "consumer" then
    identifier = (kong.client.get_consumer() or
                  kong.client.get_credential() or
                  EMPTY).id

  elseif config.limit_by == "credential" then
    identifier = (kong.client.get_credential() or
                  EMPTY).id
  end

  return identifier or kong.client.get_forwarded_ip()
end


local function get_usage(config, identifier, current_timestamp, limits)
  local usage = {}
  local stop

  for period, limit in pairs(limits) do
    local current_usage, err = policies[config.policy].usage(config, identifier, period, current_timestamp)
    if err then
      return nil, nil, err
    end

    -- What is the current usage for the configured limit name?
    if type(limit) == "number" then
      local remaining = limit - current_usage
    
     -- Recording usage
      usage[period] = {
        limit = limit,
        remaining = remaining,
      }

      if remaining <= 0 then
        stop = period
      end
    end
  end
  return usage, stop
end


local function get_access(config,data)

  local current_timestamp = time() * 1000
  local identifier

  -- Consumer is identified by ip address or authenticated_credential id
  if data == 1 then
    identifier = get_identifier(config)
  else
    identifier = c_id
  end
 
  local fault_tolerant = config.fault_tolerant

  -- Load current metric for configured period
  local limits = {
    second = config.second,
    minute = config.minute,
    hour = config.hour,
    day = config.day,
    month = config.month,
    year = config.year,
  }

  local usage, stop, err = get_usage(config, identifier, current_timestamp, limits)
  if err then
    if fault_tolerant then
      kong.log.err("failed to get usage: ", tostring(err))
    else
      kong.log.err(err)
      return kong.response.exit(500, { message = "An unexpected error occurred" })
    end
  end

  if usage then
    -- Adding headers
    local reset
    if not config.hide_client_headers then
      local headers = {}
      local timestamps
      local limit
      local window
      for k, v in pairs(usage) do
        headers[RATELIMIT_LIMIT .. "-" .. k] = v.limit
        headers[RATELIMIT_REMAINING .. "-" .. k] = math.max(0, (stop == nil or stop == k) and v.remaining - 1 or v.remaining) -- -increment_value for this current request
     
      end

      kong.ctx.plugin.headers = headers
    end

    -- If limit is exceeded, terminate the request
    if stop then
      return kong.response.exit(429, { message = "API rate limit exceeded" }, {
        [RETRY_AFTER] = reset
      })
    end
  end

  local incr = function(premature, config, limits, identifier, current_timestamp, value)
    if premature then
      return
    end
    policies[config.policy].increment(config, limits, identifier, current_timestamp, value)
  end


  -- Increment metrics for configured periods if the request goes through
  local ok, err = timer_at(0, incr, config, limits, identifier, current_timestamp, 1)
  if not ok then
    kong.log.err("failed to create timer: ", err)
  end
  
  c_id = config.consumer_id
  -- if the parent consumer is is present in config json then it also update the values for that consumer_id in database
  if type(config.consumer_id) ~= "userdata" then 
    local config,err = policies[config.policy].parent_config(config.consumer_id)
   if err then
     return err
    end

    get_access(config,0)
  end
end


function RateLimitingHandler:access(config)
  local config,err = policies[config.policy].parent_config(config.consumer_id)
  if err then
    return err
  end
  get_access(config,1)
end


function RateLimitingHandler:header_filter(_)
  local headers = kong.ctx.plugin.headers
  if headers then
    kong.response.set_headers(headers)
  end
end


function RateLimitingHandler:log(_)
  if kong.ctx.plugin.timer then
    kong.ctx.plugin.timer()
  end
end


return RateLimitingHandler

