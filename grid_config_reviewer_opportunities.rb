

sample_opportunity_id        = 1616
review_group_id              = 107
sample_grid_name             = "4th year kids"
model_type                   = "Opportunity"
context                      = "reviewer_chair_applications"
view_to_copy                 = GridConfiguration.where(model_id: sample_opportunity_id, model_type: model_type, context: context, name: sample_grid_name).first

sample_opportunity           = Opportunity.find(sample_opportunity_id)
reviewer_group_opportunities = Reviewer::Group.find(review_group_id).opportunities.encumberable.active; nil

# check for questions that may not exist for other opportunities
def find_extra_questions(reviewer_group_opportunities, sample_opportunity)
  reviewer_group_question_ids     = []
  sample_opportunity_question_ids = sample_opportunity.questions.map(&:form_field_id)
  
  extra_question_ids = []
  reviewer_group_uniq_question_ids = []
  reviewer_group_opportunities.each do |opportunity|
    opportunity_question_ids = opportunity.questions.map(&:form_field_id)

    reviewer_group_uniq_question_ids.push *opportunity_question_ids
    extra_question_ids.push *(sample_opportunity_question_ids - opportunity_question_ids)
  end
  reviewer_group_uniq_question_ids.uniq!

  reviewer_group_opportunities_missing_questions = []
  reviewer_group_opportunities.each do |opportunity|
    extra_question_ids.each do |question_id|
      if opportunity.questions.where(form_field_id: question_id).blank?
        reviewer_group_opportunities_missing_questions << opportunity.id
      end
    end
  end

  automatch_missing_questions = []
  Opportunity::Automatch.not_archived.find_each do |opportunity|
    extra_question_ids.each do |question_id|
      if opportunity.questions.where(form_field_id: question_id).blank?
        automatch_missing_questions << opportunity.id
      end
    end
  end

  apply_missing_questions = []
  Opportunity::Apply.not_archived.find_each do |opportunity|
    extra_question_ids.each do |question_id|
      if opportunity.questions.where(form_field_id: question_id).blank?
        apply_missing_questions << opportunity.id
      end
    end
  end

  puts "Review Group uniq question count        | #{reviewer_group_uniq_question_ids.count}"
  puts "Sample Opportunity question count       | #{sample_opportunity_question_ids.count}"
  puts "Questions not on the review group       | #{extra_question_ids}"
  puts "Review Group opps missing questions     | #{reviewer_group_opportunities_missing_questions}"
  puts "Auto-match opps missing questions count | #{automatch_missing_questions.uniq.count}"
  puts "Apply-to opps missing questions count   | #{apply_missing_questions.uniq.count}"
end

# check how many existing GridConfigurations of this type
def existing_grid_config_count(model_type, context, sample_grid_name)
  existing = GridConfiguration.where(model_type: model_type).where(context: context).where(name: sample_grid_name).count
end

# check if the GridConfiguration is filtering on category
def filtering_on_category?(view_to_copy)
  messages = []
  parsed_settings = JSON.parse(view_to_copy.settings)
  parsed_settings["filters"].each do |filter|
    messages << "Filtering on Category!" if filter["field"] == "category_id"
  end
  messages.empty? ? false : true
end

find_extra_questions(reviewer_group_opportunities, sample_opportunity)
existing_grid_config_count(model_type, context, sample_grid_name)
filtering_on_category?(view_to_copy)

skipped = []
updated = []
reviewer_group_opportunities.each do |opportunity|
  next if opportunity.blank?
  if GridConfiguration.where(model_id: opportunity.id, name: view_to_copy.name).exists?
    skipped << opportunity.id
  else
    new_config = view_to_copy.dup
    new_config.model_id = opportunity.id
    new_config.save!

    # this will save the new view as the default view:
    default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: model_type, model_id: opportunity.id, context: context)
    default_grid_configuration.grid_configuration_id = new_config.id
    default_grid_configuration.save!

    updated << opportunity.id
  end
end

def create_new_grid(opportunity, view_to_copy)
  new_config = view_to_copy.dup
  new_config.model_id = opportunity.id
  new_config.save!
end

def create_new_grid_and_set_as_default(opportunity, view_to_copy)
  new_config = view_to_copy.dup
  new_config.model_id = opportunity.id
  new_config.save!

  # this will save the new view as the default view:
  default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: "Opportunity", model_id: opp.id, context: "applications", name: "Basic ENGR view for Reviewers")
  default_grid_configuration.grid_configuration_id = new_config.id
  default_grid_configuration.save!
end








