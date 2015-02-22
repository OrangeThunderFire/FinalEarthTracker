part of FinalEarthCrawler;

class UnitUpdatePacket extends ServerPacket {
  static int ID = SERVER_PACKETS.UNIT_UPDATE_EVENT.index;
  UnitChangeEvent event;
  UnitUpdatePacket (this.event);

  Map toMap() {
    Map copy = new Map.from(event.fields)..remove("country")..remove("timeOfUpdate");
    return { "ID": ID, "country": event.country.toMap() }..addAll(copy);
  }

}