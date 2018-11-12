date_of_cutoff = Time.parse("01/01/2017")

date_of_change = Time.parse("11/05/2017")

opportunities = Scope.find(8).opportunities.encumberable.not_archived.where("opportunities.created_at <= ?", date_of_cutoff); nil

attributes = %w[start_at end_at effective_end_at review_period_start_at review_period_end_at]

report = []
opportunities.each do |opportunity|
  row = []
  row << opportunity.id
  row << opportunity.portfolio.name

  attributes.each do |attribute|
    last_change = opportunity.history.after(date_of_change).changes(attribute).first
    if last_change.nil?
      row << nil
      row << nil
    else
      last_change_values = last_change["changes"][attribute]
      changed_from = last_change_values.first
      changed_to = last_change_values.last

      opportunity.update_attribute(attribute, changed_from)

      row << [changed_from, changed_to]
      row << last_change["occurred_at"]
    end
  end
  report << row
end

headers = %w[opportunity_id opportunity_name start_at occurred_at end_at occurred_at effective_end_at occurred_at review_period_start_at occurred_at review_period_end_at occurred_at]

report.easy_csv("changed_dates", headers, {direct_upload: false})
