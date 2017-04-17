report = []

Client.on_each do |client|
  last_file = Import::Answer::File.where(status: "succeeded", created_at: 1.week.ago..DateTime.now).order(:id).last
  
  next if last_file.nil?
  
  total_import_record_count = Import::Answer::Record.active.count
  
  import_record_count_from_last_file = Import::Answer::Record.active.where(import_answer_file_id: last_file.id).count
  
  if total_import_record_count == import_record_count_from_last_file
    report << [client, last_file.created_at, last_file.id, total_import_record_count]
  end
end