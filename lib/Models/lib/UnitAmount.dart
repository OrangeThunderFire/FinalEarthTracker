part of FinalEarthModels;

class UnitAmount extends FinalEarthModel {
  int amount;
  int left;
  Unit unit;
  UnitAmount (this.amount, this.left, this.unit);

  UnitAmount.fromJson (Map unitData) {
    this.amount = unitData["amount"];
    this.left = unitData["left"];
    this.unit = Unit.getById(unitData["unitID"]);
  }

  Map toMap () {
    return {"amount": amount, "left": left, "unitID": unit.ID};
  }
}