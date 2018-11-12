sample_opportunity_id = 458	
sample_grid_name = "Qualified"
target_opportunity_ids = Opportunity::Encumberable.not_archived.map(&:id); nil
default = true

cloner = Support::GridConfigurationCloner.new(sample_opportunity_id, sample_grid_name, target_opportunity_ids, default)

module Support
	class GridConfigurationCloner
		MODEL_TYPE = "Opportunity"
		CONTEXT    = "applications"

		attr_reader :view_to_copy, :view_to_copy_form_field_ids, :opportunity_ids_compatible, :opportunity_ids_not_compatible

		def initialize(sample_opportunity_id, sample_grid_name, target_opportunity_ids, default)
			@sample_opportunity     = Opportunity.find(sample_opportunity_id)
			@view_to_copy           = GridConfiguration.where(model_id: sample_opportunity_id, model_type: MODEL_TYPE, context: CONTEXT, name: sample_grid_name).first
			@target_opportunity_ids = target_opportunity_ids 
			@default                = default
			@view_to_copy_form_field_ids    = []
			@opportunity_ids_compatible     = []
			@opportunity_ids_not_compatible = []
		end

		def call
			check_if_grid_works_with_target_opportunities
			report
			copy_to_compatible_target_opportunities if copy_to_compatible_opportunities?
		end

		def self.clone!(sample_opportunity_id, sample_grid_name, target_opportunity_ids, default)
			Support::GridConfigurationCloner.new(sample_opportunity_id, sample_grid_name, target_opportunity_ids, default).call
		end

		def self.help
			puts "---\nAVAILABLE METHODS\n\n" + 

			"Support::GridConfigurationCloner.clone!(sample_opportunity_id, sample_grid_name, target_opportunity_ids, default)\n\n" + 

			"Parameters:\n" +
			"sample_opportunity_id  - The id of the opportunity where the grid view to clone is saved.\n" + 
			"sample_grid_name       - The name of the grid to clone. sample_grid_name = 'My Grid View'\n" + 
			"target_opportunity_ids - Array of opportunity ids the grid view will be cloned to.\n" + 
			"default                - Should the grid view be the default view? true/false\n\n" + 

			"TARGET OPPORTUNITY TEMPLATES (Copy text below into editor and modify)\n\n" +

			"# apply to opportunities by id\n" +
			"target_opportunity_ids = [1, 2, 3]\n\n" +

			"# apply to ALL not_archived opportunities\n" +
			"target_opportunity_ids = Opportunity::Encumberable.not_archived.pluck(:id); nil\n\n" +

			"# apply to opportunities by scope\n" +
			"scope_ids = [1, 2, 3]\n" +
			"target_opportunity_ids = []\n" +
			"scope_ids.each do |id|\n" +
			"   target_opportunity_ids << Scope.find(id).opportunities.encumberable.not_archived.pluck(:id)\n" +
			"   target_opportunity_ids.flatten!\n" +
			"end; nil\n\n" +

			"# Set these\n" + 
			"sample_opportunity_id = 1234\n" +
			"sample_grid_name      = 'My Grid View'\n" +
			"default               = false\n" +
			"---\n" +
			"SET PARAMETERS ABOVE, THEN COPY AND CALL METHOD BELOW (You will be provided a report and a prompt before cloning.)\n\n" +  

			"Support::GridConfigurationCloner.clone!(sample_opportunity_id, sample_grid_name, target_opportunity_ids, default)\n\n" + 
			"---"
		end

		def get_target_opportunities
			Opportunity.find(@target_opportunity_ids)
		end

		def gated_by_conditional?
			!!@sample_opportunity.conditional_portfolio_id
		end

		def copy_to_compatible_opportunities?
			puts "Do you want to apply #{@view_to_copy.name} to the compatible opportunities? (Y/N)"
			response = gets.chomp
			return true if response.in?(["Y", "Yes", "YES", "yes", "y"])
			return false
		end

		def report
			puts "Sample opportunity type                       | #{@sample_opportunity.type}"
			puts "Sample Opportunity question count             | #{@sample_opportunity.questions.count}"
			puts "Profile Opportunity question count            | #{Opportunity::Profile.current.questions.count}"
			puts "Question ids not on the profile opportunity   | #{find_sample_opportunity_questions_not_on_profile}"
			puts ""
			if @sample_opportunity.conditional?
				puts "THIS IS A CONDITIONAL OPPORTUNITY"
				puts ""
				puts "Conditional question count                    | #{@sample_opportunity.questions.count}"
				puts "Conditional question ids                      | #{find_conditional_opportunity_questions_not_on_profile}"
				puts "Grid view contains conditional columns?       | #{@view_to_copy_form_field_ids.include?(find_conditional_opportunity_questions_not_on_profile)}"
				puts ""
			elsif gated_by_conditional?
				puts "THIS OPPORTUNITY IS GATED BY A CONDITIONAL"
				puts ""
				puts "Conditional Opportunity question count        | #{@sample_opportunity.conditional_opportunity.questions.count}"
				puts "Conditional question ids                      | #{find_conditional_opportunity_questions_not_on_profile}"
				puts "Grid view contains conditional columns?       | #{@view_to_copy_form_field_ids.include?(find_conditional_opportunity_questions_not_on_profile)}"
				puts ""
			elsif @sample_opportunity.apply? 
				puts "THIS IS AN APPLY-TO OPPORTUNITY"
				puts ""
				puts "Apply-to question count                       | #{find_apply_to_questions_not_on_profile.count}"
				puts "Apply-to question ids                         | #{find_apply_to_questions_not_on_profile}"
				puts "Grid view contains apply-to columns?          | #{@view_to_copy_form_field_ids.include?(find_apply_to_questions_not_on_profile)}"
				puts ""
			end
			puts "Existing grid config count                    | #{existing_grid_config_count}"
			puts "Filtering on category?                        | #{filtering_on_category?}"
			puts "Target types match sample opportunity type?   | #{target_opportunity_and_sample_opportunity_types_match}"
			puts "Target opportunities count                    | #{get_target_opportunities.count}"
			puts "Compatible count                              | #{@opportunity_ids_compatible.count}"
			puts "Not Compatible count                          | #{@opportunity_ids_not_compatible.count}"
			puts "Compatible opps where grid view name present  | #{count_of_compatible_opportunities_with_view_to_copy_present}"
			puts ""
			puts "Number of compatible opportunities the grid view will be applied to: #{(@opportunity_ids_compatible - [@sample_opportunity.id]).count}"
			puts ""
			puts ""
		end

		def count_of_compatible_opportunities_with_view_to_copy_present
			count = 0
			Opportunity.where(id: @opportunity_ids_compatible).find_each do |opportunity|
				count += 1 if GridConfiguration.where(model_id: opportunity.id, name: @view_to_copy.name).exists?
			end
			count
		end

		def get_grid_configuration_form_field_ids
			settings = JSON.parse(@view_to_copy.settings)["visible_columns"]

			settings.each do |setting|
				string = setting["id"]

				@view_to_copy_form_field_ids << string.sub("form_field_", "").to_i if string.include?("form_field_")
			end
		end

		def check_if_grid_works_with_target_opportunities
			get_grid_configuration_form_field_ids

			get_target_opportunities.each do |opportunity|
			next if opportunity.equal? @sample_opportunity
			target_opportunity_form_field_ids = opportunity.questions.map(&:form_field_id)
			difference_in_form_field_ids = @view_to_copy_form_field_ids - target_opportunity_form_field_ids
			if difference_in_form_field_ids.empty?
				@opportunity_ids_compatible << opportunity.id
			else
				@opportunity_ids_not_compatible << [opportunity.id, opportunity.portfolio.name, difference_in_form_field_ids]
			end
		end
		end

		def find_apply_to_questions_not_on_profile
			if @sample_opportunity.conditional?
				find_sample_opportunity_questions_not_on_profile - find_conditional_opportunity_questions_not_on_profile
			else
				find_sample_opportunity_questions_not_on_profile
			end
		end

		def find_conditional_opportunity_questions_not_on_profile
			if @sample_opportunity.conditional?
				conditional_opportunity_form_field_ids = @sample_opportunity.questions.map(&:form_field_id)
			else
				conditional_opportunity_form_field_ids = @sample_opportunity.conditional_opportunity.questions.map(&:form_field_id)
			end

			conditional_opportunity_form_field_ids - Opportunity::Profile.current.questions.map(&:form_field_id)
		end

		def find_sample_opportunity_questions_not_on_profile
			sample_opportunity_form_field_ids  = @sample_opportunity.questions.map(&:form_field_id)

			sample_opportunity_form_field_ids - Opportunity::Profile.current.questions.map(&:form_field_id)
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

		def target_opportunity_and_sample_opportunity_types_match
			get_target_opportunities.all? {|opportunity| opportunity.type == @sample_opportunity.type}
		end

		# Default right now is to destroy grid views of the same name on each opportunity and add the new one.
		def copy_to_compatible_target_opportunities
			destroyed = []
			updated   = []
			Opportunity.where(id: @opportunity_ids_compatible).find_each do |opportunity|
				next if opportunity.blank? || opportunity.id == @view_to_copy.model_id
				if GridConfiguration.where(model_id: opportunity.id, name: @view_to_copy.name).exists?
					grid_to_delete = GridConfiguration.where(model_id: opportunity.id, model_type: MODEL_TYPE, context: CONTEXT, name: @view_to_copy.name).first
					unless grid_to_delete.blank?
						destroyed << grid_to_delete.id
						grid_to_delete.destroy
					end
				end
				new_config = @view_to_copy.dup
				new_config.model_id = opportunity.id
				new_config.save!

				if @default
			        # this will save the new view as the default view:
			        default_grid_configuration = DefaultGridConfiguration.find_or_initialize_by(model_type: MODEL_TYPE, model_id: opportunity.id, context: CONTEXT)
			        default_grid_configuration.grid_configuration_id = new_config.id
			        default_grid_configuration.save!
			    end

			    updated << opportunity.id
			end
			puts "destroyed: #{destroyed.count}"
			puts "updated: #{updated.count}"
		end
	end
end
