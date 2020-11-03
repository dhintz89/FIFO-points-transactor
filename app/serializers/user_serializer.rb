class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :total_points
  # has_many :transactions

  def total_points
    current_user.total_points
  end

end