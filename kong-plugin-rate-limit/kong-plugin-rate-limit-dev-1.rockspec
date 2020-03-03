package = "kong-plugin-rate-limit"
version = "dev-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.rate-limiting2.daos"] = "kong/plugins/rate-limiting2/daos.lua",
      ["kong.plugins.rate-limiting2.handler"] = "kong/plugins/rate-limiting2/handler.lua",
      ["kong.plugins.rate-limiting2.migrations.000_base_rate_limiting"] = "kong/plugins/rate-limiting2/migrations/000_base_rate_limiting.lua",
      ["kong.plugins.rate-limiting2.migrations.003_10_to_112"] = "kong/plugins/rate-limiting2/migrations/003_10_to_112.lua",
      ["kong.plugins.rate-limiting2.migrations.init"] = "kong/plugins/rate-limiting2/migrations/init.lua",
      ["kong.plugins.rate-limiting2.policies.cluster"] = "kong/plugins/rate-limiting2/policies/cluster.lua",
      ["kong.plugins.rate-limiting2.policies.init"] = "kong/plugins/rate-limiting2/policies/init.lua",
      ["kong.plugins.rate-limiting2.schema"] = "kong/plugins/rate-limiting2/schema.lua"
   }
}
