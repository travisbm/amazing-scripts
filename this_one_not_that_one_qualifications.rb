Client.set "ncsu"

opportunities = Opportunity::RenewalTemplate.not_archived.select { |o| o.qualifications.any? }

qual_1 = [">", ["0"], 10122]
qual_2 = ["=~", ["No"], 10104]

# A report of any renewal future templates that have the qualification of 'Fed Need Acad must be greater than 0' 
# but don't have the qualification of 'Verification Flag must include No'.
# The report should also have the name of the Portfolio and the associated Scope(s).
opportunity_ids = []
opportunities.each do |opportunity|
	
	opportunity.qualification_groups.each do |group|

		qualifications = []

		qualifications << group.qualifications.pluck(:comparison, :values, :form_field_id)

		if qualifications.any? {|q| q.include?(qual_1) && q.exclude?(qual_2)}
			next if opportunity_ids.include?(opportunity.id)
			opportunity_ids << opportunity.id
		else
			next
		end

	end

end

report = []
opportunity_ids.each do |opportunity_id|
	
	opportunity = Opportunity.find(opportunity_id)

	opportunity.qualification_groups.each do |qual_group|
		row = []

		row << opportunity.portfolio.id
		row << opportunity.id
		row << opportunity.portfolio.name
		row << opportunity.portfolio.scopes.pluck(:name).join(", ")
		row << opportunity.qualifications.count
		
		qual_row = []
		qual_group.qualifications.each do |qualification|

			form_field_name = FormField.find(qualification.form_field_id).label
			comparison      = qualification.comparison
			values			= qualification.values

			qualifications = [form_field_name, comparison, values]
			
			qual_row << qualifications
		end
		row << qual_row
		report << row
	end
end

headers = %w(portfolio_id opportunity_id opportunity_name scopes qualification_count qualifications)

report.easy_csv("qualification_report", headers, {direct_upload: false})
