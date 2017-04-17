Client.set 'usm'

reference_opportunity_ids = [8337, 8335, 8336, 8333]

reference_opportunity_ids.each do |id|
	opportunity  = Opportunity::Reference.find(id)
	applications = opportunity.applications.not_archived

	report  = []
	app_headers = []
	applications.each do |application|
		#next unless User.exists?(application.evaluator_id) && User.exists?(application.user_id)
		row = []
		row << application.evaluator.id
		row << application.evaluator.name
		row << User.find(application.evaluator.applicant_user_id).id
		row << User.find(application.evaluator.applicant_user_id).name

		application.answers.each do |answer|
			app_headers << answer.form_field.label unless app_headers.include?(answer.form_field.label)
			row << answer.attributes["result"]
		end
		report << row
	end

	headers_also = %w(reference_id reference_name student_id student_name)

	headers = headers_also + app_headers

	name_hash = {8333 => "honors_program_second_recommendation", 8335 => "usm_competitive_programs", 8336 => "luckyday_citizenship_scholars", 8337 => "counselor_report"}

	file_name = opportunity.name.downcase.gsub(/\W/, "_")

	report.easy_csv(file_name, headers, {direct_upload: true})
end


# To find how many opportunities are using a reference opportunity
Portfolio.joins('opportunities' => {'questions' => 'form_field'}).where('form_field' => {'opportunity_id' => 1234})
# or
Opportunity.joins('questions' => 'form_field').merge(FormField.where(opportunity_id: 1234))