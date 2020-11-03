class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :payer_name, :points, :created_at, :user_id
  has_one :user
end
