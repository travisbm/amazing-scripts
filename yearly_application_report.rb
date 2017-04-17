Client.set "ciachef"

range_2015 = (Time.parse('01/01/2015')..Time.parse('31/12/2015'))
range_2016 = (Time.parse('01/01/2016')..Time.parse('16/12/2016'))

applications_2015 = Application::Encumberable.where(created_at: range_2015)
applications_2016 = Application::Encumberable.where(created_at: range_2016)

report = []
applications_2016.each do |application|
	row = []

	row << application.opportunity.id
	row << application.opportunity.portfolio.name
	row << application.id
	row << application.created_at
	row << application.category.name
	row << application.user.id
	row << application.user.name
	report << row
end

headers = %w(opportunity_id, opportunity_name, application_id, applied_on_date, category, student_id, student_name)

report.easy_csv("2015_applications_report", headers, {direct_upload: false})
