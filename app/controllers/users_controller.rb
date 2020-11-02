class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: current_user, serializer: UserSerializer
  end

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