Client.set "csulb"

#grid_configurations = GridConfiguration.where(type: "GridConfiguration::Client")
grid_configurations = GridConfiguration.where(type: "GridConfiguration::Client").order("model_type")
report = []

grid_configurations.each do |grid|
  row = []

  row << grid.id
  row << grid.name
  row << grid.model_type
  row << grid.model_id
  row << grid.context

  report << row
end

headers = %w(id name model_name model_id context)

report.easy_csv("grid_configuration_report", headers, {direct_upload: false})
