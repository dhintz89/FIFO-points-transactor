class Transaction < ApplicationRecord
  belongs_to :user
  alias_attribute :recipient_id, :user_id


end
