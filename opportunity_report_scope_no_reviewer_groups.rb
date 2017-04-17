# Scope to be included in desired Portfolio scopes
scope = Scope.find(9)

report = []
Opportunity::Encumberable.not_archived.order(:id).each do |opportunity|
	next if !opportunity.portfolio.scopes.include?(scope)
  	report << [opportunity.id, opportunity.portfolio.name] if opportunity.reviewer_groups.not_prime.blank?
end

headers = %w(opportunity_id opportunity_name)

report.easy_csv("Ag_and_Life_Scienes_scope_no_reviewer_groups_report", headers, {direct_upload: false})
