Client.set 'jwu'

report = []
Portfolio.joins(:notes).distinct.find_each do |portfolio|
  portfolio.notes.each do |note|
    user = User.find(note.user_id)
    
    result = []
    result << portfolio.id
    result << portfolio.name
    result << portfolio.type.sub("Portfolio::", "")
    result << user.id
    result << user.display_name
    result << note.created_at
    result << note.id
    result << note.comment
    report << result
  end
end

headers = %w(portfolio_id portfolio_name portfolio_type user_id user_name created_at note_id note)

report.easy_csv("portfolio_notes", headers, {direct_upload: false})



report = []
Opportunity::Scholarship.joins(:notes).distinct.not_archived.find_each do |opportunity|
  opportunity.notes.each do |note|
    user = User.find(note.user_id)

    result = []
    result << opportunity.id
    result << opportunity.portfolio.name
    result << opportunity.type.sub("Opportunity::", "")
    result << user.id
    result << user.display_name
    result << note.created_at
    result << note.id
    result << note.comment
    report << result
  end
end

headers = %w(opportunity_id opportunity_name opportunity_type user_id user_name created_at note_id note)

report.easy_csv("opportunity_notes", headers, {direct_upload: false})
