Opportunity::Encumberable.not_archived.find_each do |opportunity|
  Workers::QuestionRebuilders::Single.enqueue(opportunity.id)

  if opportunity.post_acceptance_process_enabled?
    Workers::QuestionRebuilders::Single.enqueue(opportunity.post_acceptance_opportunity.id)
  end
end