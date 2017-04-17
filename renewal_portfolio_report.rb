Client.set 'ncsu'

report = []
Portfolio.where('duration > 1').find_each do |portfolio|
	result = []
	result << portfolio.id
	result << portfolio.name
	result << portfolio.code
	result << portfolio.fund.name
	result << portfolio.visibility
	result << portfolio.allotment_periods.map { |period| "Start: #{period.start_at} End: #{period.end_at}" }.join(" | ")
	result << portfolio.scopes.pluck(:name).join(" | ")
	report << result
end

headers = %w(portfolio_id portfolio_name fund_code donor_name visibility distribution_periods scopes)

report.easy_csv("renewal_portfolio_report", headers, {direct_upload: false})