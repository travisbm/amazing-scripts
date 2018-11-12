portfolio_ids = [37, 95, 54, 66, 73, 83, 94, 103, 107, 217]

opportunity_ids = []

portfolio_ids.each do |portfolio_id|
  portfolio = Portfolio.find(portfolio_id)
  opportunity_ids << portfolio.applicant_opportunities.scholarship.ids
  opportunity_ids.flatten!
end