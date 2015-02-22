part of FinalEarthModels;

class Location extends FinalEarthModel {
  num latitude;
  num longitude;
  Location (num this.latitude, num this.longitude);
  Location.fromLocationJson (Map location) {
    this.latitude = location["latitude"];
    this.longitude = location["longitude"];
  }
  Map toMap() {
    return { "latitude": latitude, "longitude": longitude };
  }
}