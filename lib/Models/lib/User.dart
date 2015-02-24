part of FinalEarthModels;

class User extends FinalEarthModel {
  String name;
  int id;
  TEAM team;
  List<UnitAmount> knownUnits;
  int losses = 0;
  int dealt = 0;
  List<int> attackLogIds = new List<int>();
  User (this.id, this.name, this.team, this.knownUnits, this.losses, this.dealt, this.attackLogIds);

  User.fromJson (Map json) {
    this.id = json["id"];
    this.name = json["name"];
    this.team = convertTeamFromString(json["team"]);
    this.knownUnits = new List();
    json["knownUnits"].forEach((Map unitAmt) {
      this.knownUnits.add(new UnitAmount.fromJson(unitAmt));
    });
    this.losses = json["losses"];
    this.dealt = json["dealt"];
    this.attackLogIds = json["attackLogIds"];
  }


  Map toMap() {
    Map fields = this.fields;
    fields["team"] = convertTeamToString(this.team);
    fields["knownUnits"] = new List();
    this.knownUnits.forEach((UnitAmount uAmt) {
      fields["knownUnits"].add(uAmt.toMap());
    });
    return fields;
  }
}