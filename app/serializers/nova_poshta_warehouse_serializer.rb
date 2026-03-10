class NovaPoshtaWarehouseSerializer
  def self.format(warehouse)
    {
      ref: warehouse["Ref"],
      number: warehouse["Number"],
      description: warehouse["Description"],
      description_ru: warehouse["DescriptionRu"],
      short_address: warehouse["ShortAddress"],
      short_address_ru: warehouse["ShortAddressRu"],
      type_of_warehouse: warehouse["TypeOfWarehouse"],
      category_of_warehouse: warehouse["CategoryOfWarehouse"],
      latitude: warehouse["Latitude"],
      longitude: warehouse["Longitude"],
      reception: warehouse["Reception"],
      delivery: warehouse["Delivery"],
      schedule: warehouse["Schedule"]
    }
  end

  def self.format_collection(warehouses)
    warehouses.map { |warehouse| format(warehouse) }
  end
end
