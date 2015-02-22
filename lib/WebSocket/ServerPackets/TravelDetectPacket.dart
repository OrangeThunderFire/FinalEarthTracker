part of FinalEarthCrawler;

class TravelDetectPacket extends ServerPacket {
  static int ID = SERVER_PACKETS.TRAVEL_DETECT_EVENT.index;
  TravelDetectEvent event;
  TravelDetectPacket (this.event);

  Map toMap() {
    return { "ID": ID, "to": event.countryTo.toMap(), "from": event.countryFrom.toMap(), "team": convertTeamToString(event.team), "units": event.units };
  }

}