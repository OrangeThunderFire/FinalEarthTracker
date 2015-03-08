part of FinalEarthCrawler;
abstract class UserRepository {
  store (User event);
  update (User user);
  getById (int id);
  getByName (String name);
}

class MongoUserRepository implements UserRepository {
  MongoUserRepository();

  Future store (User user) async {
    Db database = await MongoInstance.mongoDb;
    DbCollection collection =database.collection("users");
    int count = await collection.count({ "id": user.id });
    print("STORING USER");
    if (count <= 0) {
      print("INSERTING");
      Map userDocument = user.toMap();

      Map response = await collection.insert(userDocument);
      if (response["err"] != null) {
        throw response.err;
      }

      return response;
    }
    return update(user);
  }

  Future update(User user) async {
    print("UPDATING");
    Db database = await MongoInstance.mongoDb;
    DbCollection collection =database.collection("users");
    var response = await collection.update(where.eq('id', user.id), user.toMap());
    return response;
  }

  Future<List<User>> whereHasUnitType (UnitType type) async {
    Db database = await MongoInstance.mongoDb;
    DbCollection collection =database.collection("users");
    try {
      List<Unit> units = Unit.getByType(type);
      print("UNITS");
      print(units);
      print("OR REQ");
      List<Map> orReq = units.map((Unit e) {
        return {
            "unitID": "${e.ID}"
        };
      }).toList();
      print(orReq);
      print({ "knownUnits": { "\$elemMatch": { "\$or": orReq } }});
      List user = await collection.find({ "knownUnits": { "\$elemMatch": { "\$or": orReq } }});
      if (user != null) {
        List<User> users = new List<User>();
        user.forEach((Map user) {
          users.add(new User.fromJson(user));
        });
        return users;
      }
      else {
        return new List<User>();
      }
    }
    catch (E) {
      print(E);
    }

  }

  Future<User> getById (int id) async {
    Db database = await MongoInstance.mongoDb;
    DbCollection collection =database.collection("users");
    Map user = await collection.findOne({ "id": id });
    if (user != null) {
      return new User.fromJson(user);
    }
    else {
      return;
    }
  }
  Future<User> getByName (String name) async {
    Db database = await MongoInstance.mongoDb;
    DbCollection collection =database.collection("users");
    Map user;
    try {
      user = await collection.findOne({
          "name": {
              "\$regex": new BsonRegexp(name, caseInsensitive: true)
          }
      });
    }
    catch (E) {

    }
    if (user == null) {
      return;
    }
    return new User.fromJson(user);
  }
}