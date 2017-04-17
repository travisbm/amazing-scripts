
Client.set "txstate"

# Pull the client file with the scope assignment listing
Support.file_list

s3_object = Datastores::S3.new("client/1484344211/new scopes - jan 17.csv")
import_text = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

# Pull out all the unique scope names
columns = ["Scope 1", "Scope 2", "Scope 3"]
scope_names = []

import_array.each do |row|
  columns.each do |column|
    scope_names << row[column] unless row[column].nil?
  end
end
# Keep only the unique names
scope_names.uniq!

# Now create the scopes in the client system
scope_names.each do |name|
  Scope.create(name: name)
end

# Assign the scopes to the proper Portfolios
updated = []

import_array.each do |row|
  portfolio = Portfolio.find(row["id(unchangeable)"])

  columns.each do |column|
    next if row[column].nil?

    scope = Scope.where(name: row[column]).first

    unless ScopeAssignment.where(scopable_type: "Portfolio", scopable_id: portfolio.id, scope_id: scope.id).exists?
      ScopeAssignment.create(scopable_type: "Portfolio", scopable_id: portfolio.id, scope_id: scope.id)
      updated << "P: #{portfolio.id}, S: #{scope.id}"
    end
  end

end

# With a single column of new scopes
scope_names = []
import_array.each do |row|
  scope_names << row["NEW_SCOPE"] unless row["NEW_SCOPE"].nil?
end
# Keep only the unique names
scope_names.uniq!

# Now create the scopes in the client system
scope_names.each do |name|
  Scope.create(name: name)
end

# Assign the scopes to the proper Portfolios
updated = []

import_array.each do |row|
  portfolio = Portfolio.find(row["portfolio_id(unchangeable)"])

  next if row["NEW_SCOPE"].nil?

  scope = Scope.where(name: row["NEW_SCOPE"]).first

  unless ScopeAssignment.where(scopable_type: "Portfolio", scopable_id: portfolio.id, scope_id: scope.id).exists?
    ScopeAssignment.create(scopable_type: "Portfolio", scopable_id: portfolio.id, scope_id: scope.id)
    updated << "P: #{portfolio.id}, S: #{scope.id}"
  end

end
