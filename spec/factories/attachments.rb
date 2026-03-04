# == Schema Information
#
# Table name: attachments
#
#  id              :bigint           not null, primary key
#  attachable_type :string           not null
#  file_name       :string           not null
#  file_size       :integer
#  file_type       :string
#  url             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachable_id   :bigint           not null
#
# Indexes
#
#  index_attachments_on_attachable                         (attachable_type,attachable_id)
#  index_attachments_on_attachable_type_and_attachable_id  (attachable_type,attachable_id)
#  index_attachments_on_file_type                          (file_type)
#
FactoryBot.define do
  factory :attachment do
    file_name { "#{Faker::Lorem.word}.jpg" }
    file_type { "jpg" }
    file_size { rand(1000..5_000_000) }
    url { Faker::Internet.url }
    association :attachable, factory: :product

    trait :image do
      file_name { "#{Faker::Lorem.word}.jpg" }
      file_type { "jpg" }
    end

    trait :document do
      file_name { "#{Faker::Lorem.word}.pdf" }
      file_type { "pdf" }
    end

    trait :video do
      file_name { "#{Faker::Lorem.word}.mp4" }
      file_type { "mp4" }
    end

    trait :for_product do
      association :attachable, factory: :product
    end

    trait :for_user do
      association :attachable, factory: :user
    end

    trait :for_order do
      association :attachable, factory: :order
    end

    trait :small do
      file_size { rand(100..1000) }
    end

    trait :large do
      file_size { rand(10_000_000..50_000_000) }
    end
  end
end
