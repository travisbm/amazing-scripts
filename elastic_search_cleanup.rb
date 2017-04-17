# id's that were deleted
ids = ["put numbers here!!!!!"]

# Can be "Opportunity", "User" or "application"
type = "Opportunity"

# Get a count of how many objects from you ids array are still in elasticsearch
count = Datastores::Elasticsearch.search_by({"_type" => type, "id" => ids}, {size: 0})["hits"]["total"]

# Get the count from above and use here for size. If over 100 'records' do deletions in batches
results = Datastores::Elasticsearch.search_by({"_type" => type, "id" => ids}, {size: count})["hits"]["hits"]

# Use this line to delete the 'results' that you gather above.
Datastores::Elasticsearch.bulk_delete(results, {type: type})
