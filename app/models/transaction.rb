class Transaction < ApplicationRecord
  belongs_to :user
  alias_attribute :recipient_id, :user_id
  validates :payer_name, :points, presence: true, allow_nil: false

  # retreives all transactions associated to provided user, and if payer_name is provided, filters for matches
  def self.sort_user_transactions(user_id, payer_name = '*')
    if payer_name == '*'
      self.find_by_sql(["SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at ASC", user_id].flatten)
    else 
      self.find_by_sql(["SELECT * FROM transactions WHERE user_id = ? AND payer_name = ? ORDER BY created_at ASC", user_id, payer_name].flatten)
    end
  end


  def self.deduct_points(user_id, points_to_deduct, payer_name = '*')
    #  get list of in-scope transactions
    if payer_name == '*'
      transaction_list = Transaction.sort_user_transactions(user_id)
    else
      transaction_list = Transaction.sort_user_transactions(user_id, payer_name)
    end

    #  deduct the points from the user's account
    user = User.find(user_id)
    removed_points = []  #  this will contain the returned data
    i = 0

    # NON-DESTRUCTIVE APPROACH (KEEPS RECORD OF ALL TRANSACTIONS, CREATES -TRANSACTION RATHER THAN ZEROING OUT EXISTING)
    while points_to_deduct > 0 do  # move through sorted transactions list from earliest to most recent (using i)
      processing_transaction = transaction_list[i]
      if !processing_transaction.points < 0  # skip any transactions with negative values (deductions)
        if points_to_deduct - processing_transaction.points >= 0  # if there are remaining points in existing transaction record, need to modify record, not destroy
          neg_transaction = user.transactions.create(payer_name: processing_transaction.payer_name, points: processing_transaction.points * -1)  # change from points owned to points removed
        else
          neg_transaction = user.transactions.create(payer_name: processing_transaction.payer_name, points: points_to_deduct * -1)
        end
        removed_points << neg_transaction

        points_to_deduct += neg_transaction.points
        i += 1
      end
    end

      #  return the removed points for app logging
    return removed_points
  end

end

# DESTRUCTIVE DEDUCT WHILELOOP APPROACH (DELETES ZERO'D OUT TRANSACTIONS TO SAVE MEMORY)
# while points_to_deduct > 0 do  # move through sorted transactions list from earliest to most recent (using i)
#   earliest_transaction = transaction_list[i]
#   if points_to_deduct - earliest_transaction.points >= 0  # if there are remaining points in existing transaction record, need to modify record, not destroy
#     earliest_transaction.update(points: earliest_transaction.points * -1)  # change from points owned to points removed
#     removed_points << earliest_transaction
#     earliest_transaction.destroy  # this transaction is now cancelled out, remove from db
#   else
#     new_balance = earliest_transaction.points - points_to_deduct
#     earliest_transaction.update(points: new_balance)
#     value_to_return = earliest_transaction  # create non-instantiated copy of trans to modify & add to JSON response
#     value_to_return.points = points_to_deduct * -1  # returned variable will contain the amount of points removed in "-amt" format
#     removed_points << value_to_return  
#   end
#   points_to_deduct += removed_points[-1].points
#   i += 1
# end