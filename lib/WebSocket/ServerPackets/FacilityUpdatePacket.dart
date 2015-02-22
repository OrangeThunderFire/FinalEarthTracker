part of FinalEarthCrawler;

class FacilityUpdatePacket extends ServerPacket {
  static int ID = SERVER_PACKETS.FACILITY_UPDATE_EVENT.index;
  FacilityChangeEvent event;
  FacilityUpdatePacket (this.event);

  Map toMap() {
    Map copy = new Map.from(event.fields)..remove("country")..remove("timeOfUpdate");
    return { "ID": ID, "country": event.country.toMap() }..addAll(copy);
  }

}