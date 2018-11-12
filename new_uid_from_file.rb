Client.set "colorado"

path = "client/1489758813/Col UID Corrections 03152017.csv"

s3_object = Datastores::S3.new(path)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)


updated = []
skipped = []
import_array.each do |row|

	user = User.find(row["Id"])
	uid  = row["GOOD ID"]

	if User.where(customer_uid: uid).present?
		existing_user_with_uid = User.where(customer_uid: uid).first

		skipped_row = []
		row.each do |data|
			skipped_row << data[1]
		end
		skipped_row << existing_user_with_uid.id
		skipped << skipped_row
	else
		user.customer_uid = uid
		user.save!
		updated << user.id
	end

end


headers = %w(id primary_email display_name roles created_at last_sign_in_at current_sign_in_at sign_in_count bad_id good_id user_id_with_good_id)

skipped.easy_csv("uid_mismatch", headers, {direct_upload: false})


# deactivate user account and move uid to another user account

Client.set "uab"

path = "client/1490217746/dupe_fix_upload_to_AW.csv"

s3_object = Datastores::S3.new(path)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

updated = []
import_array.each do |row|

	user         = User.find(row["UserId#"])
	uid          = row["BLAZERID"]
	display_name = row["Display Name (First and Last Only)"]
	email        = row["UAB Email"]
	new_user     = User.find(row["Account to Merge with"])

	user.customer_uid += "_dnu"

	new_user.customer_uid = uid
	new_user.display_name = display_name
	new_user.email = email

	# user.save!
	# new_user.save!
	updated << [new_user.id, new_user.customer_uid, new_user.display_name, new_user.email]
end


# deactivate uid, email and display name

Client.set "scholarships-idaho"

path = "client/1490645707/inactive_users_to_AW_uploads.csv"

s3_object = Datastores::S3.new(path)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

updated = []
not_updated = []
import_array.each do |row|

	user = User.where(email: row["email"]).first
	if user.blank?
		not_updated << [row["email"], row["customer_uid"]]
	else
		user.display_name = user.email
		user.display_name = user.display_name.prepend("INACTIVE_")
		user.email        = user.email.prepend("INACTIVE_")
		user.customer_uid = user.customer_uid.prepend("INACTIVE_")

		updated << [user.id, user.display_name, user.email, user.customer_uid]

		user.save!
	end
end

headers = %w(user_id display_name email customer_uid)

headers = %w(email customer_uid)

not_updated.easy_csv("users_not_deactivated", headers, {direct_upload: false})




path = "client/1492698710/LUC_InactivteUIDS.csv"

s3_object = Datastores::S3.new(path)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

updated = []
import_array.each do |row|
	user = User.where(customer_uid: row["customer_uid"]).first
	user.email = user.customer_uid + "_dnu@" + Client.current + ".com"
	user.save!
	updated << [user.id, user.customer_uid, user.email]
end

headers = %w(user_id customer_uid email)

updated.easy_csv("users_mass_deactivated", headers, {direct_upload: false})


# update uid to dnu from file
path = "client/1492700209/luc_users_mass_deactivated_2017Apr20_0956.csv"

s3_object = Datastores::S3.new(path)
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

updated = []
skipped = []
import_array.each do |row|
	user = User.find(row["user_id"])
	deactivated_uid = user.customer_uid + "_dnu"
	if user.customer_uid == deactivated_uid
		skipped << [user.id, user.customer_uid, user.email]
	elsif user.customer_uid.include?("_dnu")
		skipped << [user.id, user.customer_uid, user.email]
	else
		user.customer_uid = deactivated_uid
		# user.email = user.customer_uid + "_dnu@" + Client.current + ".com"
		# user.save!
		updated << [user.id, user.customer_uid, user.email]
	end
end

headers = %w(user_id customer_uid email)

report = updated + skipped

report.easy_csv("users_mass_deactivated", headers, {direct_upload: false})


diff.each do |id|
  user = User.find(id)
  user.customer_uid = user.customer_uid.sub("_dnu", "")
	user.save!
end
