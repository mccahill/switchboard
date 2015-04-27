json.array!(@switch_initial_configs) do |switch_initial_config|
  json.extract! switch_initial_config, :id, :ip, :vlan, :network_type
  json.url switch_initial_config_url(switch_initial_config, format: :json)
end
