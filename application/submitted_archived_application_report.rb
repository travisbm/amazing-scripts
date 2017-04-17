Client.set "hamiltonfoundation"

opportunity = Opportunity.find(1125)

time_range = (opportunity.created_at.to_date..opportunity.archive_at)

users = []
opportunity.applications.each do |application|
	users << application.user if application.state == "submitted"
end

users.keep_if do |user| 
	user.applications.none? do |app| 
		app.type == "Application::PostAcceptance" 
		&& (time_range).include?(app.created_at.to_date) 
		&& app.encumberable_application.encumbers?
	end
end

report = []

users.each do |user|
	row = []
	row << user.id
	row << user.name
	row << user.email
	report << row
end

headers = %w(user_id student_name student_email)

report.easy_csv("un_encumbered_applications", headers, {direct_upload: false})