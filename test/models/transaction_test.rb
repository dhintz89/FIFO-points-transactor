require 'test_helper'

class TransactionTest < ActiveSupport::TestCase

  def setup
    @user = users(:valid_user)
  end

  test "can pull transactions by user_id" do
    list = Transaction.sort_user_transactions(@user.id)
    assert_equal 3, list.size
  end

  test "can pull transactions by user_id, sorted by created date (ASC)" do
    list = Transaction.sort_user_transactions(@user.id)
    assert_equal [transactions(:one), transactions(:two), transactions(:four)], list
  end

  test "can pull transactions by user_id AND payer_name if payer_name is provided" do
    list = Transaction.sort_user_transactions(@user.id, "DANNON")
    assert_equal 2, list.size
  end

  test "can pull transactions by user_id AND payer_name, sorted by created date (ASC)" do
    list = Transaction.sort_user_transactions(@user.id, "DANNON")
    assert_equal [transactions(:one), transactions(:four)], list
  end

  test "can create new transaction for user given payer_name and points" do
    trans = @user.transactions.new(payer_name: "HARRISTEETER", points: 900)
    assert trans.valid?, "new transaction is not valid"
  end

  test "can't create new transaction for user without payer_name" do
    trans = @user.transactions.new(points: 900)
    assert_not trans.save, "transaction cannot be created without specifying payer_name"
  end

  test "can't create new transaction for user without points" do
    trans = @user.transactions.new(payer_name: "HARRISTEETER")
    assert_not trans.save, "transaction cannot be created without specifying points"
  end

  test "deduct_points deletes transactions when their balance hits 0 (all payers)" do
    Transaction.deduct_points(@user.id, 600)
    list = Transaction.sort_user_transactions(@user.id)
    assert_equal 1, list.size
  end

  test "deduct_points processes transactions in First-In-First-Out order (all payers)" do
    removed_transactions = Transaction.deduct_points(@user.id, 600)
    assert_equal [980190962, 298486374, 281110143], removed_transactions.map{|t| t.id}
  end

  test "deduct_points deducts the correct number of points (all payers)" do
    Transaction.deduct_points(@user.id, 600)
    assert_equal 400, @user.total_points
  end

  test "deduct_points deletes transactions when their balance hits 0 (payer specified)" do
    Transaction.deduct_points(@user.id, 600, "DANNON")
    list = Transaction.sort_user_transactions(@user.id, "DANNON")
    assert_equal 1, list.size
  end

  test "deduct_points processes transactions in First-In-First-Out order (payer specified)" do
    removed_transactions = Transaction.deduct_points(@user.id, 600, "DANNON")
    assert_equal [980190962, 281110143], removed_transactions.map{|t| t.id}
  end

  test "deduct_points deducts the correct number of points (payer specified)" do
    Transaction.deduct_points(@user.id, 600, "DANNON")
    assert_equal 200, @user.payer_points_subtotal("DANNON")
  end

end
