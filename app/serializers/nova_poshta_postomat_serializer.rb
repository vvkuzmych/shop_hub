class NovaPoshtaPostomatSerializer
  def self.format(postomat)
    {
      ref: postomat["Ref"],
      number: postomat["Number"],
      description: postomat["Description"],
      description_ru: postomat["DescriptionRu"],
      short_address: postomat["ShortAddress"],
      short_address_ru: postomat["ShortAddressRu"],
      latitude: postomat["Latitude"],
      longitude: postomat["Longitude"],
      reception: postomat["Reception"],
      delivery: postomat["Delivery"],
      schedule: postomat["Schedule"]
    }
  end

  def self.format_collection(postomats)
    postomats.map { |postomat| format(postomat) }
  end
end
