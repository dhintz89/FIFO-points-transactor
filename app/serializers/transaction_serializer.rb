class TransactionSerializer < ActiveModel::Serializer
  attributes :payer_name, :points

  def points
    object[:points].to_s + " points"
  end
end
