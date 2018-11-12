file = "client/1509983144/BRIDGEW_UIDS_Deactivate.csv"

s3_object = Datastores::S3.new(file)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

report = []

import_array.each do |row|
  customer_uid = row["customer UID"]
  
  new_uid = customer_uid + "_DNU"
  new_email = new_uid + "@student.bridgew.edu"

  user = User.find_by_customer_uid(customer_uid)
  user.customer_uid = new_uid
  user.email = new_email
  user.save!

  report << [user.customer_uid, new_uid, new_email]
end

headers = %w[previous_customer_uid new_customer_uid new_email]

report.easy_csv("changed_customer_uids", headers, {direct_upload: false})