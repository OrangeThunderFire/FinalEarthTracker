part of FinalEarthCrawler;

class WorldUpdatePacket extends ServerPacket {
  static int ID = SERVER_PACKETS.WORLD_UPDATE_EVENT.index;
  WorldUpdateEvent event;
  WorldUpdatePacket (this.event);
  Map toMap() {
    return { "ID": ID, "world": event.world.toMap() };
  }

}