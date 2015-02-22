part of FinalEarthCrawler;

class TravelDetectDispatcher extends FinalEarthDispatcher {

  TravelDetectDispatcher (FinalEarthCrawler crawler):super(crawler);

  void _checkForEvents () {
    if (!_isCancelled) {
      this.crawler.onWorldUpdate.listen((WorldUpdateEvent event) {
        World previousWorld = event.previousWorld;
        if (previousWorld != null) {
          _dispatchTraveledCountries(event.previousWorld, event.world);

        }
      });
    }
  }

  // TODO: Refactor entirely
  // Gotta be a better way of doing this
  void _dispatchTraveledCountries (World previousWorld, World currentWorld) {
    Map<int, Country> alliedChanges = new Map<int, Country>();
    Map<int, Country> axisChanges = new Map<int, Country>();
    currentWorld.countries.forEach((Country country) {
      Country previous = previousWorld.getCountryById(country.id);
      if (country != previous) {
        print("Country modification detected");
        List<String> changes = country.getDifferentFields(previous);
        if (changes.contains("axisUnits") || changes.contains("alliesUnits")) {
          print("Unit modification detected");
          int changeInAxisUnits = country.axisUnits - previous.axisUnits;
          int changeInAlliesUnits = country.alliesUnits - previous.alliesUnits;
          print("$changeInAxisUnits $changeInAlliesUnits");
          if (changeInAlliesUnits != 0) {
            if (alliedChanges.containsKey(- changeInAlliesUnits)) {
              if (changeInAlliesUnits > 0) {
                _sendEvent(country, alliedChanges[-changeInAlliesUnits], TEAM.ALLIES, changeInAlliesUnits);
              }
              else {
                _sendEvent(alliedChanges[-changeInAlliesUnits], country, TEAM.ALLIES, -changeInAlliesUnits);
              }
            }
            else {
              alliedChanges[changeInAlliesUnits] = country;
            }
          }
          if (changeInAxisUnits != 0) {
            if (axisChanges.containsKey(- changeInAxisUnits)) {
              if (changeInAxisUnits > 0) {
                _sendEvent(country, axisChanges[-changeInAxisUnits], TEAM.AXIS, changeInAxisUnits);
              }
              else {
                _sendEvent(axisChanges[-changeInAxisUnits], country, TEAM.AXIS, -changeInAxisUnits);
              }
            }
            else {
              axisChanges[changeInAxisUnits] = country;
            }
          }

        }
      }
    });
  }
  void _sendEvent (Country to, Country from, TEAM team, int unitsMoved) {
    this._eventStream.add(new TravelDetectEvent(to, from, team, unitsMoved));
  }
}
