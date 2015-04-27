json.array!(@switches) do |switch|
  json.extract! switch, :id, :name, :description, :hub
  json.url switch_url(switch, format: :json)
end
