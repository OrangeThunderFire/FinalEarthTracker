part of FinalEarthModels;

class AttackLog extends FinalEarthModel {
  int logID;
  String attackerName;
  String defenderName;
  int attackerID;
  int defenderID;
  List<UnitAmount> attackerUnitData;
  List<UnitAmount> defenderUnitData;
  int attackerLosses;
  int defenderLosses;
  DateTime time;

  AttackLog (this.logID, this.time, this.attackerName, this.defenderName, this.attackerID,
             this.defenderID, this.attackerUnitData, this.defenderUnitData,
             this.attackerLosses, this.defenderLosses);

  AttackLog.fromJson (Map log) {
    this.logID = log["logID"];
    this.attackerName = log["attackerName"];
    this.defenderName = log["defenderName"];
    this.attackerID = log["attackerID"];
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