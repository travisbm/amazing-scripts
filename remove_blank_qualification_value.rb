Client.set 'travis'
# Set path to the clients CSV file
file_name = "client/1486480167/bad_quals.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

# Delete qualifications with the 'rogue' underscore from the bad_quals report

def must_include_with_underscore(qualification)
  qualification.values.include?("__") && qualification.comparison == "=~"
end

def report_row(client, qualification)
  [client, qualification.opportunity.id, qualification.id, qualification.comparison, qualification.values.join(" | ")]
end

updated   = []
skipped   = []
solo_qual = []
import_array.each do |row|
  Client.set "#{row['Shard']}"
  begin
    qualification = Qualification.find(row["Qualification ID"])
    if qualification.opportunity.archived?
      skipped << report_row(Client.current, qualification)
    elsif must_include_with_underscore(qualification)
      if qualification.values.count == 1
        solo_qual << report_row(Client.current, qualification)
        next
      end
      updated << report_row(Client.current, qualification) 
      qualification.values.delete("__") 
      qualification.save!
    end
  rescue ActiveRecord::RecordNotFound
    next
  end
end

headers = %w(client opportunity_id qualification_id qualification_comparison qualification_values)

solo_qual.easy_csv("monika_the_rogue_underscore_hunter", headers, {direct_upload: false})