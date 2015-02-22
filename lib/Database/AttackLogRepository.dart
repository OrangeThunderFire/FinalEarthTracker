part of FinalEarthCrawler;
abstract class AttackLogRepository {
  void store (AttackMadeEvent event);
}

class MongoAttackLogRespository implements AttackLogRepository {
  MongoAttackLogRepository();

  store (AttackMadeEvent event) async {
    Db database = await MongoInstance.mongoDb;
    DbCollection collection =database.collection("attack_logs");
    int count = await collection.count({ "attackLog.logID": event.attackLog.logID });
    if (count <= 0) {
      Map attackLogDocument = event.fields;
      attackLogDocument["attackLog"] = event.attackLog.toMap();

      Map response = await collection.insert(attackLogDocument);
      if (response["err"] != null) {
        throw response.err;
      }


      return response;
    }
    // already inserted
    return;
  }


}