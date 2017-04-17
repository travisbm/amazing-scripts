report = []

Application::Automatch.not_archived.find_each do |application|
    result  = []
    headers = []

    hash = application.form_field_to_answer_hash

    hash.each do |key, value|
    	headers << FormField.find(key).label
    end

    hash.each do |key, value|
      result << value
    end
end

# document = application.retrieve_document
# document.each do |k,v|
#
# end