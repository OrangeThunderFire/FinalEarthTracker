part of FinalEarthCrawler;

class CountryUpdatePacket extends ServerPacket {
  static int ID = SERVER_PACKETS.COUNTRY_UPDATE_EVENT.index;
  CountryChangeEvent event;
  CountryUpdatePacket (this.event);

  Map toMap() {
    return { "ID": ID, "country": event.currentCountry.toMap(), "previousCountry": event.previousCountry.toMap(), "changedFields": event.changedFields };
  }

}