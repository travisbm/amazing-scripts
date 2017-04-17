Client.set ""

application_count = Application.count
user_count 	      = User.count
opportunity_count = Opportunity.count

user_ids = []

opportunity_ids = []

application_ids = []

# delete applications
Support::Delete::Applications.delete!(*application_ids)

# delete all applications
Support::Delete::Applications.delete_all!

# check users before deletion
Support::Delete::Users.check_users(*user_ids)

# delete users
Support::Delete::Users.delete!(*user_ids)

# delete opportunities
Support::Delete::Opportunities.delete!(*opportunity_ids)




# For delhi deletions

Client.set 'delhi'

portfolio_ids = []

user_ids = []

# Script to grab the scholarship opportunity ids from the provided portfolios
opportunity_ids = []
portfolio_ids.each do |id|
	portfolio = Portfolio.find(id)
	opportunity = portfolio.opportunities.select{|o| o.scholarship?}

	raise("Portfolio ID: #{portfolio.id} has more than one scholarship Opporunity") if opportunity.count != 1

	opportunity_ids << opportunity.first.id
end

Support::Delete::Opportunities.delete!(*opportunity_ids)

# Delete Users

# check users before deletion
Support::Delete::Users.check_users(*user_ids)

# ["User 82 CANNOT be deleted -- 5 Applicant Reviews",
#  "User 81 CANNOT be deleted -- 4 Applicant Reviews",
#  "User 80 CANNOT be deleted -- 4 Applicant Reviews",
#  "User 79 CANNOT be deleted -- 5 Applicant Reviews"]

# Delete users with Applicant Reviews that have been started.

user_ids = []

user_ids.each do |id|
	user = User.find(id)

	apps = user.profile_applications.pluck(:id)
	Support::Delete::Applications.delete!(*apps)

	apps = user.applicant_applications.pluck(:id)
	Support::Delete::Applications.delete!(*apps)	
end

# Clear out ALL Opportunity Dates
Opportunity::Scholarship.not_archived.each do |opportunity|
  opportunity.start_at = nil
  opportunity.end_at = nil
  opportunity.effective_end_at = nil
  opportunity.review_period_start_at = nil
  opportunity.review_period_end_at = nil
  opportunity.save!
end












