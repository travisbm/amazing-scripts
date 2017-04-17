sample_opportunity_id        = 1616

sample_grid_name             = "Basic ENGR view for Reviewers Chairs"
model_type                   = "Opportunity"
context                      = "reviewer_chair_applications"
view_to_copy                 = GridConfiguration.where(model_id: sample_opportunity_id, model_type: model_type, context: context, name: sample_grid_name).first
sample_opportunity           = Opportunity.find(sample_opportunity_id); nil
profile_opportunity          = Opportunity::Profile.current; nil

def get_grid_configuration_form_field_ids
	settings = JSON.parse(view_to_copy.settings)["visible_columns"]

	form_field_ids = []
	settings.each do |setting|
		string = setting["id"]

		form_field_ids << string.sub("form_field_", "").to_i if string.include?("form_field_")
	end

	form_field_ids
end

def check_extra_questions_on_opps_in_scope 
    scoped_opportunities = Scope.find(scope_id).opportunities.not_archived.where(type: "Opportunity::Automatch")
    a = sample_opportunity_form_field_ids

    extra_form_field_ids = []
    scoped_opportunities.each do |opportunity|
      b = opportunity.questions.map(&:form_field_id)
      extra_form_field_ids.push *( a - b | b - a )
    end
    extra_form_field_ids.uniq!

	puts "Profile Opportunity question count        | #{profile_opportunity_form_field_ids.count}"
    puts "Sample Opportunity question count         | #{sample_opportunity_form_field_ids.count}"
    puts "Questions not on the scoped opportunities | #{extra_form_field_ids}"
end

def check_if_grid_works_with_scoped_opportunities
	opportunity_ids_not_compatible = []
	opportunity_ids_compatible     = []
	sample_opportunity_form_field_ids = sample_opportunity.questions.map(&:form_field_id); nil

	target_opportunities.each do |opportunity|
		target_opportunity_form_field_ids = opportunity.questions.map(&:form_field_id)

		if (form_field_ids - target_opportunity_form_field_ids).empty?
			opportunity_ids_compatible << opportunity.id
		else
			opportunity_ids_not_compatible << opportunity.id
		end
	end
end

end

# Run these to check if grid view will work for a set of scoped opportunities
find_extra_questions(profile_opportunity, sample_opportunity, scope_id)
existing_grid_config_count(model_type, context, sample_grid_name)
filtering_on_category?(view_to_copy)