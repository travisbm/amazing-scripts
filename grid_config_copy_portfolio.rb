# copy grid configuration from sample auto-match opportunity to others

Client.set "training-wvu"

# A renewal opportunity that has the grid view
sample_opportunity_id = 6807
sample_grid_name      = "For Review"
model_type            = "Opportunity"
context               = "reviewer_chair_applications"
view_to_copy          = GridConfiguration.where(model_id: sample_opportunity_id, model_type: model_type, context: context, name: sample_grid_name).first

check = GridConfigCheck.new(sample_opportunity_id, sample_grid_name)

class GridConfigCheck

  attr_reader :extra_question_ids

  def initialize(opportunity_id, grid_name)
    @sample_opportunity_id = opportunity_id
    @sample_grid_name = grid_name
    @view_to_copy = GridConfiguration.where(model_id: opportunity_id, model_type: "Opportunity", context: "reviewer_chair_applications", name: grid_name).first
  end

  def call
    check_for_non_profile_questions
    existing_grid_config_count
    filtering_on_category
  end

  # check for non-profile questions that may not exist for other opportunities
  def check_for_non_profile_questions
    sample_opportunity = Opportunity.find(@sample_opportunity_id)
    profile = Opportunity::Profile.current
    @extra_question_ids = sample_opportunity.questions.map(&:form_field_id) - profile.questions.map(&:form_field_id)

    automatch_missing_questions = []
    Opportunity::Automatch.not_archived.find_each do |opportunity|
      extra_question_ids.each do |question_id|
        if opportunity.questions.where(form_field_id: question_id).blank?
          automatch_missing_questions << opportunity.id
        end
      end
    end
    # automatch_missing_questions.count

    apply_missing_questions = []
    Opportunity::Apply.not_archived.find_each do |opportunity|
      extra_question_ids.each do |question_id|
        if opportunity.questions.where(form_field_id: question_id).blank?
          apply_missing_questions << opportunity.id
        end
      end
    end
    # apply_missing_questions.count
    puts "Extra Questions Count:        #{@extra_question_ids.count}"
    puts "Missing Auto-Match Questions: #{automatch_missing_questions.count}"
    puts "Missing Apply-To Questions:   #{apply_missing_questions.count}"
  end
  # end check

  # check how many already exist:
  def existing_grid_config_count
    puts "Existing Grid Configurations: #{GridConfiguration.where(model_type: "Opportunity").where(context: "reviewer_chair_applications").where(name: @sample_grid_name).count}"
  end

  def filtering_on_category
    # check if this config is filtering on category:
    messages = []
    parsed_settings = JSON.parse(@view_to_copy.settings)
    parsed_settings["filters"].each do |filter|
      messages << "Filtering on Category!" if filter["field"] == "category_id"
    end
    puts "Filtering on Category: #{messages.count}"
  end

end

# load opportunities with the target opportunities the grid will be applied to
opportunities = Opportunity::Encumberable.not_archived; nil

skipped = []
updated = []
opportunities.each do |opportunity|
  next if opportunity.blank?
  if GridConfiguration.where(model_id: opportunity.id, model_type: model_type, context: context, name: sample_grid_name).exists?
    skipped << opportunity.id
  else
    new_config = view_to_copy.dup
    new_config.model_id = opportunity.id
    # new_config.save!

    # this will save the new view as the default view:
    default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: model_type, model_id: opportunity.id, context: context)
    default_grid_configuration.grid_configuration_id = new_config.id
    # default_grid_configuration.save!

    updated << opportunity.id
  end
end

# Add GridConfig to Portfolios for use on Opportunity::Renewal

# Scopes where you want the new GridConfiguration to be DefaultGridConfiguration
scope_ids = [7]
scopes = Scope.where(id: scope_ids) 

# Grab all portfolios with renewals
portfolios = Portfolio::Scholarship.select {|portfolio| portfolio.renews?}

updated = []
skipped = []
default_grid_changed = []
portfolios.each do |portfolio|
  if GridConfiguration.where(model_id: portfolio.id, name: view_to_copy.name).exists?
    skipped << portfolio.id
  else
    new_config = view_to_copy.dup
    new_config.model_id = portfolio.id
    # new_config.save!
    updated << portfolio.id

    # this will save the new view as the default view:
    if scopes.any? {|scope| portfolio.scopes.include?(scope)}
      default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: "Portfolio", model_id: portfolio.id, context: )
      default_grid_configuration.grid_configuration_id = new_config.id
      # default_grid_configuration.save!
      default_grid_changed << portfolio.id
    end
  end
end

# This works by scope. If the grid view is already present by name, it is removed and the new version is added. 
# New grid view is set to default.
Client.set "XXXX"

sample_opportunity_id = 4141
sample_grid_name = "COBE"
view_to_copy = GridConfiguration.where(model_id: sample_opportunity_id, model_type: "Opportunity", context: "applications", name: sample_grid_name).first

scopes = [3, 92, 94, 99, 100, 95, 96]
updated = []
skipped = []
# destroyed = []
# updated_after_destroy = []
Scope.find(scopes).each do |scope|
  scope.opportunities.encumberable.not_archived.find_each do |opportunity|
    if GridConfiguration.where(model_id: opportunity.id, name: view_to_copy.name).exists?
      # grid_to_delete = GridConfiguration.where(model_id: opportunity.id, model_type: "Opportunity", context: "applications", name: sample_grid_name).first
      # unless grid_to_delete.blank?
      #   destroyed << grid_to_delete
      #   grid_to_delete.destroy
      # end
      # create_new_grid_and_set_as_default(opportunity, view_to_copy)
      # updated_after_destroy << opportunity.id
      skipped << opportunity.id
    else    
      create_new_grid_and_set_as_default(opportunity, view_to_copy)
      updated << opportunity.id
    end
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
  default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: "Opportunity", model_id: opportunity.id, context: "applications")
  default_grid_configuration.grid_configuration_id = new_config.id
  default_grid_configuration.save!
end
