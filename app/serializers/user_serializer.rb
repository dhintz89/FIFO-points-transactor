class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :total_points

  def total_points
    current_user.total_points.to_s + " points"
  end

end