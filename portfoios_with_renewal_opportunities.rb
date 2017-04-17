# Buffalo State notice some issues with the qualifications on their renewals, and 
# I was hoping y'all could run some reports to help us get to the bottom of them. 
# The first report would be:

# Portfolio Number
# Portfolio Name
# Number of Qualification Groups
# Start date for renewal 1 (MM/DD)
# End date for renewal 1 (MM/DD)
# Start date for renewal 2 (MM/DD)
# End date for renewal 2 (MM/DD)

# The second report would be: 
# Portfolio Number
# Portfolio Name
# Qualifications (all in one cell, similar to the attached CSV we made for NSCU)

# A report of all portfolios with renewal opportunities. 

opportunities = Opportunity::Renewal.all

report = []
opportunities_count = 0

opportunities.order(:start_at).group_by(&:portfolio_id).each do |portfolio_id, opportunities|
	portfolio = Portfolio.find(portfolio_id)

	row = []
	row << portfolio.id
	row << portfolio.name

	opportunities_count = opportunities.count if opportunities.count > opportunities_count

	opportunities.each do |opportunity|
		row << opportunity.id
		row << opportunity.qualification_groups.count
		row << opportunity.start_at
		row << opportunity.end_at
	end
	report << row
end

headers = %w(portfolio_id portfolio_name)
more_headers = %w(renewal_opportunity_id renewal_opportunity_qualification_groups_count start_date end_date)
opportunities_count.times {headers += more_headers}

report.easy_csv("portfolios_with_renewal_opportunities", headers, {direct_upload: false})


