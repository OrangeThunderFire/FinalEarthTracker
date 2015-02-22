part of FinalEarthCrawler;

class TravelDetectEvent extends FinalEarthEvent {
  final Country countryFrom;
  final Country countryTo;
  final TEAM team;
  final int units;
  TravelDetectEvent (this.countryTo, this.countryFrom, this.team, this.units);
}