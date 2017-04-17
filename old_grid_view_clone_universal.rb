# apply to opportunities by id
opportunity_ids = [1, 2, 3]
target_opportunities = Opportunity::Encumberable.not_archived.where(id: [opportunity_ids])

# apply to ALL not_archived opportunities
target_opportunities = Opportunity::Encumberable.not_archived

# apply to opportunities by scope
scope_ids = [1, 2, 3]
target_opportunities = []
scope_ids.each do |id|
  target_opportunities = Scope.find(id).opportunities.encumberable.not_archived
end

sample_opportunity_id = 1234
sample_grid_name      = "My Grid View"

# use this call in console 
copy = GridViewClone.new(sample_opportunity_id, sample_grid_name, target_opportunities); nil

class GridViewClone

  MODEL_TYPE = "Opportunity"
  CONTEXT    = "applications"

  attr_reader :view_to_copy, :view_to_copy_form_field_ids, :opportunity_ids_compatible, :opportunity_ids_not_compatible

  def initialize(sample_opportunity_id, sample_grid_name, target_opportunities)
    @sample_opportunity   = Opportunity.find(sample_opportunity_id)
    @profile_opportunity  = Opportunity::Profile.current
    @view_to_copy         = GridConfiguration.where(model_id: sample_opportunity_id, model_type: MODEL_TYPE, context: CONTEXT, name: sample_grid_name).first
    @extra_form_field_ids = []
    @view_to_copy_form_field_ids = []
    @opportunity_ids_compatible = []
    @opportunity_ids_not_compatible = []
    @target_opportunities = target_opportunities
  end

  def call
    report
    get_grid_configuration_form_field_ids
    check_if_grid_works_with_scoped_opportunities
  end

  def apply_anywhere?
    @sample_opportunity.automatch? && !gated_by_conditional? && !admin_questions?
  end

  def admin_questions?
    @sample_opportunity.form_fields.where(asked_to: "administrator").any?
  end

  # is this a dangerous way to return boolean?
  def gated_by_conditional?
    !!@sample_opportunity.conditional_portfolio_id
  end

  def report
    puts "Profile Opportunity question count        | #{@profile_opportunity.questions.count}"
    puts "Sample Opportunity question count         | #{@sample_opportunity.questions.count}"
    puts "Questions not on the profile opportunity  | #{find_extra_questions}"
    puts "Existing grid config count                | #{existing_grid_config_count}"
    puts "Filtering on category?                    | #{filtering_on_category?}"
  end

  def get_grid_configuration_form_field_ids
    settings = JSON.parse(@view_to_copy.settings)["visible_columns"]

    settings.each do |setting|
      string = setting["id"]

      @view_to_copy_form_field_ids << string.sub("form_field_", "").to_i if string.include?("form_field_")
    end
  end

  def check_if_grid_works_with_target_opportunities
    @target_opportunities.each do |opportunity|
      target_opportunity_form_field_ids = opportunity.questions.map(&:form_field_id)

      difference_in_form_field_ids = @view_to_copy_form_field_ids - target_opportunity_form_field_ids

      if difference_in_form_field_ids.empty?
        @opportunity_ids_compatible << opportunity.id
      else
        @opportunity_ids_not_compatible << [opportunity.id, opportunity.portfolio.name, difference_in_form_field_ids]
      end
    end

    puts "Compatible count:    | #{@opportunity_ids_compatible.count}"
    puts "Not Compatible count | #{@opportunity_ids_not_compatible.count}"
  end

  def find_extra_questions
    profile_opportunity_form_field_ids = @profile_opportunity.questions.map(&:form_field_id)
    sample_opportunity_form_field_ids  = @sample_opportunity.questions.map(&:form_field_id)

    @extra_form_field_ids.push *(sample_opportunity_form_field_ids - profile_opportunity_form_field_ids)
  end

  def automatch_missing_questions
    missing_questions = []
    Opportunity::Automatch.not_archived.find_each do |opportunity|
      @extra_form_field_ids.each do |question_id|
        if opportunity.questions.where(form_field_id: question_id).blank?
          missing_questions << [opportunity.id, question_id]
        end
      end
    end
    missing_questions
  end

  def apply_missing_questions
    missing_questions = []
    Opportunity::Apply.not_archived.find_each do |opportunity|
      @extra_form_field_ids.each do |question_id|
        if opportunity.questions.where(form_field_id: question_id).blank?
          missing_questions << [opportunity.id, question_id]
        end
      end
    end
    missing_questions
  end

  # check how many existing GridConfigurations of this type
  def existing_grid_config_count
    GridConfiguration.where(model_type: MODEL_TYPE, context: CONTEXT, name: @view_to_copy.name).count
  end

  # check if the GridConfiguration is filtering on category
  def filtering_on_category?
    messages = []
    parsed_settings = JSON.parse(@view_to_copy.settings)
    parsed_settings["filters"].each do |filter|
      messages << "Filtering on Category!" if filter["field"] == "category_id"
    end
    messages.empty? ? false : true
  end

  def copy_to_compatible_target_opportunities
    skipped = []
    updated = []
    Opportunity.where(id: @opportunity_ids_compatible).find_each do |opportunity|
      next if opportunity.blank?
      if GridConfiguration.where(model_id: opportunity.id, name: @view_to_copy.name).exists?
        skipped << opportunity.id
      else
        new_config = @view_to_copy.dup
        new_config.model_id = opportunity.id
        new_config.save!

        # this will save the new view as the default view:
        default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: MODEL_TYPE, model_id: opportunity.id, context: CONTEXT)
        default_grid_configuration.grid_configuration_id = new_config.id
        default_grid_configuration.save!

        updated << opportunity.id
      end
    end

    puts "skipped: #{skipped.count}"
    puts "updated: #{updated.count}"
  end

end

# Run these to check if grid view will work for other encumberable opportunities.
find_extra_questions(profile_opportunity, sample_opportunity)
existing_grid_config_count(model_type, context, sample_grid_name)
filtering_on_category?(view_to_copy)


# below are different ways to apply the sample opportunity grid view to other opportunities

# load opportunities with the target opportunities the grid will be applied to
opportunities = Opportunity::Encumberable.not_archived

skipped = []
updated = []
opportunities.each do |opportunity|
  next if opportunity.blank?
  if GridConfiguration.where(model_id: opportunity.id, name: view_to_copy.name).exists?
    skipped << opportunity.id
  else
    new_config = view_to_copy.dup
    new_config.model_id = opportunity.id
    # new_config.save!

    # this will save the new view as the default view:
    default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: model_type, model_id: opportunity.id, context: CONTEXT)
    default_grid_configuration.grid_configuration_id = new_config.id
    # default_grid_configuration.save!

    updated << opportunity.id
  end
end

# Update by scope
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
      default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: model_type, model_id: opportunity.id, context: CONTEXT)
      default_grid_configuration.grid_configuration_id = new_config.id
      #default_grid_configuration.save!
    end
  end
end

# If the grid view is already present by name, it is removed and the new version is added. 
# New grid view is set to default.
opportunities = Opportunity::Encumberable.not_archived

updated = []
destroyed = []

opportunities.each do |opportunity|
  if GridConfiguration.where(model_id: opportunity.id, name: view_to_copy.name).exists?
    grid_to_delete = GridConfiguration.where(model_id: opportunity.id, model_type: model_type, context: CONTEXT, name: sample_grid_name).first
    unless grid_to_delete.blank?
      destroyed << grid_to_delete
      # grid_to_delete.destroy
    end
  end    
  new_config = view_to_copy.dup
  new_config.model_id = opportunity.id
  # new_config.save!

  # this will save the new view as the default view:
  default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: model_type, model_id: opportunity.id, context: CONTEXT)
  default_grid_configuration.grid_configuration_id = new_config.id
  # default_grid_configuration.save!
  updated << opportunity.id
end


# These can be used in different versions of the script above if needed
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








