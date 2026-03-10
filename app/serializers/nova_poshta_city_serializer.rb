class NovaPoshtaCitySerializer
  def self.format(city)
    {
      ref: city["Ref"],
      name: city["Description"],
      name_ru: city["DescriptionRu"],
      area: city["Area"],
      settlement_type: city["SettlementTypeDescription"]
    }
  end

  def self.format_collection(cities)
    cities.map { |city| format(city) }
  end
end
