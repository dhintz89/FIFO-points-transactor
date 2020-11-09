class TransactionSerializer < ActiveModel::Serializer
  attributes :payer_name, :points

  def points
    binding.pry
    object[:points].to_s + " points"
  end
end
