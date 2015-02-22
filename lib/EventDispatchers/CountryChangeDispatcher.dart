part of FinalEarthCrawler;

class CountryChangeDispatcher extends FinalEarthDispatcher {

  CountryChangeDispatcher (FinalEarthCrawler crawler):super(crawler);

  void _checkForEvents () {
    if (!_isCancelled) {
      this.crawler.onWorldUpdate.listen((WorldUpdateEvent event) {
        World previousWorld = event.previousWorld;
        if (previousWorld != null) {
          event.world.countries.forEach((Country country) {
            Country previousCountry = previousWorld.getCountryById(country.id);
            if (country != previousCountry) {
              List<String> changes = country.getDifferentFields(previousCountry);
              _eventStream.add(new CountryChangeEvent(country, previousCountry, changes));
            }
          });
        }
      });
    }
  }

}