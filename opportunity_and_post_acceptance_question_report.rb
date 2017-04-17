Client.set 'manhattan'

opportunities = Opportunity::PostAcceptance.not_archived

report = []
opportunities.each do |opportunity|
	parent_opportunity = Opportunity.find(opportunity.parent_id)
	row = []
	row << parent_opportunity.id
	row << parent_opportunity.portfolio.name
	row << opportunity.id
	opportunity.questions.empty? ? row << "No question" : row << opportunity.questions.first.form_field.label
	report << row
end

headers = %w(opportunity_id opportunity_name post_acceptance_opportunity_id post_acceptance_question)

report.easy_csv("opportunity_post_acceptance_questions", headers, {direct_upload: false})