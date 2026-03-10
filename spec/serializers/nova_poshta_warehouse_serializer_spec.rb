require "rails_helper"

RSpec.describe NovaPoshtaWarehouseSerializer do
  describe ".format" do
    let(:warehouse_data) do
      {
        "Ref" => "warehouse-ref-123",
        "Number" => "1",
        "Description" => "Відділення №1: вул. Хрещатик, 1",
        "DescriptionRu" => "Отделение №1: ул. Крещатик, 1",
        "ShortAddress" => "Київ, вул. Хрещатик, 1",
        "ShortAddressRu" => "Киев, ул. Крещатик, 1",
        "TypeOfWarehouse" => "9a68df70-0267-42a8-bb5c-37f427e36ee4",
        "CategoryOfWarehouse" => "Branch",
        "Latitude" => "50.4501",
        "Longitude" => "30.5234",
        "Reception" => { "Monday" => "08:00-20:00" },
        "Delivery" => { "Monday" => "08:00-20:00" },
        "Schedule" => { "Monday" => "08:00-20:00" }
      }
    end

    it "formats warehouse data correctly" do
      result = described_class.format(warehouse_data)

      expect(result[:ref]).to eq("warehouse-ref-123")
      expect(result[:number]).to eq("1")
      expect(result[:description]).to eq("Відділення №1: вул. Хрещатик, 1")
      expect(result[:description_ru]).to eq("Отделение №1: ул. Крещатик, 1")
      expect(result[:short_address]).to eq("Київ, вул. Хрещатик, 1")
      expect(result[:latitude]).to eq("50.4501")
      expect(result[:longitude]).to eq("30.5234")
      expect(result[:type_of_warehouse]).to eq("9a68df70-0267-42a8-bb5c-37f427e36ee4")
      expect(result[:category_of_warehouse]).to eq("Branch")
      expect(result[:reception]).to be_present
      expect(result[:delivery]).to be_present
      expect(result[:schedule]).to be_present
    end
  end

  describe ".format_collection" do
    let(:warehouses) do
      [
        { "Ref" => "ref1", "Number" => "1", "Description" => "Warehouse 1", "DescriptionRu" => "Склад 1", "ShortAddress" => "Address 1", "ShortAddressRu" => "Адрес 1", "TypeOfWarehouse" => "type1", "CategoryOfWarehouse" => "Branch", "Latitude" => "50.1", "Longitude" => "30.1", "Reception" => {}, "Delivery" => {}, "Schedule" => {} },
        { "Ref" => "ref2", "Number" => "2", "Description" => "Warehouse 2", "DescriptionRu" => "Склад 2", "ShortAddress" => "Address 2", "ShortAddressRu" => "Адрес 2", "TypeOfWarehouse" => "type2", "CategoryOfWarehouse" => "Branch", "Latitude" => "50.2", "Longitude" => "30.2", "Reception" => {}, "Delivery" => {}, "Schedule" => {} }
      ]
    end

    it "formats collection of warehouses" do
      result = described_class.format_collection(warehouses)

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:number]).to eq("1")
      expect(result.second[:number]).to eq("2")
    end
  end
end
