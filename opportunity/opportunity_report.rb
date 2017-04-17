Client.set ""

opportunities = Opportunity.where(type: "Opportunity::External")

report = []

opportunities.each do |op|
  result = []
  result << op.id
  result << op.type.gsub("Opportunity::", "")
  result << op.portfolio.name
  result << op.description
  result << op.start_at
  result << op.end_at
  result << op.archived?
  result << op.archive_at
  result << op.updated_at.strftime('%m/%d/%y')
  result << op.visible_award_amount
  result << op.portfolio.scopes.pluck(:name).join(" | ")
  result << op.portfolio.visibility
  result << op.external_url
  # result << op.notes.pluck(:comment).join(" | ")
  result << op.portfolio.notes.pluck(:comment).join(" | ")

  report << result
end

headers = %w(id type scholarship_name description start_at end_at
             archived? archive_at updated_at visible_award_amount
             scopes visibility external_url notes)

report.easy_csv("external_opportunities_report", headers, {direct_upload: true})
