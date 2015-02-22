part of FinalEarthModels;

class World extends FinalEarthModel {
  final List<Country> countries = new List<Country>();
  final Map<int, Country> _countryByIdIndex = new Map<int, Country>();
  final Map<String, Country> _countryByNameIndex = new Map<String, Country>();
  final Map<String, Country> _countryByCountryCodeIndex = new Map<String, Country>();
  final Map<String, List<Country>> _countriesByRegionIndex = new Map<String, List<Country>>();

  World();
  World.fromMapJson (Map worldData) {
    worldData["arr1"].forEach((String key, Map countryData) {
      String id = worldData["travel1"][key.toLowerCase()]; // What the fuck is up with their data types
      // Holy shit they have mixed lower case and upper case...
      if (id == null) {
        id = worldData["travel1"][key];
      }
      countryData["location"] = worldData["travel"][id];
      this._addCountry(new Country.fromMapJson(countryData));
    });
  }

  World.fromWorldJson (Map world) {
    world["countries"].forEach((Map country) {
      this._addCountry(new Country.fromCountryJson(country));
    });
  }

  void _addCountry (Country country) {
    countries.add(country);
    _countryByIdIndex[country.id] = country;
    _countryByNameIndex[country.name.toUpperCase()] = country;
    if (country.countryCode != null) {
      _countryByCountryCodeIndex[country.countryCode.toUpperCase()] = country;
    }
    if (!_countriesByRegionIndex.containsKey(country.region.toUpperCase())) {
      _countriesByRegionIndex[country.region.toUpperCase()] = new List<Country>();
    }
    _countriesByRegionIndex[country.region.toUpperCase()].add(country);
  }


  Country getCountryById (int id) {
    return _checkIndexOrFail(_countryByIdIndex, id, "ID");
  }
  List<Country> getCountriesByRegion (String region) {
    return _checkIndexOrFail(_countriesByRegionIndex, region.toUpperCase(), "region");
  }

  Country getCountryByCountryCode (String code) {
    return _checkIndexOrFail(_countryByCountryCodeIndex, code.toUpperCase(), "Country Code");
  }

  Country getCountryByName (String name) {
    return _checkIndexOrFail(_countryByNameIndex, name.toUpperCase(), "Name");
  }

  dynamic _checkIndexOrFail (Map container, dynamic identifier, String identifierType) {
    if (container.containsKey(identifier)) {
      return container[identifier];
    }
    else {
      throw new CountryNotFoundException("[$identifierType: $identifier]");
    }
  }

  Map toMap () {
    Map curr = new Map.from(this.fields);
    curr["countries"] = new List<Map>();
    countries.forEach((Country c) {
      curr["countries"].add(c.toMap());
    });
    return curr;
  }
}