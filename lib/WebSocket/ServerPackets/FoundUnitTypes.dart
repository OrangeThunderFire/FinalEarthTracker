part of FinalEarthCrawler;

class FoundUnitTypes extends ServerPacket {
  static int ID = SERVER_PACKETS.FOUND_UNIT_TYPES.index;
  List<User> users;
  String rID = "";
  FoundUnitTypes (this.rID, this.users);

  Map toMap() {
    List<Map> userMap = new List<Map>();
    this.users.forEach((User u) {
      userMap.add(u.toMap());
    });
    return { "ID": ID, "rID": this.rID, "users": this.users };
  }

}