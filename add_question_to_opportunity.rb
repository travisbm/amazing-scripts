# Add a new question to opportunities

Client.set 'ncsu'

file_name = "client/1484884639/47252_NCSU_OppsIDs.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

# New Question's form_field
form_field = FormField.find(10612)

# Get opportunity id's from a file
opportunity_ids = []
import_array.each do |row|
	opportunity_id = row["Id"]

	opportunity_ids << opportunity_id
end

skipped = []
updated = []
# Add the question to the opportunities
opportunity_ids.each do |id|
	opportunity = Opportunity.find(id)

	if opportunity.questions.specific.map(&:form_field_id).include?(form_field.id)
    	skipped << opportunity.id
  	else
	    question = opportunity.question(form_field)
	    # question.required = sample_question.required
	    # question.position = sample_question.position
	    updated << opportunity.id
	    opportunity.save!
  	end
end