part of FinalEarthCrawler;

class CountryChangeEvent extends FinalEarthEvent {
  final Country previousCountry;
  final Country currentCountry;
  final List<String> changedFields;
  CountryChangeEvent (this.currentCountry, this.previousCountry, this.changedFields);
}