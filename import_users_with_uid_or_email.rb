# This was used to import users who had a uid or email in the system.
# The users records are pulled from an import file.
# This was originally used to import users after an import failed during implementation,
# client was switched to Shibboleth from local before the import was fully processed

import_answer_file = Import::Answer::File.find(37)

records = Import::Answer::Record.where(import_answer_file: import_answer_file).joins("JOIN users ON users.customer_uid = import_answer_records.customer_uid OR users.email = import_answer_records.email")

records.each do |record|
    record.import!
end

# Find profile applications that might have been made with just a customer_uid value
# could be users who logged in and don't have a matching uid in the system
email_nil = Application::Profile.where("applications.created_at > ?", Date.today - 2.days).joins(:user).merge(User.where(email: nil)).count
