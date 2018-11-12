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



report = []
Client.on_each(Client.metricable_set) do |client|
	FormField.all.each do |form_field|
		next unless form_field.values.count >= 10000
		row = []
		row << client
		row << form_field.id
		row << form_field.label
		row << form_field.values.count
		row << Qualification.where(form_field_id: form_field.id).count
		row << Opportunity.not_archived.joins(:qualifications).merge(Qualification.where(form_field_id: form_field.id)).distinct.count
		row << Qualification.where(form_field_id: form_field.id).select(:values).distinct.inject(0) {|sum, q| sum += q.values.count}
		values = []
		Qualification.where(form_field_id: form_field.id).select(:values).distinct.each do |qualification|
			values << qualification.values
		end
		row << values.flatten
		report << row
	end
end

headers = %w[client form_field_id form_field_label form_field_values_count qualifications_with_form_field_count opportunities_using_qualification_count unique_qualification_values_count unique_qualification_values]

report.easy_csv("rogue_form_fields", headers, {direct_upload: false})
