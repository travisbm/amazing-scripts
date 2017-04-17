Client.set 'foster-washington'

donor_ids = [149,188,207,200,209,203,192,10,5,191,74,179,212,218,231,230,133,219,143,130,137,146,227,225,228]

deleted = []
donor_ids.each do |id|
	donor_profile = Donor::Profile.find(id)
	deleted << donor_profile
	donor_profile.destroy
end

changed_active = []
Donor::Profile.where(active: false).each do |profile|
	profile.active = true
	changed_active << profile
	profile.save!
end

