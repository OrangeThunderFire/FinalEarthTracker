part of FinalEarthCrawler;

class UnitChangeEvent extends FinalEarthEvent {
  final Country country;
  final int axisUnits;
  final int alliesUnits;
  UnitChangeEvent (this.country, this.axisUnits, this.alliesUnits);
}