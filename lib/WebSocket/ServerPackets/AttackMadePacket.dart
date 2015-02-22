part of FinalEarthCrawler;

class AttackMadePacket extends ServerPacket {
  static int ID = SERVER_PACKETS.ATTACK_MADE_EVENT.index;
  AttackMadeEvent event;
  AttackMadePacket (this.event);

  Map toMap() {
    return { "ID": ID, "attackLog": event.attackLog.toMap() };
  }

}