admin_created_users = []
report = []

User.where.not(id: [3, 70]).find_each do |user|
  next unless user.applicant?
  
  history_user_create = user.history.create.type("User").first
  user_created_by_id = history_user_create["user_id"]

  next if (user_created_by_id == user.id) || (user_created_by_id == 3) 
    
  admin = User.find(user_created_by_id)
  
  user_id = user.id
  user_name = user.name
  user_email = user.email
  user_uid = user.customer_uid
  admin_id = admin.id
  admin_name = admin.name
  admin_email = admin.email
  admin_uid = admin.customer_uid
  created_at = user.created_at

  row = [user_id, user_name, user_email, user_uid, admin_id, admin_name, admin_email, admin_uid, created_at]
  report << row

end

headers = %w(applicant_id applicant_name applicant_email applicant_customer_uid admin_id admin_name admin_email admin_customer_uid applicant_created_at)

report.easy_csv("admin_created_users", headers, {direct_upload: false})
