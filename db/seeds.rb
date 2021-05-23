User.create(email: "admin@email.com", password: "admin1", password_confirmation: "admin1", admin: true)

Product.create(title: "The martian", body:"A scientist is trapped on mars.", tags:"scifi,andy weir,space", price:20.00, file_location:"/assets/aw1")
Product.create(title: "A short history of nearly everything", body:"Learn about everything.", tags:"history,bill bryson", price:40.00, file_location:"/assets/bb1")