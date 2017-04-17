Client.set "butlercc"

category = Category.find(58)

category.reviewer_visible = false

category.save!
