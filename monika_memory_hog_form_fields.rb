Client.set "uab"

path = "client/1489755936/memory_hog_ffs_2017Mar09.csv"

s3_object = Datastores::S3.new(path)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

report = []
import_array.each do |row|

	Client.set "#{row["client"]}"
	form_field = FormField.find(row["ff_id"])
	qualifications = Qualification.where(form_field_id: form_field.id)

	qualifications.each do |qualification|
		report_row = []
		report_row << row["client"]
		report_row << form_field.id
		report_row << form_field.label
		report_row << form_field.values.count
		report_row << qualification.id
		report_row << qualification.comparison
		
		value_row = []
		qualification.values.each do |value|			value_row << value	
		end

		report_row << value_row
		report_row << qualification.qualification_group_id
		report_row << qualification.created_at
		report_row << qualification.updated_at
		
		report << report_row
	end
end

headers = %w(client form_field_id form_field_label form_field_values_count qualification_id qualification_label qualification_values qualification_group_id qualification_created_at qualification_updated_at)

report.easy_csv("memory_hog_qualifications", headers, {direct_upload: false})
