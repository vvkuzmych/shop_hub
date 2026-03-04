# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  parent_id   :integer
#
# Indexes
#
#  index_categories_on_name  (name) UNIQUE
#
class CategorySerializer
  include JSONAPI::Serializer

  attributes :name, :description, :position
end
