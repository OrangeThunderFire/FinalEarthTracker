part of FinalEarthExceptions;

class CountryNotFoundException implements FinalEarthException {
  final String countryIdentifier;

  CountryNotFoundException(this.countryIdentifier);

  String toString() {
    return "Exception: $countryIdentifier was not found.";
  }
}