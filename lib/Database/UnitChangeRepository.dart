part of FinalEarthCrawler;
abstract class UnitChangeRepository {
  void store (FacilityChangeEvent event);
}

class MongoUnitChangeRepository implements UnitChangeRepository {
  MongoUnitChangeRepository();

  store (UnitChangeEvent event) async {
    Db database = await MongoInstance.mongoDb;
    DbCollection collection =database.collection("unit_updates");

    Map unitChangeDocument = new Map.from(event.fields);
    unitChangeDocument["country"] = unitChangeDocument["country"].toMap();

    Map response = await collection.insert(unitChangeDocument);
    if (response["err"] != null) {
      throw response.err;
    }
    return response;
  }


}