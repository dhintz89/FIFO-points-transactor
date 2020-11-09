# Facilitating transactions is not a user action, but is meant for admins/agents. Thus the user's account is denoted via URL.
  # Ex. System calls user/1/add_points(payer, points) to add points to user1's account, user1 wouldn't have access for this action.
  # Reason: a user shouldn't be able to call add_points for themselves if points are coming from another account.

class TransactionsController < ApplicationController
  before_action :authenticate_user!

  # view details for all of user's transactions
  def view_log
    transactions = Transaction.sort_user_transactions(params[:user_id]) # sort by created_date
    render json: transactions, each_serializer: TransactionShowSerializer
  end
  
  # rollup view of all user's current points by payer
  def points_balance
    user = User.find(params[:user_id])
    transactions = Transaction.sort_user_transactions(params[:user_id]) # sort by created_date
    payers = []

    transactions.each do |t|
      payer = payers.find{|p| p[:payer_name] == t.payer_name}
      if payer
        payer[:points] = payer[:points] + t.original_points
      else
        entry = {payer_name: t.payer_name, points: t.original_points}
        payers << entry
      end
    end
    payers.each {|p| p[:points] = p[:points].to_s + " points"}

    render json: payers
  end

  # creates a new transaction associated to user_id in URL
  def add_points
    user = User.find(params[:user_id])

    if transaction_params[:points] < 0  # This is for negative additions - possible input per instructions
      payer_balance = user.payer_points_subtotal(transaction_params[:payer_name])
      points_to_deduct = transaction_params[:points] * -1
      #  Do not deduct more points than user's total payer sub-balance
      if payer_balance - points_to_deduct < 0  # must be enough points from given payer in the account
        render json: {error: "Can't deduct more than user's total payer sub-balance"}, status: :not_acceptable
      else
        removed_points = Transaction.deduct_points(user.id, points_to_deduct, transaction_params[:payer_name])
        removed_points.size > 0 ? (render json: removed_points, each_serializer: RemovedTransactionSerializer) : (render json: removed_transactions.to_json)
      end

    else  #  Positive additions - usual use case
      transaction = user.transactions.new(payer_name: transaction_params[:payer_name], points: transaction_params[:points], original_points: transaction_params[:points])
      if transaction.valid?
        transaction.save
        render json: transaction, serializer: TransactionShowSerializer
      else
        render json: {errors: transaction.errors}, status: :bad_request
      end
    end
  end


  def deduct_points
    user = User.find(params[:user_id])
    points_to_deduct = transaction_params[:points]

    # Do not deduct more points than user's total balance
    if user.total_points - points_to_deduct < 0
      render json: {error: "Can't deduct more than user's total balance"}, status: :not_acceptable
    else   
      removed_points = Transaction.deduct_points(user.id, points_to_deduct)
      removed_points.size > 0 ? (render json: removed_points, each_serializer: RemovedTransactionSerializer) : (render json: removed_transactions.to_json)
    end
  end


  def destroy
    transaction = Transaction.find(params[:id])
    transaction.destroy
    render json: transaction, serializer: TransactionShowSerializer
  end


  def show
    render json: Transaction.find(params[:id]), serializer: TransactionShowSerializer
  end

  private

  def transaction_params
    params.require(:transaction).permit(:payer_name, :points)
  end
end