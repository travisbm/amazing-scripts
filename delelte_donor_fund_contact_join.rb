Client.set 'foster-washington'

fund_contacts_to_delete = Donor::FundContact.select {|fc| !Donor::Contact.exists?(fc.contact_id)}; nil

fund_contacts_to_delete.each do |fund_contact|
	fund_contact.destroy!
end


fund_contacts = Donor::FundContact.where(fund_id: 207).select {|fc| !Donor::Contact.exists?(fc.contact_id)}; nil

fund_contacts.each do |fund_contact|
	fund_contact.destroy!
end

Donor::FundContact.joins('LEFT OUTER JOIN donor_contacts ON donor_contacts.id = donor_fund_contacts.contact_id').where('donor_contacts.id IS NULL'); nil

Donor::FundContact.joins('LEFT OUTER JOIN donor_funds ON donor_funds.id = donor_fund_contacts.fund_id').where('donor_funds.id IS NULL'); nil