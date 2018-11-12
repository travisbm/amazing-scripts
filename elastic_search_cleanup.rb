# id's that were deleted
ids = []

# Can be "Opportunity", "User" or "Application"
type = "Application"

# Get a count of how many objects from you ids array are still in elasticsearch
count = Datastores::Elasticsearch.search_by({"_type" => type, "id" => ids}, {size: 0})["hits"]["total"]

# Get the count from above and use here for size. If over 100 'records' do deletions in batches
results = Datastores::Elasticsearch.search_by({"_type" => type, "id" => ids}, {size: count})["hits"]["hits"]

# Use this line to delete the 'results' that you gather above.
Datastores::Elasticsearch.bulk_delete(results, {type: type})

############################################### Report ####################################################

report = []

Datastores.on_each do

  document_types = ["Application", "User", "Opportunity", "Reviewer::Review"]
  document_type_hash = {"client" => Client.current}
  batch_size = 1000


  document_types.each do |document_type|
    max = Object.const_get(document_type).select("max(id)").to_a.first.max.to_i
    lower = 0
    upper = batch_size
    row = []

    while lower < max
      expected_ids = (lower+1..upper).to_a
      cleaner = Cleaner.new(document_type, expected_ids)
      if cleaner.orphaned_documents.present?
        row << cleaner.orphaned_documents
        # cleaner.call
      end
      lower += batch_size
      upper += batch_size
    end
    document_type_hash[document_type] = row.flatten.map { |hash| hash[:_id].to_i }
  end
  report << document_type_hash; nil
end


########################################## REPORT ############################################################

report = []
document_types = ["Application", "User", "Opportunity", "Reviewer::Review"]
document_type_hash = {}
batch_size = 1000

Datastores.on_each do 
  report_row = []
  report_row << Client.current
  document_types.each do |document_type|
    max = Object.const_get(document_type).select("max(id)").to_a.first.max.to_i
    lower = 0
    upper = batch_size
    row = []

    while lower < max
      expected_ids = (lower+1..upper).to_a
      cleaner = Cleaner.new(document_type, expected_ids)
      if cleaner.orphaned_documents.present?
        row << cleaner.orphaned_documents
      end
      lower += batch_size
      upper += batch_size
    end
    document_type_hash[document_type] = row.flatten.map { |hash| hash[:_id].to_i }
  end
  document_type_hash.each { |_key, value| report_row << value.count }; nil
  report << report_row
end

headers = %w(client Application User Opportunity Reviewer::Review)
report.easy_csv("global_orphaned_documents", headers, {direct_upload: false})


########################################## Global Wipe of Orphans #################################################

Datastores.on_each do

  document_types = ["Application", "User", "Opportunity", "Reviewer::Review"]
  batch_size = 1000

  document_types.each do |document_type|
    max = Object.const_get(document_type).select("max(id)").to_a.first.max.to_i
    lower = 0
    upper = batch_size

    while lower < max
      expected_ids = (lower+1..upper).to_a
      cleaner = Cleaner.new(document_type, expected_ids)
      if cleaner.orphaned_documents.present?
        cleaner.call
      end
      lower += batch_size
      upper += batch_size
    end
  end

end