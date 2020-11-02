class SessionSerializer < ActiveModel::Serializer
  attributes :id, :email, :token

  def token
    current_user.generate_jwt
  end
end