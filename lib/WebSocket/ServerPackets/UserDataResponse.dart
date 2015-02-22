part of FinalEarthCrawler;

class UserDataResponse extends ServerPacket {
  static int ID = SERVER_PACKETS.USER_DATA_RESPONSE.index;
  String rID;
  User user;
  UserDataResponse (this.rID, this.user);

  Map toMap() {
    return { "ID": ID, "rID": this.rID, "user": user.toMap() };
  }

}