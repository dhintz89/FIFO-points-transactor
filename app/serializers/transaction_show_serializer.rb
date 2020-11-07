class TransactionShowSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :payer_name, :points, :created_at

  def points
    object.points.to_s + " points"
  end
end
