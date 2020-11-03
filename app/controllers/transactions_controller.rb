# To facilitate transactions, no login is required as these are not user actions.
  # Assumes security and authorization is handled by integrated system.
  #   Ex. System calls add_points(recipient, payer, points), not a user
  # Reason: a user shouldn't be able to call add_points for themselves if points are coming from another account.

class TransactionsController < ApplicationController
  before_action :authenticate_user!

end