# report from specific time frame pulled from history
report = []

Portfolio.all.each do |portfolio|
    row = []

    row << portfolio.id
    row << portfolio.name

    code_history = auxiliary_code_history(portfolio)
    id_history   = project_id_history(portfolio)

    if code_history.present? && id_history.present?
        next if code_history["changes"]["auxiliary_code"].all? { |c| c.blank? } && id_history["changes"]["project_id"].all? { |c| c.blank? }
        auxiliary_code_report(code_history, row)
        project_id_report(id_history, row)
    elsif code_history.present?
        next if code_history["changes"]["auxiliary_code"].all? { |c| c.blank? }
        auxiliary_code_report(code_history, row)
        empty_row(row)
    elsif id_history.present?
        next if id_history["changes"]["project_id"].all? { |c| c.blank? }
        empty_row(row)
        project_id_report(id_history, row)
    else
        next
    end

    report << row
end

# make a report
headers = %w(portfolio_id portfolio_name previous_auxiliary_code updated_auxiliary_code user_id date_changed previous_project_id updated_project_id user_id date_changed)

report.easy_csv("history_of_portfolio_changes", headers, {direct_upload: false})

# methods
def time_left
    Time.zone.parse('2018-10-22 08:00:00')
end

def time_right
    Time.zone.parse('2018-10-24 15:00:00')
end

def auxiliary_code_history(portfolio)
    portfolio.history.event("update").changes("auxiliary_code").after(time_left).before(time_right).first
end

def project_id_history(portfolio)
    portfolio.history.event("update").changes("project_id").after(time_left).before(time_right).first
end

def auxiliary_code_report(history, row)
    auxiliary_code_date_changed = history["occurred_at"]
    auxiliary_user_id           = history["user_id"]
    auxiliary_code_changes      = history["changes"]["auxiliary_code"]
    auxiliary_code_change_from  = auxiliary_code_changes.first
    auxiliary_change_to         = auxiliary_code_changes.second

    row << auxiliary_code_change_from
    row << auxiliary_change_to
    row << auxiliary_user_id
    row << auxiliary_code_date_changed
end

def project_id_report(history, row)
    project_id_date_changed = history["occurred_at"]
    project_id_user_id      = history["user_id"]
    project_id_changes      = history["changes"]["project_id"]
    project_id_change_from  = project_id_changes.first
    project_id_change_to    = project_id_changes.second

    row << project_id_change_from
    row << project_id_change_to
    row << project_id_user_id
    row << project_id_date_changed
end

def empty_row(row)
    row << ""
    row << ""
    row << ""
    row << ""
end
