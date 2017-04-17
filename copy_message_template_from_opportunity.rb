file_name = "client/1491230684/custom offer email update-Table.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

deliver_when   = "approve"
subject         = "Required Thank You Letter(s) for your Eccles School Admissions Scholarship"
body            =  MessageTemplate.where(name: "offer", delivery_method: "email", opportunity_id: 3163).first.body

updated = []
opportunity_ids.each do |opportunity_id|
	 
	message_template = MessageTemplate.where(name: "offer", delivery_method: "email", opportunity_id: opportunity_id).first

	message_template.deliver_when = deliver_when
	message_template.subject = subject
	message_template.body = body
	message_template.save!

	updated << opportunity_id
end

