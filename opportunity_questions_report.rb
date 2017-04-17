# find questions that were qualifying questions on opportunities
Client.set ""

opportunities = Opportunity::Apply.not_archived.includes(:questions) +
				Opportunity::PostAcceptance.not_archived.includes(:questions) +
				Opportunity::Renewal.not_archived.includes(:questions) +
				Opportunity::RenewalTemplate.not_archived.includes(:questions)

report = []
opportunities.each do |opportunity|
	questions = opportunity.questions.specific
	form_field_ids = opportunity.qualifications.pluck(:form_field_id)

	questions.each do |question|
		form_field = FormField.find(question.form_field_id)

	if Qualification.where(form_field_id: question.form_field_id).count > 0
			next
		else
			row = []
			row << question.id
			row << form_field.id
			row << form_field.label
			row << opportunity.id
			row << opportunity.portfolio.name
			row << opportunity.name
			form_field_ids.include?(form_field.id) ? row << true : row << false
			report << row
		end
	end
end

headers = %w(question_id form_field_id form_field_label(question) opportunity_id opportunity_name season qualifying)

report.easy_csv("applyto_application_questions", headers, {direct_upload: false})

# find unused form_fields and the last opportunity they were associated with, if there was one.

Client.set ""

opportunities = Opportunity::Apply.not_archived.includes(:questions) +
				Opportunity::PostAcceptance.not_archived.includes(:questions) +
				Opportunity::Renewal.not_archived.includes(:questions) +
				Opportunity::RenewalTemplate.not_archived.includes(:questions)

#form_field_ids = FormField.where(availability: 'specific').pluck(:id)

form_field_ids = FormField.where(asked_to: "applicant").specific.pluck(:id)

specific_form_field_ids = []
opportunities.each do |opportunity|
	questions = opportunity.questions.specific

	specific_form_field_ids += questions.pluck(:form_field_id)
end

unused_form_field_ids = form_field_ids - specific_form_field_ids.uniq

report = []
unused_form_field_ids.each do |id|
	form_field = FormField.find(id)
	next if form_field.archived?

	last_associated_opportunity = form_field.opportunities.order(archive_at: :desc).first

	if !last_associated_opportunity.nil?
		row = []

		row << id
		row << form_field.label
		row << last_associated_opportunity.id
		row << last_associated_opportunity.portfolio.name
		row << last_associated_opportunity.name
	else
		row = []

		row << id
		row << form_field.label
		row << ""
		row << ""
		row << ""
	end
	report << row
end

headers = %w(form_field_id form_field_label last_associated_opportunity_id last_associated_opportunity_name last_associated_opportunity_cycle)

report.easy_csv("unused_form_fields_report", headers, {direct_upload: false})

# most recent archived opportunity form_field was on
FormField.find(10840).opportunities.order(archive_at: :desc)














