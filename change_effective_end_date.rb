# set the date to change FROM
current_end_date = Date.new(2017,3,3)
# set the date to change TO
desired_end_date = Date.new(2017,3,5)

# search by effective_end_at and end_at the same
automatch_opportunities = Opportunity::Automatch.where(effective_end_at: current_end_date, end_at: current_end_date).all; nil

# change effective_end_at and end_at to the same value for automatch opportunities
automatch_opportunities.each do |opportunity|
  opportunity.effective_end_at = desired_end_date
  opportunity.end_at           = desired_end_date
  opportunity.save!
  opportunity.index!

  sleep 5
end

# search by effective_end_at only
automatch_opportunities = Opportunity::Automatch.where(effective_end_at: current_end_date).all; nil

# change effective_end_at for automatch opportunities
automatch_opportunities.each do |opportunity|
  opportunity.effective_end_at = desired_end_date
  opportunity.save!
  opportunity.index!

  sleep 5
end

# search by end_at only
automatch_opportunities = Opportunity::Automatch.where(end_at: current_end_date).all; nil

# change effective_end_at and end_at to the same value for automatch opportunities
automatch_opportunities.each do |opportunity|
  opportunity.end_at = desired_end_date
  opportunity.save!
  opportunity.index!

  sleep 5
end


# search for apply to opportunities by end_at
apply_opportunities = Opportunities::Apply.where(end_at: current_end_date).all; nil

# change end_at for apply opportunities
apply_opportunities.each do |opportunity|
	opportunity.end_at = desired_end_date
	opportunity.save!
	opportunity.index!

	sleep 5
end