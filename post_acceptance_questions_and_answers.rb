Client.set 'worcester'

opportunities = Opportunity::PostAcceptance.where(archive_at: Chronic.parse('12/09/2016').to_date)

report = []
applications = []
opportunities.each do |opportunity|
	
	applicants = opportunity.applications

	applicants.each do |applicant|
		next if applicant.answers.empty?

		row = []
		row << opportunity.id
		row << opportunity.portfolio.name
		row << applicant.user_id
		row << applicant.name

		application.answers.each do |answer|
			app_headers << answer.form_field.label unless app_headers.include?(answer.form_field.label)
			row << answer.attributes["result"]
		end
		report << row

		# applicant.answers.each do |answer|
		# 	row << "#{answer.form_field.label} | #{answer.attributes["result"]}"
		# end
		
	end
end

headers = %w(opportunity_id opportunity_name applicant_id applicant_name)

report.easy_csv("post_acceptance_questions_answers_report", headers, {direct_upload: false})




Client.set 'worcester'

opportunities = Opportunity::PostAcceptance.where(archive_at: Chronic.parse('12/09/2016').to_date)

applications = []
opportunities.each do |opportunity|
	applications += opportunity.applications
end

array_applications_group_by_question_count = applications.group_by {|application| application.answers.count}

array_applications_group_by_question_count.keys.first do |key|
	next if key == 0

	report = []
	app_headers = []
	array_applications_group_by_question_count[key].each do |application|
		# next if applicant.answers.empty?

		row = []
		row << application.opportunity.id
		row << application.opportunity.portfolio.name
		row << application.user_id
		row << application.name

		application.answers.each_with_index do |answer, index|
			app_headers << answer.form_field.label unless app_headers.include?(answer.form_field.label)
			if answer.form_field.label == app_headers[index]
				row << answer.attributes["result"] 
			else
				row << "no match"
			end
		end
		report << row
	end
	headers = %w(opportunity_id opportunity_name applicant_id applicant_name) + app_headers

	report.easy_csv("no_answers_post_acceptance_questions_answers_report", headers, {direct_upload: false})
end










