# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  commentable_type :string           not null
#  content          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_comments_on_commentable                          (commentable_type,commentable_id)
#  index_comments_on_commentable_type_and_commentable_id  (commentable_type,commentable_id)
#  index_comments_on_user_id                              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.paragraph(sentence_count: 3) }
    association :user
    association :commentable, factory: :product

    trait :for_product do
      association :commentable, factory: :product
    end

    trait :for_order do
      association :commentable, factory: :order
    end

    trait :short do
      content { Faker::Lorem.sentence(word_count: 10) }
    end

    trait :long do
      content { Faker::Lorem.paragraph(sentence_count: 10) }
    end
  end
end
