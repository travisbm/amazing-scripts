# Run this to update the application url from applicant_url to admin_url on all shards where it is present in the post_acceptance_submitted MessageTemplate. 262 of 683 updated in test run.
updated     = []
not_updated = []
rescued     = []
total       = []

Client.on_each do |client|
  message_template = MessageTemplate::Fetcher.for_system_by_name("post_acceptance_submitted").first

  begin
    if message_template.body.include? "applicant_url"
      message_template.body.gsub!("applicant_url", "admin_url")
      message_template.save!
      updated << client
    else
      not_updated << client
    end
  rescue StandardError => error
    rescued << [client, error]
  end

  total << client
end

# Run this to update the application url from applicant_url to admin_url on the template shard
Client.set 'template'

updated     = []
not_updated = []
rescued     = []

message_template = MessageTemplate::Fetcher.for_system_by_name("post_acceptance_submitted").first

begin
  if message_template.body.include? "applicant_url"
    message_template.body.gsub!("applicant_url", "admin_url")
    message_template.save!
    updated << Client.current
  else
    not_updated << Client.current
  end
rescue StandardError => error
  rescued << [Client.current, error]
end



