# Set the client
Client.set "utah"

# Set a user_id to be attached to each new note.
note_user_id = 34

# Use Support.file_list to get file name and set variable below
# Support.file_list

# Set path to the clients CSV file
file_name = "client/1455554998/utah_business_portfolio_notes.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

# Array to keep track of Objects that have been updated.
updated = []

# Go through each line of the imported array and assign needed atributes.
import_array.each do |row|
  opportunity_id = row["Opportunity Id"]

  opportunity = Opportunity.find(opportunity_id)
  portfolio   = opportunity.portfolio

  # Add each note from the provided opportunity to the provided portfolio
  opportunity.notes.each do |note|
    note = Note.create!(user_id: note_user_id, comment: note.comment)
    portfolio.notes << note
  end

  # Save the porfolio and add it to the updated array.
  #portfolio.save!
  updated << portfolio
end
