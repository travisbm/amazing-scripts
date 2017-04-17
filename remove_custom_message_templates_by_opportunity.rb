Client.set 'utah'

file_name = "client/1490971259/revert to system template-Table.csv"

# Use eightball gem to read in the CSV file
s3_object    = Datastores::S3.new(file_name)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

opportunity_ids = []
import_array.each do |row|
	opportunity_ids << row["id(unchangeable)"]
end

class RemoveCustomMessageTemplates

	attr_reader :opportunity_ids_with_unsent_messages

	EMAIL_NAMES = %w(offer offer_reminder post_acceptance)
	FLASH_NAMES = %w(offer post_acceptance)

	def initialize(opportunity_ids)
		@opportunity_ids = opportunity_ids
		@opportunity_ids_with_unsent_messages = []
	end

	def call
		if !unsent_messages? 
			destroy_custom_message_templates
		elsif unsent_messages? && destroy_with_unsent_messages?
			destroy_custom_message_templates
		elsif create_report?
			report
		else
			puts "Goodbye!"
		end
	end

	def email_message_templates
		MessageTemplate.joins(:opportunity).merge(Opportunity::Encumberable.not_archived.where(id: @opportunity_ids)).where(message_templates: {name: EMAIL_NAMES, delivery_method: "email"})
	end

	def flash_message_templates
		MessageTemplate.joins(:opportunity).merge(Opportunity::Encumberable.not_archived.where(id: @opportunity_ids)).where(message_templates: {name: FLASH_NAMES, delivery_method: "flash"})
	end

	def unsent_messages?
		opportunity_ids_with_unsent_messages = []
		email_message_templates.each do |template|
			@opportunity_ids_with_unsent_messages << [template.opportunity_id, template.id, template.messages.count] if template.messages.any? {|m| m.delivered_at == nil}
		end
		@opportunity_ids_with_unsent_messages.empty? ? false : true
	end

	def destroy_custom_message_templates
		email_message_templates.destroy_all
		flash_message_templates.destroy_all
		puts "You've destroyed all the things!"
	end

	def destroy_with_unsent_messages?
		puts "There are unsent messages on some of these oppotunities!!! All unsent messages will be DESTROYED. Continue anyway? (Y/N)"
		response = gets.chomp
		return true if response.in?(["Y", "Yes", "YES", "yes", "y"])
		return false
	end

	def create_report?
		puts "Would you like a report of the unsent messages? (Y/N)"
		response = gets.chomp
		return true if response.in?(["Y", "Yes", "YES", "yes", "y"])
		return false
	end

	def headers
		%w(opportunity_id message_template_id unsent_messages_count)
	end

	def report
		@opportunity_ids_with_unsent_messages.easy_csv("unsent_messages_report", headers, {direct_upload: false})
	end
end


remove = RemoveCustomMessageTemplates.new(opportunity_ids); nil




















