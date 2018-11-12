Client.set 'lamar'

award_term_ids = AwardTerm.where(name: ["FY1819", "Fall 2018 Only", "Spring 2019 Only"]).ids
applications = Application.where(award_term_id: award_term_ids)

report = []

applications.each do |application|
  application_id = application.id
  applicant_name = application.user.name
  award_amount = application.amount
  award_period = application.award_term.name
  application_category = application.category.name
  opportunity_name = application.opportunity.portfolio_name

  row = [application_id, applicant_name, award_amount, award_period, application_category, opportunity_name]
  report << row
end


headers = %w(application_id applicant_name award_amount award_period application_category opportunity_name)

report.easy_csv("applications_report", headers, {direct_upload: false})

