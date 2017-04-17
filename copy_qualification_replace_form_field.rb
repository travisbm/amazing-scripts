# On any opportunity using form_field_ID 10075 as a qualifier, clone the group(s) using that
# field and replace that field in the cloned group(s) with form_field_ID 10128.


Client.set "travis"

file_name = "client/1485475956/travis_qualifications_form_field_ 831_2017Jan26_1812.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

opportunity_ids = []
import_array.each do |row|
  opportunity_ids << row["opportunity_id"]
end

opportunity_ids.uniq!

# FormField id's
college_major_1 = 831

college_major_2 = 849
college_major_3 = 850

old_form_field_id = 831
new_form_field_ids = [849, 850]

updated = []
new_qualifications = []
new_qualification_groups = []

new_form_field_ids.each do |new_form_field_id|
  opportunity_ids.each do |opportunity_id|
    opportunity = Opportunity.find(opportunity_id)

    opportunity.qualification_groups.each do |old_qualification_group|
      if old_qualification_group.qualifications.map(&:form_field_id).include? old_form_field_id
      new_qualification_group = QualificationGroup.new
      new_qualification_group.opportunity_id = opportunity.id
      # new_qualification_group.save!
      new_qualification_groups << old_qualification_group.id

      old_qualification_group.qualifications.each do |old_qualification|
        new_qualification = old_qualification.dup
        new_qualification.qualification_group_id = new_qualification_group.id
        new_qualification.created_at = nil
        new_qualification.updated_at = nil

        if new_qualification.form_field_id == old_form_field_id
          new_qualification.form_field_id = new_form_field_id
          new_qualifications << old_qualification.id
        end

        # new_qualification.save!
        end
      end
    end
    updated << opportunity.id
  end
end

