part of FinalEarthCrawler;

class FindUnitType extends ClientPacket {
  static UserRepository _userRepo = new MongoUserRepository();
  static int ID = CLIENT_PACKETS.FIND_UNIT_TYPE.index;

  final String rID;
  final int typeID;

 FindUnitType.create(int this.typeID);

  void handlePacket(WebSocketHandler wsh, Client client) async {
    try {
      List<User> users = await _userRepo.whereHasUnitType(UnitType[this.typeID]);
      client.sendPacket(new FoundUnitTypes(this.rID, users));
    }
    catch (E) {
      print("Encountered error: In FindUnitType\n");
      print(E);
    }
  }
}