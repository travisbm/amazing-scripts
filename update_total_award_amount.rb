Client.set 'ncsu'

# Set path to the clients CSV file
file_name = "client/1487344672/Update Renewal Opps Available Funds.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

updated = []
import_array.each do |row|
	opportunity = Opportunity.find(row["Renewal Opp ID"])
	new_total   = row["total_award_amount_renewal"]

	opportunity.total_award_amount = new_total
	opportunity.save!
	updated << [opportunity.id, opportunity.total_award_amount]
end