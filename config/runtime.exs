import Config
config :kv, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :"foo@wall-E"},
    {?n..?z, :"bar@wall-E"}
  ]
end
