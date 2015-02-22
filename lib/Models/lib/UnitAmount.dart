part of FinalEarthModels;

class UnitAmount extends FinalEarthModel {
  /// Unit amount that was lost in attack - Misleading name: Couldnt change due to db structure.
  int amount;
  /// This is the unit total before amount is subtracted
  int left;
  // The actual total units they have of this type
  get total => left - amount;
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