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
  bool isNukeLog = false;
  int destroyAmount = 0;

  AttackLog (this.logID, this.time,this.attacker, this.defender, this.attackerUnitData, this.defenderUnitData,
             this.attackerLosses, this.defenderLosses, [this.isNukeLog = false, this.destroyAmount = 0]);

  AttackLog.fromJson (Map log) {
    this.logID = log["logID"];
    if (log.containsKey("attacker") && log["attacker"] != null) {
      this.attacker = new User.fromJson(log["attacker"]);
    }
    this.defender = new User.fromJson(log["defender"]);

    this.attackerLosses = log["attackerLosses"];
    this.isNukeLog = log["isNukeLog"];
    this.defenderLosses = log["defenderLosses"];
    this.time = new DateTime.fromMillisecondsSinceEpoch(log["time"]);
    this.attackerUnitData = new List<UnitAmount>();
    this.defenderUnitData = new List<UnitAmount>();
    this.destroyAmount = log["destroyAmount"];

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
    fields["defender"] = this.defender.toMap();
    fields["attackerUnitData"] = new List();
    fields["defenderUnitData"] = new List();
    fields["attacker"] = null;
    if (!this.isNukeLog) {
      fields["attacker"] = this.attacker.toMap();
      this.attackerUnitData.forEach((UnitAmount uAmt) {
        fields["attackerUnitData"].add(uAmt.toMap());
      });
    }
    this.defenderUnitData.forEach((UnitAmount uAmt) {
      fields["defenderUnitData"].add(uAmt.toMap());
    });
    return fields;
  }
}