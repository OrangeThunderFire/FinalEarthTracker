part of FinalEarthCrawler;

class UnitChangeDispatcher extends FinalEarthDispatcher {

  UnitChangeDispatcher (FinalEarthCrawler crawler):super(crawler);

  void _checkForEvents () {
    if (!_isCancelled) {
      this.crawler.onCountryChange.listen((CountryChangeEvent event) {
        if (this.unitsChanged(event.changedFields)) {
          Country current = event.currentCountry;
          Country previous = event.previousCountry;
          int changeInAxisUnits = current.axisUnits - previous.axisUnits;
          int changeInAlliesUnits = current.alliesUnits - previous.alliesUnits;
          _eventStream.add(new UnitChangeEvent(event.currentCountry, changeInAxisUnits, changeInAlliesUnits));
        }
      });
    }
  }

  bool unitsChanged (List<String> input) {
    return input.contains("axisUnits") || input.contains("alliesUnits");
  }
}