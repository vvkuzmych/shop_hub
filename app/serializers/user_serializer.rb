class UserSerializer
  include JSONAPI::Serializer

  attributes :email, :first_name, :last_name, :full_name, :role

  attribute :created_at do |user|
    user.created_at.iso8601
  end
end
