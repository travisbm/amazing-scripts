Client.set 'seattleu'

# Set path to the clients CSV file
file_name = "client/1484092716/SeattleU SFS Scope.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)


# A way to do it with a list of id's, possibly from a csv
opportunity_ids = []

import_array.each do |row|
	opportunity_ids << row["Id"]
end

opps_changed = []
opportunity_ids.each do |id|
	opportunity = Opportunity.find(id)
	
	next if opportunity.archived?
	
	opps_changed << opportunity 
	opportunity.allow_drafted = true
	opportunity.save!
end