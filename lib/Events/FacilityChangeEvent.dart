part of FinalEarthCrawler;


class FacilityChangeEvent extends FinalEarthEvent {
  final Country country;
  final int groundDefences;
  final int airDefences;
  final num mines;
  final int oilRigs;
  final num factories;
  FacilityChangeEvent (this.country, { this.groundDefences: 0, this.airDefences: 0, this.mines: 0, this.oilRigs: 0, this.factories: 0 });
}