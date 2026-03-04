require "rails_helper"

RSpec.describe Address, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:addressable) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:street) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:country) }
  end

  describe "enums" do
    it "defines address_type enum values" do
      expect(Address.address_types.keys).to contain_exactly("shipping", "billing", "home", "work")
    end

    it "allows setting address_type" do
      address = create(:address, address_type: :shipping)
      expect(address.address_type).to eq("shipping")
      expect(address.address_type_shipping?).to be true
    end
  end

  describe "scopes" do
    let!(:user) { create(:user) }
    let!(:shipping_address) { create(:address, addressable: user, address_type: :shipping) }
    let!(:billing_address) { create(:address, addressable: user, address_type: :billing) }

    describe ".shipping_addresses" do
      it "returns only shipping addresses" do
        expect(Address.shipping_addresses).to contain_exactly(shipping_address)
      end
    end

    describe ".billing_addresses" do
      it "returns only billing addresses" do
        expect(Address.billing_addresses).to contain_exactly(billing_address)
      end
    end

    describe ".by_country" do
      it "returns addresses for specific country" do
        expect(Address.by_country("USA")).to include(shipping_address, billing_address)
      end
    end
  end

  describe "polymorphic behavior" do
    let(:user) { create(:user) }
    let(:order) { create(:order, user: user) }

    it "can be associated with a user" do
      address = create(:address, addressable: user)
      expect(address.addressable).to eq(user)
      expect(address.addressable_type).to eq("User")
    end

    it "can be associated with an order" do
      address = create(:address, addressable: order)
      expect(address.addressable).to eq(order)
      expect(address.addressable_type).to eq("Order")
    end
  end

  describe "#full_address" do
    let(:address) do
      create(:address,
        street: "123 Main St",
        city: "New York",
        state: "NY",
        zip_code: "10001",
        country: "USA")
    end

    it "returns the complete address as a string" do
      expect(address.full_address).to eq("123 Main St, New York, NY, 10001, USA")
    end
  end

  describe "#to_s" do
    let(:address) { create(:address) }

    it "returns the full address" do
      expect(address.to_s).to eq(address.full_address)
    end
  end
end
