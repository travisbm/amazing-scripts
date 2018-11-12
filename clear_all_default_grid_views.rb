ids = Opportunity.encumberable.not_archived.ids; nil

DefaultGridConfiguration.where(model_id: ids).each do |default_grid_configuration|
	default_grid_configuration.destroy!
end