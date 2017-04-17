Client.set ""

reviewers = Reviewer::GroupMember.order(:user_id)

report = []

reviewers.group_by(&:user_id).each do |user_id, groups|
  row = []
  row << User.find(user_id).name
  row << User.find(user_id).email

  groups.each do |group|

    if groups.count == 1
      group_name = "No Groups Assigned"
    else
      group_name = Reviewer::Group.find(group.reviewer_group_id).name

      next if group_name == "Reviewer Group Template"

    end

    row << group_name
    row << group.role

    report << row
    row = ["", ""]
  end

end

headers = %w(name email review_group reviewer_role)

report.easy_csv("reviewer_report", headers, {direct_upload: false})

