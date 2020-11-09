class RemovedTransactionSerializer < ActiveModel::Serializer
  attributes :payer_name, :points, :created_at

  def points
    object.points.to_s + " points"
  end
end
