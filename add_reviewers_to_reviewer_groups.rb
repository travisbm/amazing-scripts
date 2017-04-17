Client.set 'massbay'

groups = [42, 2, 44, 38, 45]
users = [[808], [810, 811], [813], [803], [815]]

group_to_users_hash = Hash.new
groups.each_with_index do |group, index|
	group_to_users_hash[group] = users[index]
end

reviewers_created = []
group_to_users_hash.each do |group_id, users|
	chair = false

	users.each do |user_id|
		unless Reviewer::GroupMember.where(user_id: user_id, reviewer_group_id: group_id).exists?
		    member = Reviewer::GroupMember.new(user_id: user_id, reviewer_group_id: group_id, chair: chair)
		    member.save!
		    reviewers_created << member
		end
	end
end


