# copy grid configuration from sample auto-match opportunity to others

Client.set "shsu"

sample_opportunity_id = 3642
sample_grid_name = "COBE"
view_to_copy = GridConfiguration.where(model_id: sample_opportunity_id, model_type: "Opportunity", context: "applications", name: sample_grid_name).first

# check for non-profile questions that may not exist for other opportunities
sample_opportunity = Opportunity.find(sample_opportunity_id)
profile = Opportunity::Profile.current
extra_question_ids = sample_opportunity.questions.map(&:form_field_id) - profile.questions.map(&:form_field_id)

automatch_missing_questions = []
Opportunity::Automatch.not_archived.find_each do |opportunity|
  extra_question_ids.each do |question_id|
    if opportunity.questions.where(form_field_id: question_id).blank?
      automatch_missing_questions << opportunity.id
    end
  end
end
automatch_missing_questions.count

apply_missing_questions = []
Opportunity::Apply.not_archived.find_each do |opportunity|
  extra_question_ids.each do |question_id|
    if opportunity.questions.where(form_field_id: question_id).blank?
      apply_missing_questions << opportunity.id
    end
  end
end
apply_missing_questions.count
# end check

# check how many already exist:
existing = GridConfiguration.where(model_type: "Opportunity").where(context: "applications").where(name: sample_grid_name).count

# check if this config is filtering on category:
messages = []
parsed_settings = JSON.parse(view_to_copy.settings)
parsed_settings["filters"].each do |filter|
  messages << "Filtering on Category!" if filter["field"] == "category_id"
end
messages
# end check

# opportunity_ids = [1,2,3]
skipped = []
updated = []
Opportunity::Encumberable.not_archived.find_each do |opportunity|
# opportunity_ids.each do |id|
#   opportunity = Opportunity.find(id)
#   next if opportunity.blank?
  if GridConfiguration.where(model_id: opportunity.id, name: view_to_copy.name).exists?
    skipped << opportunity.id
  else
    new_config = view_to_copy.dup
    new_config.model_id = opportunity.id
    #new_config.save!
    updated << opportunity.id

    # this will save the new view as the default view:
    default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: "Opportunity", model_id: opportunity.id, context: "applications")
    default_grid_configuration.grid_configuration_id = new_config.id
    #default_grid_configuration.save!
  end
end

# To count opportunities when excluding certain scopes
count = 0
Scope.select {|scope| scope.id != 5}.each do |scope|
	count += scope.opportunities.not_archived.encumberable.count
end


#### Just make a grid default in mass by scope

scopes = Scope.select {|scope| scope.id != 5}
grid_to_make_default = GridConfiguration.find(3615)

skipped = []
updated = []

scopes.each do |scope|
	scope.opportunities.encumberable.not_archived.find_each do |opportunity|

	  default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: "Opportunity", model_id: opportunity.id, context: "applications")

	  if default_grid_configuration.grid_configuration_id == grid_to_make_default.id
	    skipped << opportunity.id
	  else
	    default_grid_configuration.grid_configuration_id = grid_to_make_default.id
		default_grid_configuration.save!
	    updated << opportunity.id
	  end
	end
end

# Update by multiple scopes

scopes = Scope.find([3, 92, 94, 99, 100, 95, 96])

skipped = []
updated = []

scopes.each do |scope|
  scope.opportunities.encumberable.not_archived.find_each do |opportunity|
    next if opportunity.blank?
  if GridConfiguration.where(model_id: opportunity.id, name: view_to_copy.name).exists?
    skipped << opportunity.id
  else
    new_config = view_to_copy.dup
    new_config.model_id = opportunity.id
    #new_config.save!
    updated << opportunity.id

    # this will save the new view as the default view:
    default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: "Opportunity", model_id: opportunity.id, context: "applications")
    default_grid_configuration.grid_configuration_id = new_config.id
    #default_grid_configuration.save!
  end
end


