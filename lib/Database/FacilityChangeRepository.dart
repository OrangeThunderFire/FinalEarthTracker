part of FinalEarthCrawler;

abstract class FacilityChangeRepository {
  void store (FacilityChangeEvent event);
}


class MongoFacilityChangeRepository implements FacilityChangeRepository {

  MongoFacilityChangeRepository ();

  store (FacilityChangeEvent event) async {
    Db database = await MongoInstance.mongoDb;
    DbCollection collection =database.collection("facility_updates");

    Map facilityChangeDocument = new Map.from(event.fields);
    facilityChangeDocument["country"] = facilityChangeDocument["country"].toMap();

    Map response = await collection.insert(facilityChangeDocument);
    if (response["err"] != null) {
      throw response.err;
    }
    return response;
  }
}