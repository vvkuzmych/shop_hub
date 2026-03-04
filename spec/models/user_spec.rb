# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string
#  encrypted_password     :string
#  first_name             :string
#  last_name              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require "rails_helper"

RSpec.describe User, type: :model do
  # Association tests
  describe "associations" do
    it { is_expected.to have_many(:orders).dependent(:destroy) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    # TODO: Add cart_items association test when CartItem model is created
    # it { is_expected.to have_many(:cart_items).dependent(:destroy) }
  end

  # Enum tests
  describe "enums" do
    it { is_expected.to define_enum_for(:role).with_values(customer: 0, admin: 1) }
  end

  # Validation tests
  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }

    it "validates email uniqueness" do
      create(:user, email: "test@example.com")
      duplicate = build(:user, email: "test@example.com")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "validates email format" do
      valid_emails = [ "user@example.com", "test.user@domain.co.uk", "user+tag@example.com" ]
      valid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).to be_valid, "Expected #{email} to be valid"
      end

      invalid_emails = [ "invalid", "@example.com", "user@", "user" ]
      invalid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).not_to be_valid, "Expected #{email} to be invalid"
      end
    end
  end

  # Password tests (Devise)
  describe "password" do
    it "requires password on create" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it "authenticates with correct password" do
      user = create(:user, password: "password123")
      expect(user.valid_password?("password123")).to be true
      expect(user.valid_password?("wrong")).to be false
    end
  end

  # Scope tests
  describe "scopes" do
    describe ".admins" do
      it "returns only admin users" do
        admin = create(:user, role: :admin)
        customer = create(:user, role: :customer)

        expect(User.admins).to include(admin)
        expect(User.admins).not_to include(customer)
      end
    end

    describe ".customers" do
      it "returns only customer users" do
        admin = create(:user, role: :admin)
        customer = create(:user, role: :customer)

        expect(User.customers).to include(customer)
        expect(User.customers).not_to include(admin)
      end
    end
  end

  # Method tests
  describe "#full_name" do
    it "returns first name and last name combined" do
      user = build(:user, first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end

  # Role helper methods
  describe "role helpers" do
    it "provides role query methods" do
      admin = create(:user, role: :admin)
      customer = create(:user, role: :customer)

      expect(admin.admin?).to be true
      expect(admin.customer?).to be false

      expect(customer.customer?).to be true
      expect(customer.admin?).to be false
    end
  end
end
