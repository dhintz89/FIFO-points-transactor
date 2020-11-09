# README

## Prerequisites
* Ruby version: 2.6.1
* Rails version: 5.2.4


## Steps to setup locally
1. Fork and Clone repository from Github<br/>
`git clone git@github.com:[your-username]/fetch-backend-coding-challenge.git`

2. Install dependencies using Bundle<br/>
`bundle install`

3. Create database from config/database.yml (SQLite3)<br/>
`rake db:create`

4. Initialize<br/>
`rake db:schema:load`<br/>
*If this doesn't work for any reason, run `rake db:migrate` instead to build from migration files*

5. Seed database<br/>
`rails db:seed`<br/>
*This will create a dummy user for authentication and db association purposes, as well as several transactions for integration testing*

6. Need to reset the data in the database?<br/>
`rake db:reset`  (db will reset and be re-seeded)

7. Need to entirely drop the database and start over?<br/>
`rake db:drop`  (db will be destroyed)


## Testing
There are model tests included in test/models.  These will test:
* User can be properly created and authenticated and can properly calculate the points totals.
* Transaction can be properly created, viewed, and deducted

Run all tests using `rails test`<br/>
Or Run individual model tests using `rails test test/transaction_test.rb` or `rails test test/user_test.rb`


## Starting Server
* Run `rails s` after all setup is complete to startup development server
* Site is now running on localhost:3000<br/>
*Note: This is not setup to run in the browser, it will respond to HTTP Requests with JSON Responses.*

## Available HTTP Endpoints
Site will respond to the following HTTP Requests (recommend using [Postman](https://www.postman.com/downloads/) to make calls)<br/>
[![Run in Postman](https://run.pstmn.io/button.svg)](https://god.postman.co/run-collection/c379b625d44266b22487)<br/>
Note: Default Auth Token present in Postman Workspace corresponds to first user after **database is seeded**.  If you prefer to create a new user instead, make sure to change the token in the Authorization Headers to the value returned upon successful Registration.

#### Frontend User Paths

###### Register new User
* Request: `POST localhost:3000/users`
  * Body: `{ "user": { "email":<String>, "password":<String>, "password_confirmation":<Integer> } }`
  * Headers: N/A
* Expected Response: `{ "user": { "id": <Integer>, "email": <String>, "token": <String> } }`
###### Sign in existing User
* Request: `POST localhost:3000/users/sign_in`
  * Body: `{ "user": { "email":<String>, "password":<String> } }`
  * Headers: `Authorization: Bearer <token>`
* Expected Response: `{ "user": { "id": <Integer>, "email": <String>, "token": <String> } }`
###### View User Info
A signed-in user can use this endpoint to view their own account details, as well as their total point balance.
* Request: `GET localhost:3000/user`
  * Body: N/A
  * Headers: `Authorization: Bearer <token>`
* Expected Response: `{ "user": { "id": <Integer>, "email": <String>, "total_points": <String> } }`
<br/>

#### Backend User/Agent Paths

###### Get a user's points balance
Use to see how many points are currently in a user's account, organized by payer.
* Request: `GET localhost:3000/users/<:user_id>/transactions/points_balance`
  * Body: N/A
  * Headers: `Authorization: Bearer <String>`
* Expected Response: `{ "transactions": [ {"payer_name": <String>, "points": <String>}, {"payer_name": <String>, "points": <String>},... ] }`
###### View full transaction log
Use to see full list of transactions, including zeroed-out and negative, organized by ascending created date.
* Request: `GET localhost:3000/users/<:user_id>/transactions/view_log`
  * Body: N/A
  * Headers: `Authorization: Bearer <String>`
* Expected Response: `{ "transactions": [ {"id": <Integer>, "user_id":<Integer>, "payer_name": <String>, "points": <String>, "original_points":<Integer>, "created_at":<DateTime>}, {"id": <Integer>, "user_id":<Integer>, "payer_name": <String>, "points": <String>, "original_points":<Integer>, "created_at":<DateTime>},... ] }`
###### Add points to a user
Use to add points to a user.
*Note: adding negative points performs the same action as using the deduct points endpoint, except only transactions for a single payer will be processed.*
* Request: `POST localhost:3000/users/<:user_id>/transactions/add_points`
  * Body: `{ "transaction": { "payer_name":<String>, "points": <Integer> } }`
  * Headers: `Authorization: Bearer <String>`
* Expected Response: `{ "transaction": { "id": <Integer>, "user_id": <Integer>, "payer_name": <String>, "points": <String>, "created_at": <DateTime> } }`
###### View transaction details
Use to view full details of a singe transaction.
* Request: `GET localhost:3000/users/<:user_id>/transactions/<:id>`
  * Body: N/A
  * Headers: `Authorization: Bearer <String>`
* Expected Response: `{ "transaction": { "id": <Integer>, "user_id": <Integer>, "payer_name":<String>, "points": <Integer>, "original_points":<Integer>, "created_at": <DateTime> } }`
###### Deduct Points from a user 
Use to deduct points from a user.  Points will be removed order-by-order in first-in/first-out order.  Returns removed points.
* Request: `POST localhost:3000/users/<:user_id>/transactions/deduct_points`
  * Body: `{ "transaction": { "points": <Integer> } }`
  * Headers: `Authorization: Bearer <String>`
* Expected Response: `{ "transactions": [ {"payer_name": <String>, "points": <String>, "updated_at": <DateTime>}, {"payer_name": <String>, "points": <String>, "updated_at": <DateTime>},... ] }`
###### Delete a specific transaction
Use to delete (cancel) a transaction - Deduct Points endpoint should be used for removing valid points.
* Request: `DELETE localhost:3000/users/<:user_id>/transactions/<:id>`
  * Body: N/A
  * Headers: `Authorization: Bearer <String>`
* Expected Response: `{ "transaction": { "id": <Integer>, "user_id": <Integer>, "payer_name": <String>, "points": <String>, "original_points":<Integer>, "created_at": <DateTime> } }`

