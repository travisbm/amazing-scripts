#Unsubmitted References for a specific opportunity

Client.set "sbccd"

opportunity = Opportunity.find(687)

report = []
references_to_email = []
opportunity.applications.not_archived.find_each do |application|
	reference_ids = []

	reference_ids << application.answer(10168).attributes["result"]
	reference_ids << application.answer(10169).attributes["result"]
	reference_ids << application.answer(10170).attributes["result"]

	reference_ids.each do |reference_id|
		next if reference_id.nil?
		reference = Reference.find(reference_id)
		reference_application = reference.application
		next if reference.expired?
		references_to_email << reference.id 
		results = []
		results << reference.opportunity.name
		results << reference.name
		results << reference_application.user.email
		results << reference.applicant.name
		results << reference.applicant.email
		results << reference_application.category.name
		results << reference.created_at
		report  << results
	end
end

headers = %w(reference_type reference_name reference_email applicant_name applicant_email status requested_date)

report.easy_csv("reference_report_opportunity_#{opportunity.id}", headers, {direct_upload: false})

# To email references in Drafted category
emailed = []
Reference.find(references_to_email).each do |reference|
	reference.email_contact if reference.application.category.name == "Drafted"
	emailed << reference.id #if reference.application.category.name == "Drafted"
end
