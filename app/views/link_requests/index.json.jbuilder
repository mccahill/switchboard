json.array!(@link_requests) do |link_request|
  json.extract! link_request, :id
  json.url link_request_url(link_request, format: :json)
end
