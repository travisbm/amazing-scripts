group = Reviewer::Group.find(413)

reviews = group.reviews

report = []
reviews.each do |review|
  applicant_name = review.applicant_application.user.name
  reviewer_name = review.reviewer_application.user.name
  raw_score = review.reviewer_application.evaluation_data["raw_score"]
  weighted_score = review.reviewer_application.evaluation_data["weighted_score"]
  answers = review.reviewer_application.answers

  answers.each do |answer|
    question = answer.form_field.label
    reviewer_answer = answer.attributes["result"]

     row = [applicant_name, reviewer_name, question, reviewer_answer, raw_score, weighted_score]
     report << row
  end
end

headers = %w(applicant_name reviewer_name question answer raw_score weighted_score)

report.easy_csv("archived_reviewer_group_report", headers, {direct_upload: false})