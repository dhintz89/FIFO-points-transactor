require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'can create valid user' do
    # user = valid_user from test/fixtures/users.yml
    user = users(:valid_user)
    assert user.valid?, "user not valid"
  end

  test "should not save user without info" do
    user = User.new
    assert_not user.save
  end
  
  test "should not save without email" do
    user = User.new(password: "password")
    assert_not user.save
  end

  test "should not save without password" do
    user = User.new(email: "test@example.com")
    assert_not user.save
  end

  # test "user can log in with credentials" do
  #   users = [User.new(email: "test@example.com", password: "password")]
  #   user = users.find{|u| u.email == "test@example.com"}
  #   assert_equal user.password, "password"
  # end

  test "should create JWT" do
    user = users(:valid_user)
    user.id = 1
    token = user.generate_jwt
    jwt_payload = JWT.decode(token, Rails.application.secrets.secret_key_base).first
    puts "expect #{user.id} to equal #{jwt_payload['id']}"
    assert_equal user.id, jwt_payload['id']
  end

  test "should have association with transaction" do
    user = users(:valid_user)
    # valid_user associated with 2 transactions in test/fixtures/transactions.yml
    assert_equal 2, user.transactions.size
  end

  test "total_points should return user's full points balance, not where the points came from" do
    user = users(:valid_user)
    puts "total_points result: #{user.total_points}, expected: #{500}"
    assert_equal 500, user.total_points
  end

end
