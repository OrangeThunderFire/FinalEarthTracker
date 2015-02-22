part of FinalEarthCrawler;

class MongoInstance {
  static Db _mongoDb = new Db("mongodb://localhost:27017/finalearth");

  static get mongoDb async {
    if (_mongoDb.state == State.CLOSED || _mongoDb.state == State.INIT) {
      await _mongoDb.open();
        return new Future.value(_mongoDb);
    }
    else {
      return new Future.value(_mongoDb);
    }
  }
}