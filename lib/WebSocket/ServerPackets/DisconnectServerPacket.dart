part of FinalEarthCrawler;

class DisconnectServerPacket extends ServerPacket {
  static int ID = SERVER_PACKETS.DISCONNECT_SERVER.index;
  String reason;
  DisconnectServerPacket(this.reason);

}
