
# reindex applications on not archived opportunities that have been updated in the last 12 hours
Application.indexable.opportunity_not_archived.where(updated_at: 12.hours.ago..DateTime.now).find_each(&:index!)