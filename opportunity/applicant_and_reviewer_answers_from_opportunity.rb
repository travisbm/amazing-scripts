Client.set "schoolcraft"

opportunity_ids = [2243,2027,2455,1961,1934,2320,2315,2373,2267,2180,2193,2167,2087,2125,2275,1913,1929,1922,2423,2462,2486,2514,2367,2049,2383,2351,2010,2001,1947,2435,2466,2259,2104,2110,2334,2337,2479,2051,2242,1907,2106,1873,1884,1997,1896,2345,2258,2080,2429]

# fields for applicant_application
first_name_field = 310
last_name_field  = 312
student_id_field = 308
# fields for reviewer_application
reviewer_rating  = 681
report = []

# iterate through opportunities by id
opportunity_ids.each do |id|
    opportunity = Opportunity.find(id)
    # iterate through each of the opportunities reviews
    opportunity.reviews.each do |review|
    	row = []
    	result_array = [review.applicant_application.answer(first_name_field).result, 
    		            review.applicant_application.answer(last_name_field).result, 
    		            review.applicant_application.answer(student_id_field).result]

    	row << opportunity.portfolio.name

    	if result_array.any? { |result| result.nil? }
    		row << review.applicant_application.user.name
    		row << ""
    		row << ""
    	else
	    	row << review.applicant_application.answer(first_name_field).result
	    	row << review.applicant_application.answer(last_name_field).result
	    	row << review.applicant_application.answer(student_id_field).result
	    end

    	if review.reviewer_application.nil?
    		row << "No Rating"
    	else
    		row << review.reviewer_application.answer(reviewer_rating).result
    	end
    	report << row
    end
end

headers = %w(opportunity_name applicant_first_name applicant_last_name applicant_id application_id reviewer_rating)

report.easy_csv("faculty_academic_scholarship_reviews", headers, {direct_upload: false})
