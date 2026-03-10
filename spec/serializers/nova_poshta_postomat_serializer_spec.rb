require "rails_helper"

RSpec.describe NovaPoshtaPostomatSerializer do
  describe ".format" do
    let(:postomat_data) do
      {
        "Ref" => "postomat-ref-456",
        "Number" => "5001",
        "Description" => "Поштомат №5001: вул. Саксаганського, 10",
        "DescriptionRu" => "Почтомат №5001: ул. Саксаганского, 10",
        "ShortAddress" => "Київ, вул. Саксаганського, 10",
        "ShortAddressRu" => "Киев, ул. Саксаганского, 10",
        "Latitude" => "50.4401",
        "Longitude" => "30.5189",
        "Reception" => { "Monday" => "00:00-23:59" },
        "Delivery" => { "Monday" => "00:00-23:59" },
        "Schedule" => { "Monday" => "24/7" }
      }
    end

    it "formats postomat data correctly" do
      result = described_class.format(postomat_data)

      expect(result[:ref]).to eq("postomat-ref-456")
      expect(result[:number]).to eq("5001")
      expect(result[:description]).to eq("Поштомат №5001: вул. Саксаганського, 10")
      expect(result[:description_ru]).to eq("Почтомат №5001: ул. Саксаганского, 10")
      expect(result[:short_address]).to eq("Київ, вул. Саксаганського, 10")
      expect(result[:latitude]).to eq("50.4401")
      expect(result[:longitude]).to eq("30.5189")
      expect(result[:reception]).to be_present
      expect(result[:delivery]).to be_present
      expect(result[:schedule]).to be_present
    end
  end

  describe ".format_collection" do
    let(:postomats) do
      [
        { "Ref" => "ref1", "Number" => "5001", "Description" => "Postomat 1", "DescriptionRu" => "Почтомат 1", "ShortAddress" => "Address 1", "ShortAddressRu" => "Адрес 1", "Latitude" => "50.1", "Longitude" => "30.1", "Reception" => {}, "Delivery" => {}, "Schedule" => {} },
        { "Ref" => "ref2", "Number" => "5002", "Description" => "Postomat 2", "DescriptionRu" => "Почтомат 2", "ShortAddress" => "Address 2", "ShortAddressRu" => "Адрес 2", "Latitude" => "50.2", "Longitude" => "30.2", "Reception" => {}, "Delivery" => {}, "Schedule" => {} }
      ]
    end

    it "formats collection of postomats" do
      result = described_class.format_collection(postomats)

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:number]).to eq("5001")
      expect(result.second[:number]).to eq("5002")
    end
  end
end
