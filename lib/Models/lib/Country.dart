part of FinalEarthModels;

class Country extends FinalEarthModel {
  int _id;
  String _name;
  String _region;
  int _oilRigs;
  int _land;
  int _coastline;
  num _mines;
  int _control;
  TEAM _controllingTeam;
  int _groundDefences;
  int _airDefences;
  num _factories;
  int _alliesUnits;
  int _axisUnits;
  Location _location;
  bool _island;
  String _countryCode;

  int get id => _id;
  String get name => _name;
  String get region => _region;
  int get oilRigs => _oilRigs;
  int get land => _land;
  int get coastline => _coastline;
  num get mines => _mines;
  int get control => _control;
  TEAM get controllingTeam => _controllingTeam;
  int get groundDefences => _groundDefences;
  int get airDefences => _airDefences;
  num get factories => _factories;
  int get alliesUnits => _alliesUnits;
  int get axisUnits => _axisUnits;
  Location get location => _location;
  bool get isIsland => _island;
  String get countryCode => _countryCode;

  Country.fromMapJson (Map countryData) {
    this._id = int.parse(countryData["id"]);
    int teamId = int.parse(countryData["team"]);
    this._controllingTeam = TEAM.values[teamId];
    this._name = countryData["name"];
    this._alliesUnits = countryData["allUnits"];
    this._axisUnits = countryData["axUnits"];
    this._region = countryData["region"];
    this._oilRigs = int.parse(countryData["oilrigs"]);
    this._land = int.parse(countryData["land"]);
    this._coastline = int.parse(countryData["coastline"]);
    this._mines = num.parse(countryData["mines"]); // Seriously whats up with these data types
    this._control = int.parse(countryData["control"]);
    this._groundDefences = int.parse(countryData["gdefence"]);
    this._airDefences = int.parse(countryData["adefence"]);
    this._factories = num.parse(countryData["factorys"]); //  What a stupid fucking name, LOL ITS A FUCKING DOUBLE? WHAT THE FUCK

    // Location parse
    this._island = countryData["location"]["island"];
    List latLng = countryData["location"]["latLng"];
    this._location = new Location(latLng[0], latLng[1]);
    this._countryCode = countryData["location"]["code"];
  }

  Country.fromCountryJson (Map country) {
    this._id = country["id"];
    this._controllingTeam = convertTeamFromString(country["controllingTeam"]);
    this._name = country["name"];
    this._countryCode = country["countryCode"];
    this._alliesUnits = country["alliesUnits"];
    this._axisUnits = country["axisUnits"];
    this._region = country["region"];
    this._oilRigs = country["oilRigs"];
    this._land = country["land"];
    this._coastline = country["coastline"];
    this._mines = country["mines"];
    this._control = country["control"];
    this._groundDefences = country["groundDefences"];
    this._airDefences = country["airDefences"];
    this._factories = country["factories"]; //  What a stupid fucking name, LOL ITS A FUCKING DOUBLE? WHAT THE FUCK

    // Location parse
    this._island = country["isIsland"];
    this._location = new Location.fromLocationJson(country["location"]);
  }

  List<String> getDifferentFields (Country other) {
    List<String> changes = new List<String>();
    this.fields.forEach((String k, value) {
      if (other.fields[k] != value) {
        changes.add(k);
      }
    });
    return changes;
  }
  operator[](String key) {
    return this.fields[key];
  }

  Duration getTravelDuration (Country countryTwo) {
    return new Duration(seconds: (getDistance(countryTwo) / 0.441792));
  }

  num _toRad (num degrees) {
    return degrees * (Math.PI / 180);
  }

  num getDistance (Country countryTwo) {
    num lon1 = this.location.longitude;
    num lat1 = this.location.latitude;
    num lon2 = countryTwo.location.longitude;
    num lat2 = countryTwo.location.latitude;
    int km = 6371;
    num rad1 = _toRad(lat2 - lat1);
    num rad2 = _toRad(lon2 - lon1);
    num l1 = _toRad(lat1);
    num l2 = _toRad(lat2);
    num a = (Math.sin(rad1 / 2) * Math.sin(rad1 / 2)) + Math.sin(rad2 / 2) * Math.sin(rad2 / 2) * Math.cos(l1) * Math.cos(l2);
    num c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    num distance = km * c;
    return distance;
  }

  Map toMap () {
    Map fields = this.fields;
    fields["location"] = this.location.toMap();
    fields["controllingTeam"] = this.controllingTeam == TEAM.AXIS ? "Axis" : this.controllingTeam == TEAM.NEUTRAL ? "Neutral" : "Allies";
    return fields;
  }
}