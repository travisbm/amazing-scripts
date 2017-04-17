opportunity_ids = [2129, 2132, 2135]

opportunity = Opportunity.find(opportunity_id)

report = []

opportunity.applications.each do |application|
	application.history.since(Chronic.parse("12/16/2015")).select {|h| h["changes"]["category_id"]}.each do |hist|
		report << hist if hist["changes"]["category_id"][0] != nil
	end
end

headers = %w(application_id name category applied_on categorized_on tartan_id)