# To facilitate transactions, no login is required as these are not user actions.
  # Assumes security and authorization is handled by integrated system.
  #   Ex. System calls add_points(recipient, payer, points), not a user
  # Reason: a user shouldn't be able to call add_points for themselves if points are coming from another account.

class TransactionsController < ApplicationController
  before_action :authenticate_user!

  # index
  def points_balance
    user = User.find(params[:user_id])
    transactions = user.transactions.all.sort_by{ |obj| obj.created_at }
    render json: transactions.to_json
  end

  # create
  def add_points
    user = User.find(params[:user_id])
    if transaction_params[:points] < 0
      # remove points
    else
      transaction = user.transactions.new(transaction_params)
      if transaction.valid?
        transaction.save
        render json: transaction.to_json
      else
        render json: {errors: transaction.errors}, status: :bad_request
      end
    end
  end

  def deduct_points

  end

  def destroy
    transaction = Transaction.find(params[:id])
    transaction.destroy
    render json: transaction.to_json
  end

  def show
    render json: Transaction.find(params[:id]).to_json
  end

  private

  def transaction_params
    params.require(:transaction).permit(:payer_name, :points)
  end
end