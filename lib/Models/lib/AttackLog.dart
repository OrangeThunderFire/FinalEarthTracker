part of FinalEarthModels;

class AttackLog extends FinalEarthModel {
  int logID;
  User attacker;
  User defender;
  List<UnitAmount> attackerUnitData;
  List<UnitAmount> defenderUnitData;
  int attackerLosses;
  int defenderLosses;
  DateTime time;

  AttackLog (this.logID, this.time,this.attacker, this.defender, this.attackerUnitData, this.defenderUnitData,
             this.attackerLosses, this.defenderLosses);

  AttackLog.fromJson (Map log) {
    this.logID = log["logID"];
    this.attacker = new User.fromJson(log["attacker"]);
    this.defender = new User.fromJson(log["defender"]);
    this.attackerLosses = log["attackerLosses"];
    this.defenderLosses = log["defenderLosses"];
    this.time = new DateTime.fromMillisecondsSinceEpoch(log["time"]);
    this.attackerUnitData = new List<UnitAmount>();
    this.defenderUnitData = new List<UnitAmount>();
    log["attackerUnitData"].forEach((Map unitData) {
      this.attackerUnitData.add(new UnitAmount.fromJson(unitData));
    });
    log["defenderUnitData"].forEach((Map unitData) {
      this.defenderUnitData.add(new UnitAmount.fromJson(unitData));
    });
  }

  Map toMap () {
    Map fields = this.fields;
    fields["time"] = this.time.millisecondsSinceEpoch;
    fields["attacker"] = this.attacker.toMap();
    fields["defender"] = this.defender.toMap();
    fields["attackerUnitData"] = new List();
    fields["defenderUnitData"] = new List();
    this.attackerUnitData.forEach((UnitAmount uAmt) {
      fields["attackerUnitData"].add(uAmt.toMap());
    });
    this.defenderUnitData.forEach((UnitAmount uAmt) {
      fields["defenderUnitData"].add(uAmt.toMap());
    });
    return fields;
  }
}