# Please add the question "Notes" (ID 10612) as an Administrator question to all Opportunities in the following scopes:

# S.A.D. 
# Endowment Fund 
# Alumni Association 
# NC State Foundation 
# Partial NC State Foundation

# Please have this field marked as "RESTRICTED" for all these instances.

# To make it a little easier, I've attached a file in the customer's FILES section entitled "47252_NCSU_OppsIDs.csv". 
# This file contains the Opp IDs for all non-archived opportunities in these scopes so you don't have to mine for them. 

Client.set 'ncsu'

file_name = "client/1484884639/47252_NCSU_OppsIDs.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

opportunity_ids = []

import_array.each do |row|
	opportunity_ids << row["Id"]
end

skipped =[]
skipped_ff = []
skipped_ff_set = []
updated = []

opportunity_sample = Opportunity.find(70533)

opportunity_ids.each do |opportunity_id|
  opportunity = Opportunity.find(opportunity_id)
  next if opportunity == opportunity_sample

  opportunity_sample.questions.specific.not_set.find_each do |sample_question|
    if opportunity.questions.specific.map(&:form_field_id).include?(sample_question.form_field_id)
      skipped << opportunity.id unless skipped.include?(opportunity.id)
      skipped_ff << sample_question.form_field_id unless skipped_ff.include?(sample_question.form_field_id)
    else
      question = opportunity.question(sample_question.form_field)
      question.required = sample_question.required
      question.position = sample_question.position
    end
  end
  opportunity_sample.question_sets.specific.find_each do |sample_question_set|
    if opportunity.question_sets.specific.map(&:form_field_set_id).include?(sample_question_set.form_field_set_id)
      skipped << opportunity.id unless skipped.include?(opportunity.id)
      skipped_ff_set << sample_question_set.form_field_set_id unless skipped_ff_set.include?(sample_question_set.form_field_set_id)
    else
      question_set = opportunity.question_set(sample_question_set.form_field_set)
      question_set.required = sample_question_set.required
      question_set.position = sample_question_set.position
      question_set.min_questions = sample_question_set.min_questions
      question_set.max_questions = sample_question_set.max_questions
    end
  end
  opportunity.save!
  updated << opportunity.id
end

updated.count
skipped.count
skipped_ff.count
skipped_ff_set.count