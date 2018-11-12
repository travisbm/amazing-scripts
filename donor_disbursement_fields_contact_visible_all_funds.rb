# This sets all of the contact visible donor disbursement fields to contact visible on all funds

updated = []
Donor::Fund.find_each do |fund|
  disbursement_fields       = Donor::Disbursement::Field.contact_visible
  disbursement_fields_funds = fund.disbursement_fields_funds.contact_visible.to_a

  disbursement_fields_ids = fund.disbursement_field_ids

  disbursement_fields.find_each do |field|
    unless field.id.in?(disbursement_fields_ids)
      fund_field = fund.disbursement_fields_funds.build(fund_id: fund.id, disbursement_field_id: field.id)
      disbursement_fields_funds << fund_field
    end
  end

  updated << fund.id
  # fund.save!
end
  
