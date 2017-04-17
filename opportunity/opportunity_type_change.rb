Client.set "bgsu"

start_at   = Chronic.parse('10/24/2016')
updated_at = Chronic.parse('10/31/2016')

report = []

Opportunity::Apply.not_archived.where("start_at = ? AND updated_at > ?", start_at, updated_at).find_each do |opportunity|
	
	opportunity.history.select{|l| l['changes']['type'] == ["Opportunity::Automatch", "Opportunity::Apply"]}.each do |hist|
		
		occurred_at = Chronic.parse(hist['occurred_at'])

		next if occurred_at < updated_at
		
		row = []
		row << opportunity.id
		row << opportunity.portfolio.name
		row << opportunity.type
		row << hist["occurred_at"]
		report << row
	end

end


headers = ["opportunity_id", "opportunity_name", "current_type", "date_changed_from_automatch"]
report.easy_csv("changed_opportunities", headers, {direct_upload: false})
