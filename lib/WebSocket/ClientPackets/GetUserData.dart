part of FinalEarthCrawler;

class GetUserData extends ClientPacket {
  static UserRepository _userRepo = new MongoUserRepository();
  static int ID = CLIENT_PACKETS.GET_USER_DATA.index;

  final String name;
  final String rID;

  GetUserData.create(String this.name);

  void handlePacket(WebSocketHandler wsh, Client client) async {
    User user = await _userRepo.getByName(this.name);
    if (user == null) {
      client.sendPacket(new UserNotFoundPacket(this.rID, this.name));
      return;
    }
    client.sendPacket(new UserDataResponse(this.rID, user));
  }
}