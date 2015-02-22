part of FinalEarthCrawler;
enum SERVER_PACKETS {
  DISCONNECT_SERVER,
  WORLD_UPDATE_EVENT,
  COUNTRY_UPDATE_EVENT,
  UNIT_UPDATE_EVENT,
  FACILITY_UPDATE_EVENT,
  TRAVEL_DETECT_EVENT,
  ATTACK_MADE_EVENT,
  USER_DATA_RESPONSE,
  USER_NOT_FOUND
}

abstract class ServerPacket extends Boilerplate {

  Map<String, dynamic> toMapDefault(int ID) {
    return { "ID": ID };
  }
  Map<String, dynamic> toMap() {
    return this.fields;
  }
}

abstract class ResponsePacket extends ServerPacket {
  String rID = new uuid.Uuid().v4();
}

