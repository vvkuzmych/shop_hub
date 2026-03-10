require "rails_helper"

RSpec.describe NovaPoshtaCitySerializer do
  describe ".format" do
    let(:city_data) do
      {
        "Ref" => "e71abb60-4b33-11de-b2ad-00215aee3ebe",
        "Description" => "Київ",
        "DescriptionRu" => "Киев",
        "Area" => "Київська область",
        "SettlementTypeDescription" => "місто"
      }
    end

    it "formats city data correctly" do
      result = described_class.format(city_data)

      expect(result[:ref]).to eq("e71abb60-4b33-11de-b2ad-00215aee3ebe")
      expect(result[:name]).to eq("Київ")
      expect(result[:name_ru]).to eq("Киев")
      expect(result[:area]).to eq("Київська область")
      expect(result[:settlement_type]).to eq("місто")
    end
  end

  describe ".format_collection" do
    let(:cities) do
      [
        {
          "Ref" => "ref1",
          "Description" => "Київ",
          "DescriptionRu" => "Киев",
          "Area" => "Київська область",
          "SettlementTypeDescription" => "місто"
        },
        {
          "Ref" => "ref2",
          "Description" => "Львів",
          "DescriptionRu" => "Львов",
          "Area" => "Львівська область",
          "SettlementTypeDescription" => "місто"
        }
      ]
    end

    it "formats collection of cities" do
      result = described_class.format_collection(cities)

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:name]).to eq("Київ")
      expect(result.second[:name]).to eq("Львів")
    end
  end
end
