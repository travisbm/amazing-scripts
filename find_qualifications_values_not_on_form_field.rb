report = []

date = DateTime.parse("april 28th 2017")

Client.on_each do |client|
	Opportunity.not_archived.joins(:qualifications).merge(Qualification.where("qualifications.updated_at >= ?", date)).each do |opportunity|
		opportunity.qualifications.each do |qualification|
			diff = qualification.values - qualification.form_field.values
			if qualification.form_field.type == "TextFormField" 
				next unless qualification.values.count > 1
				report << [client, opportunity.id, qualification.created_at, qualification.id, qualification.values, qualification.form_field.id, qualification.form_field.label, qualification.form_field.values]
			elsif not diff.empty?
				next if diff == ["__"]
				report << [client, opportunity.id, qualification.created_at, qualification.id, qualification.values, qualification.form_field.id, qualification.form_field.label, qualification.form_field.values]
			end
		end
	end
end

headers = %w(client opportunity_id qualification_created_at qualification_id qualification_values form_field_id form_field_label form_field_values)

report.easy_csv("global_bad_quals", headers, {direct_upload: false})



 Opportunity.not_archived.joins(:qualification_groups).merge(QualificationGroup.where("qualification_groups.created_at >= ?", date))