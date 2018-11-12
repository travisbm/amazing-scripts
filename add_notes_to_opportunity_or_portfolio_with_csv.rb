# 
# Move Opportunity Notes to the Opportunities Portfolio
#

# Set the client
Client.set "utah"

# Set a user_id to be attached to each new note.
note_user_id = 40286

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
  opportunity_id = row["Id"]
  note = row["Notes"]

  opportunity = Opportunity.find(opportunity_id)
  note = Note.create!(user_id: note_user_id, )

  # Add each note from the provided opportunity to the provided portfolio
  opportunity.notes.each do |note|
    note = Note.create!(user_id: note_user_id, comment: note.comment)
    portfolio.notes << note
  end

  # Save the porfolio and add it to the updated array.
  #portfolio.save!
  updated << portfolio
end

#
# Add Notes to Opportunities
#

Client.set "schoolymcschoolface"

Support.file_list

file_name = "client/1539724625/College of Engineering Opportunity NOTES_EL.csv"

s3_object = Datastores::S3.new(file_name)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

updated = []
already_done = []

import_array.each do |row|
  id = row["Id"]
  note_user_id = 40286
  note = row["Notes"]

  next if note.blank?

  opportunity = Opportunity.find(id)

  if updated.include?(opportunity)
    already_done << opportunity
  else
    opportunity.notes << Note.new(user_id: note_user_id, comment: note)
    # opportunity.save!
    updated << opportunity
  end
end

#
# Add Notes to Portfolios
#

Client.set "SchoolyMcSchoolFace"

Support.file_list

file_name = "client/1540308966/College of Engineering Opportunity NOTES (1).csv"

s3_object = Datastores::S3.new(file_name)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

updated = []

import_array.each do |row|
  id = row["portfolio_id"]
  note_user_id = 353383
  note = row["Notes"]

  next if note.blank?

  portfolio = Portfolio.find(id)
  note = Note.new(user_id: note_user_id, comment: note)

  portfolio.notes << note
  portfolio.save!

  updated << portfolio
end

#
# Add Notes to Opportunity with a given note
# 

updated = []

comment = "Account_Fund_Program_Org_Project/Grant\n\n(Example: 5711_233_9_123456_PRJ1234)"
note_user_id = 70

opportunities = Opportunity.not_archived.where(type: ["Opportunity::Automatch", "Opportunity::Apply", "Opportunity::Renewal"])

opportunities.each do |opportunity|
  note = Note.new(user_id: note_user_id, comment: comment)

  opportunity.notes << note
  opportunity.save!

  updated << opportunity
end

# note count 1366
# opportunities count 4411