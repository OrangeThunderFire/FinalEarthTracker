part of FinalEarthCrawler;

class FacilityChangeDispatcher extends FinalEarthDispatcher {

  List<String> _watchedFields = [
      "airDefences",
      "groundDefences",
      "factories",
      "mines",
      "oilRigs"
  ];

  FacilityChangeDispatcher (FinalEarthCrawler crawler):super(crawler);

  void _checkForEvents () {
    if (!_isCancelled) {
      this.crawler.onCountryChange.listen((CountryChangeEvent event) {
        if (this.facilitiesChanged(event.changedFields)) {
          Country current = event.currentCountry;
          Country previous = event.previousCountry;
          int airDefencesChanged = current.airDefences - previous.airDefences;
          int groundDefencesChanged = current.groundDefences - previous.groundDefences;
          num factoriesChanged = current.factories - previous.factories;
          num minesChanged = current.mines - previous.mines;
          int oilRigsChanged = current.oilRigs - previous.oilRigs;

          _eventStream.add(new FacilityChangeEvent(current,
            groundDefences: groundDefencesChanged,
            airDefences: airDefencesChanged,
            factories: factoriesChanged,
            oilRigs: oilRigsChanged,
            mines: minesChanged
          ));
        }
      });
    }
  }
  bool facilitiesChanged (List<String> input) {
    for (int i = 0; i < _watchedFields.length; i++) {
      if (input.contains(_watchedFields[i])) {
        return true;
      }
    }
    return false;
  }
}