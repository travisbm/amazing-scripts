Client.set "ku"

file_path = "client/1486561980/Keyword 3 Update_KU.csv"

s3_object    = Datastores::S3.new(file_path)
import_text  = s3_object.read.eightball
import_array = CSV.parse(import_text, :headers => true)

updated = []
import_array.each do |row|	
  portfolio  = Portfolio.find(row["id(unchangeable)"])
  scope      = Scope.where(name: row["Scope"]).first
  
  next if scope.nil?

  unless ScopeAssignment.where(scopable_type: "Portfolio", scopable_id: portfolio.id, scope_id: scope.id).exists?
    ScopeAssignment.create(scopable_type: "Portfolio", scopable_id: portfolio.id, scope_id: scope.id)
    updated << [portfolio.id, portfolio.name, scope.id, scope.name]
  end
end
