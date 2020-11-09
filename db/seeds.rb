# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).


# Create 2 Users
main_user = User.create(email: "test@example.com", password: "password")
secondary_user = User.create(email: "notauser@example.com", password: "password")

# Create 4 positive and 1 negative Transactions under main_user, and 2 not associated to main_user
main_user.transactions.create(payer_name: "DANNON", points: 100, original_points: 300)
main_user.transactions.create(payer_name: "UNILEVER", points: 200, original_points: 200)
main_user.transactions.create(payer_name: "DANNON", points: -200, original_points: -200)
secondary_user.transactions.create(payer_name: "SOMETHINGELSE", points: 500, original_points: 500)
secondary_user.transactions.create(payer_name: "SOMETHINGELSE", points: 400, original_points: 400)
main_user.transactions.create(payer_name: "MILLER COORS", points: 10000, original_points: 10000)
main_user.transactions.create(payer_name: "DANNON", points: 1000, original_points: 1000)