part of FinalEarthCrawler;

class UserNotFoundPacket extends ServerPacket {
  static int ID = SERVER_PACKETS.USER_NOT_FOUND.index;
  String rID;
  String name;
  UserNotFoundPacket (this.rID, this.name);

  Map toMap() {
    return { "ID": ID, "rID": this.rID, "name": this.name };
  }

}