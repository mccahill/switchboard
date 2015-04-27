json.array!(@links) do |link|
json.link_id link.id
json.link_traffic link.traffic
json.nodes link.approvals do |approval|
	json.id approval.id
	json.ip approval.ip.addr
end

end

