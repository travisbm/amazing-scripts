#Email unsubmitted References for a specific opportunity

Client.set "utep"

opportunity = Opportunity.find(449)

sent = []
opportunity.applications.find_each do |application|
  application.user.reference_contacts.each do |reference|
    reference_application = reference.application
    next if reference.expired? || reference_application.submitted?
    reference.email_contact
    sent << reference
  end
end

# Send reference request reminder to unsubmitted references

Client.set "sbccd"

opportunity = Opportunity.find(687)

sent = []
references = []
opportunity.applications.find_each do |application|
  application.user.reference_contacts.each do |reference|
    reference_application = reference.application
    next if reference.expired? || reference_application.submitted?
    references << reference.id
    # Message::Library.reference_request_reminder_reference_notification(reference).deliver
    # sent << reference
  end
end