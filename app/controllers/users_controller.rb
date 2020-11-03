# To use the app as a user, you must log in.  User actions assume authenticated user.

class UsersController < ApplicationController
  before_action :authenticate_user!

  # returns the logged-in user details and their total balance
  def show
    render json: current_user, serializer: UserSerializer
  end

  # logged-in user can update their user details (email/password)
  def update
    if current_user.update_attributes(user_params)
      render json: current_user, serializer: UserSerializer
    else
      render json: {errors: current_user.errors}, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end