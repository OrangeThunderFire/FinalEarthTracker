part of FinalEarthCrawler;

abstract class WorldRepository {

  void store (FacilityChangeEvent event);
}

class MongoWorldRepository implements WorldRepository {
  MongoWorldRepository();

  store (WorldUpdateEvent event) async {
    Db database =await MongoInstance.mongoDb;
    DbCollection collection =database.collection("world_updates");

    Map worldDocument = new Map.from(event.fields);
    worldDocument.remove("previousWorld");
    worldDocument["world"] = worldDocument["world"].toMap();

    Map response = await collection.insert(worldDocument);
    if (response["err"] != null) {
      throw response.err;
    }
    return response;
  }

}