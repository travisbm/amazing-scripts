# Would it be possible to run a report of applicants that do not qualify for any opportunities? 
# Additionally, a report of any applicants that do not qualify for opportunities gated by a 
# conditional application?



Client.set "csulb"

report = []

Opportunity::Profile.current.applications.submitted.find_each do |general_application|
  user = general_application.user
  
  next if user.applications.not_archived.where("applications.qualification_points >= 1").any?

  applications = user.applications.not_archived - [general_application]
  
  applications_string = applications.map{|a| a.opportunity.portfolio.name}.join(" | ")
  opportunity_ids = applications.map{|a| a.opportunity_id}.join(", ")
  
  results = []
  results << user.id
  results << user.display_name
  results << user.email
  results << general_application.id
  results << applications.count
  results << applications_string
  results << opportunity_ids
  report  << results
end

headers = ["user_id", "user_name", "user_email", "general_application_id", "un_qualified_count", "un_qualified_opportunities", "un_qualified_opportunities_ids"]

report.easy_csv("unqualified_applicants_all_opportunities", headers, {direct_upload: false})


# All students who don't qualify for conditional opportunities
Client.set "csulb"

report = []

Opportunity::Profile.current.applications.submitted.find_each do |general_application|
  user = general_application.user

  applications = user.applications.not_archived.select {|application| application.conditional? && application.qualification_points == 0}
  
  next if applications.none?
    
  applications_string = applications.map{|a| a.opportunity.portfolio.name}.join(" | ")
  opportunity_ids = applications.map{|a| a.opportunity_id}.join(", ")
  
  results = []
  results << user.id
  results << user.display_name
  results << user.email
  results << general_application.id
  results << applications.count
  results << applications_string
  results << opportunity_ids
  report  << results
end

headers = ["user_id", "user_name", "user_email", "general_application_id", "un_qualified_count", "un_qualified_conditional_opportunities", "un_qualified_conditional_opportunities_ids"]

report.easy_csv("unqualified_applicants_conditional_opportunities", headers, {direct_upload: false})


