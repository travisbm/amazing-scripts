Client.set ""

report = []

Opportunity.archived.where(archive_at: Chronic.parse("12/02/2016")).select{|op| op.notes.count > 0}.each do |opportunity|
	row = []
	row << opportunity.id
	row << opportunity.portfolio.name
	row << opportunity.type
	row << opportunity.notes.pluck(:comment)
	report << row
end

headers = %w(opportunity_id opportunity_name opportunity_type opportunity_notes)

report.easy_csv("archived_opportunity_notes", headers, {direct_upload: false})