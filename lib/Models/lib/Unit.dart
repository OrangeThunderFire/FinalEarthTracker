part of FinalEarthModels;

enum UnitType {
  SOLDIER,
  JEEP,
  TANK,
  AIR_CRAFT,
  CHOPPER,
  NAVAL
}

class Unit extends FinalEarthModel {
  static Map<int, Unit> _UNITS_ID_INDEX = new Map<int, Unit>();
  static Map<String, Unit> _UNITS_NAME_INDEX = new Map<int, Unit>();
  static bool _initialized = false;
  final String name;
  final UnitType type;
  final int cost;
  final TEAM team;
  final bool dies;
  final int ID;
  final int men;
  final String special;
  final bool unlockable;
  final int life;
  final int vsSoldiers;
  final int vsTanks;
  final int vsJeeps;
  final int vsPlanes;
  final int vsChoppers;
  final int vsNaval;
  final int vsFacilities;
  final int soldierSave;
  final int vehicleSave;

  Unit (this.name, this.type, this.cost, this.team, this.ID,
              this.life, this.vsSoldiers, this.vsTanks, this.vsJeeps,
              this.vsPlanes, this.vsChoppers, this.vsNaval, this.vsFacilities,
              this.soldierSave, this.vehicleSave, this.special, this.unlockable
              ,this.men);

  static void createAndAddUnit (String name, UnitType type, int cost, TEAM team, int ID,
                                int life, int vsSoldiers, int vsTanks, int vsJeeps,
                                int vsPlanes, int vsChoppers, int vsNaval, int vsFacilities,
                                int soldierSave, int vehicleSave, String special, bool unlockable
                                , int men) {
    Unit unit = new Unit (name, type, cost, team, ID, life, vsSoldiers, vsTanks, vsJeeps,
    vsPlanes, vsChoppers, vsNaval, vsFacilities, soldierSave, vehicleSave, special, unlockable, men);
    _UNITS_ID_INDEX[ID] = unit;
    _UNITS_NAME_INDEX[name] = unit;
  }

  static void addFromMap (int ID, Map unitData) {
    if (!Unit._UNITS_ID_INDEX.containsKey(ID)) {
      String name = unitData["name"];
      UnitType type;
      switch (unitData["type"]) {
        case "Soldier":
          type = UnitType.SOLDIER;
          break;
        case "Tank":
          type = UnitType.TANK;
          break;
        case "Jeep":
          type = UnitType.JEEP;
          break;
        case "Aircraft":
          type = UnitType.AIR_CRAFT;
          break;
        case "Chopper":
          type = UnitType.CHOPPER;
          break;
        case "Naval":
          type = UnitType.NAVAL;
          break;
      }
      TEAM team = (unitData["team"] == "1" ? TEAM.ALLIES : (unitData["team"] == "0" ? TEAM.NEUTRAL : TEAM.AXIS));
      int cost = int.parse(unitData["cost"]);
      int men = int.parse(unitData["men"]);
      int vsTanks = int.parse(unitData["tanks"]);
      int vsSoldiers = int.parse(unitData["soldiers"]);
      int vsJeeps = int.parse(unitData["jeeps"]);
      int vsPlanes = int.parse(unitData["planes"]);
      int vsChoppers = int.parse(unitData["choppers"]);
      int vsNaval = int.parse(unitData["naval"]);
      int vsFacilities = int.parse(unitData["facilities"]);
      int life = int.parse(unitData["life"]);
      int soldierSave = unitData["soldiersave"] != null ? int.parse(unitData["soldiersave"], onError: (String src) { return 0; }) : 0;
      int vehicleSave = unitData["vehiclesave"] != null ? int.parse(unitData["vehiclesave"], onError: (String src) { return 0; }) : 0;
      bool dies = unitData["die"] == "1";
      bool unlockable = unitData["donator"] == "1";
      String special = unitData["special"] == "0" ? "" : unitData["special"];
      Unit.createAndAddUnit(name, type, cost, team, ID, life, vsSoldiers, vsTanks, vsJeeps,
      vsPlanes, vsChoppers, vsNaval, vsFacilities, soldierSave, vehicleSave, special, unlockable, men);
    }
  }
  static void addFromUnitPageJSON (String json) {
    Map unitData = JSON.decode(json);
    unitData.forEach((int id, Map unitInfo) {
      Unit.addFromMap(id, unitInfo);
    });
  }

  static void init () {
    if (_initialized == false) {
      Unit.addFromUnitPageJSON(r'{"56":{"name":"Rebel","type":"Soldier","cost":"35000","team":"2","soldiers":"7","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"4","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"1","amount":"16363","special":"0"},"1":{"name":"Assault","type":"Soldier","cost":"100000","team":"0","soldiers":"15","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"10","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":"17778","special":"0"},"2":{"name":"Support","type":"Soldier","cost":"125000","team":"0","soldiers":"18","tanks":"0","jeeps":"0","planes":"0","choppers":"2","naval":"0","facilities":"0","life":"14","soldiersave":"1","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":"63846","special":"Cover infantry"},"7":{"name":"Suicide bomber","type":"Soldier","cost":"150000","team":"2","soldiers":"60","tanks":"50","jeeps":"70","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"2","soldiersave":"0","vehiclesave":"0","die":"1","men":"1","donator":"0","amount":null,"special":"0"},"3":{"name":"Anti-tank","type":"Soldier","cost":"200000","team":"0","soldiers":"3","tanks":"20","jeeps":"25","planes":"0","choppers":"4","naval":"0","facilities":"0","life":"10","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":null,"special":"0"},"4":{"name":"Medic","type":"Soldier","cost":"250000","team":"0","soldiers":"11","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"18","soldiersave":"5","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":"844","special":"Reduce infantry losses"},"10":{"name":"Vodnik","type":"Jeep","cost":"300000","team":"2","soldiers":"37","tanks":"0","jeeps":"0","planes":"0","choppers":"3","naval":"0","facilities":"0","life":"15","soldiersave":"0","vehiclesave":"0","die":"0","men":"4","donator":"0","amount":null,"special":"0"},"6":{"name":"Sniper","type":"Soldier","cost":"400000","team":"0","soldiers":"32","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"50","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"1","amount":"934","special":"0"},"8":{"name":"Special ops","type":"Soldier","cost":"750000","team":"0","soldiers":"45","tanks":"8","jeeps":"8","planes":"0","choppers":"3","naval":"2","facilities":"100","life":"63","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":"2897","special":"Spy and bombing"},"12":{"name":"Type 98","type":"Tank","cost":"2150000","team":"2","soldiers":"30","tanks":"140","jeeps":"61","planes":"5","choppers":"10","naval":"0","facilities":"0","life":"130","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"0","amount":null,"special":"0"},"58":{"name":"A-100 MLR","type":"Jeep","cost":"3000000","team":"2","soldiers":"400","tanks":"2","jeeps":"100","planes":"0","choppers":"0","naval":"2","facilities":"1","life":"125","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"1","amount":null,"special":"Bombardment"},"51":{"name":"BTR-80","type":"Jeep","cost":"3000000","team":"2","soldiers":"190","tanks":"50","jeeps":"83","planes":"0","choppers":"10","naval":"0","facilities":"0","life":"205","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"42":{"name":"BZK005","type":"Aircraft","cost":"3000000","team":"2","soldiers":"115","tanks":"60","jeeps":"60","planes":"0","choppers":"0","naval":"10","facilities":"3","life":"65","soldiersave":"0","vehiclesave":"0","die":"0","men":"0","donator":"1","amount":null,"special":"Spy and Air strike"},"16":{"name":"Tunguska M1","type":"Tank","cost":"3500000","team":"2","soldiers":"17","tanks":"5","jeeps":"6","planes":"80","choppers":"70","naval":"0","facilities":"0","life":"243","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"0","amount":null,"special":"0"},"52":{"name":"ZBD-97","type":"Tank","cost":"3500000","team":"2","soldiers":"250","tanks":"50","jeeps":"99","planes":"0","choppers":"20","naval":"0","facilities":"0","life":"207","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"60":{"name":"BREM-1","type":"Tank","cost":"5000000","team":"2","soldiers":"10","tanks":"0","jeeps":"10","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"360","soldiersave":"0","vehiclesave":"5","die":"0","men":"6","donator":"0","amount":null,"special":"Reduce vehicle losses"},"50":{"name":"Black Eagle","type":"Tank","cost":"8000000","team":"2","soldiers":"200","tanks":"500","jeeps":"350","planes":"4","choppers":"40","naval":"3","facilities":"0","life":"540","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"1","amount":null,"special":"0"},"28":{"name":"Mi-28 Havoc","type":"Chopper","cost":"13000000","team":"2","soldiers":"1380","tanks":"250","jeeps":"300","planes":"80","choppers":"80","naval":"25","facilities":"0","life":"175","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"0","amount":null,"special":"0"},"39":{"name":"Hind Mi35","type":"Chopper","cost":"17500000","team":"2","soldiers":"1728","tanks":"520","jeeps":"480","planes":"36","choppers":"250","naval":"30","facilities":"0","life":"352","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"45":{"name":"Changhe Z-8","type":"Chopper","cost":"20000000","team":"2","soldiers":"1150","tanks":"40","jeeps":"240","planes":"0","choppers":"80","naval":"0","facilities":"0","life":"650","soldiersave":"0","vehiclesave":"0","die":"0","men":"5","donator":"0","amount":null,"special":"0"},"24":{"name":"Xian JH-7","type":"Aircraft","cost":"23000000","team":"2","soldiers":"600","tanks":"390","jeeps":"490","planes":"100","choppers":"15","naval":"75","facilities":"30","life":"300","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":null,"special":"Air strike"},"29":{"name":"MiG-29 Fulcrum","type":"Aircraft","cost":"30000000","team":"2","soldiers":"25","tanks":"70","jeeps":"70","planes":"650","choppers":"425","naval":"50","facilities":"6","life":"770","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":null,"special":"Air strike"},"32":{"name":"Chengdu J-10","type":"Aircraft","cost":"32000000","team":"2","soldiers":"420","tanks":"380","jeeps":"415","planes":"198","choppers":"200","naval":"130","facilities":"28","life":"720","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"0","amount":null,"special":"Air strike"},"41":{"name":"Chengdu J-20","type":"Aircraft","cost":"120000000","team":"2","soldiers":"750","tanks":"750","jeeps":"700","planes":"1500","choppers":"1500","naval":"500","facilities":"100","life":"1800","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"1","amount":null,"special":"Air strike"},"18":{"name":"Destroyer","type":"Naval","cost":"150000000","team":"0","soldiers":"600","tanks":"1800","jeeps":"1800","planes":"900","choppers":"650","naval":"300","facilities":"16","life":"1125","soldiersave":"0","vehiclesave":"0","die":"0","men":"300","donator":"0","amount":null,"special":"Bombardment"},"19":{"name":"Submarine","type":"Naval","cost":"200000000","team":"0","soldiers":"0","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"1560","facilities":"0","life":"1620","soldiersave":"0","vehiclesave":"0","die":"0","men":"50","donator":"0","amount":null,"special":"0"},"20":{"name":"Cruiser","type":"Naval","cost":"350000000","team":"0","soldiers":"750","tanks":"1050","jeeps":"750","planes":"4800","choppers":"2400","naval":"200","facilities":"33","life":"2160","soldiersave":"0","vehiclesave":"0","die":"0","men":"800","donator":"0","amount":null,"special":"Bombardment"},"48":{"name":"Frigate","type":"Naval","cost":"500000000","team":"0","soldiers":"0","tanks":"0","jeeps":"0","planes":"2250","choppers":"1000","naval":"3250","facilities":"0","life":"2430","soldiersave":"0","vehiclesave":"0","die":"0","men":"250","donator":"0","amount":null,"special":"0"},"21":{"name":"Battleship","type":"Naval","cost":"700000000","team":"0","soldiers":"12000","tanks":"3600","jeeps":"7200","planes":"3000","choppers":"3000","naval":"1000","facilities":"66","life":"3240","soldiersave":"0","vehiclesave":"0","die":"0","men":"1500","donator":"0","amount":null,"special":"Bombardment"},"22":{"name":"Aircraft carrier","type":"Naval","cost":"2500000000","team":"0","soldiers":"15000","tanks":"15000","jeeps":"15000","planes":"11000","choppers":"10000","naval":"5000","facilities":"0","life":"9000","soldiersave":"0","vehiclesave":"0","die":"0","men":"2000","donator":"0","amount":null,"special":"0"},"47":{"name":"Nuclear Submarine","type":"Naval","cost":"5000000000","team":"0","soldiers":"0","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"13000","facilities":"0","life":"22500","soldiersave":"0","vehiclesave":"0","die":"0","men":"400","donator":"1","amount":null,"special":"0"},"46":{"name":"Super Carrier","type":"Naval","cost":"7000000000","team":"0","soldiers":"25000","tanks":"25000","jeeps":"25000","planes":"25000","choppers":"25000","naval":"25000","facilities":"8333","life":"29490","soldiersave":"0","vehiclesave":"0","die":"0","men":"2500","donator":"1","amount":null,"special":"Bombardment"}}');
      Unit.addFromUnitPageJSON(r'{"1":{"name":"Assault","type":"Soldier","cost":"100000","team":"0","soldiers":"15","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"10","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":null,"special":"0"},"2":{"name":"Support","type":"Soldier","cost":"125000","team":"0","soldiers":"18","tanks":"0","jeeps":"0","planes":"0","choppers":"2","naval":"0","facilities":"0","life":"14","soldiersave":"1","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":null,"special":"Cover infantry"},"3":{"name":"Anti-tank","type":"Soldier","cost":"200000","team":"0","soldiers":"3","tanks":"20","jeeps":"25","planes":"0","choppers":"4","naval":"0","facilities":"0","life":"10","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":null,"special":"0"},"4":{"name":"Medic","type":"Soldier","cost":"250000","team":"0","soldiers":"11","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"18","soldiersave":"5","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":null,"special":"Reduce infantry losses"},"9":{"name":"Humvee","type":"Jeep","cost":"250000","team":"1","soldiers":"32","tanks":"0","jeeps":"0","planes":"0","choppers":"2","naval":"0","facilities":"0","life":"12","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"57":{"name":"Anti-air","type":"Soldier","cost":"300000","team":"1","soldiers":"7","tanks":"0","jeeps":"0","planes":"4","choppers":"6","naval":"0","facilities":"0","life":"10","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"1","amount":null,"special":"0"},"6":{"name":"Sniper","type":"Soldier","cost":"400000","team":"0","soldiers":"32","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"50","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"1","amount":null,"special":"0"},"55":{"name":"Mortar Team","type":"Soldier","cost":"500000","team":"1","soldiers":"30","tanks":"1","jeeps":"45","planes":"0","choppers":"0","naval":"0","facilities":"0","life":"40","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"8":{"name":"Special ops","type":"Soldier","cost":"750000","team":"0","soldiers":"45","tanks":"8","jeeps":"8","planes":"0","choppers":"3","naval":"2","facilities":"100","life":"63","soldiersave":"0","vehiclesave":"0","die":"0","men":"1","donator":"0","amount":null,"special":"Spy and bombing"},"37":{"name":"IAV Stryker","type":"Jeep","cost":"2300000","team":"1","soldiers":"95","tanks":"35","jeeps":"61","planes":"5","choppers":"5","naval":"0","facilities":"0","life":"160","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"53":{"name":"AMX-30","type":"Tank","cost":"3000000","team":"1","soldiers":"30","tanks":"160","jeeps":"77","planes":"5","choppers":"10","naval":"0","facilities":"0","life":"166","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"49":{"name":"FV 510 Warrior","type":"Tank","cost":"4000000","team":"1","soldiers":"250","tanks":"50","jeeps":"70","planes":"0","choppers":"25","naval":"0","facilities":"0","life":"225","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"1","amount":null,"special":"0"},"61":{"name":"MRV Bison","type":"Tank","cost":"4000000","team":"1","soldiers":"10","tanks":"0","jeeps":"10","planes":"0","choppers":"10","naval":"0","facilities":"0","life":"306","soldiersave":"0","vehiclesave":"5","die":"0","men":"6","donator":"0","amount":null,"special":"Reduce vehicle losses"},"59":{"name":"M142 HIMARS","type":"Jeep","cost":"4000000","team":"1","soldiers":"400","tanks":"13","jeeps":"120","planes":"0","choppers":"0","naval":"2","facilities":"1","life":"150","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"1","amount":null,"special":"Bombardment"},"43":{"name":"Predator","type":"Aircraft","cost":"4500000","team":"1","soldiers":"150","tanks":"90","jeeps":"95","planes":"0","choppers":"0","naval":"15","facilities":"5","life":"90","soldiersave":"0","vehiclesave":"0","die":"0","men":"0","donator":"1","amount":null,"special":"Spy and Air strike"},"17":{"name":"M3A3 Bradley","type":"Tank","cost":"4500000","team":"1","soldiers":"40","tanks":"18","jeeps":"20","planes":"90","choppers":"95","naval":"0","facilities":"0","life":"306","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"13":{"name":"M1A2 Abram","type":"Tank","cost":"6200000","team":"1","soldiers":"60","tanks":"385","jeeps":"132","planes":"6","choppers":"30","naval":"3","facilities":"0","life":"400","soldiersave":"0","vehiclesave":"0","die":"0","men":"3","donator":"0","amount":null,"special":"0"},"27":{"name":"MD500 Defender","type":"Chopper","cost":"12000000","team":"1","soldiers":"1380","tanks":"200","jeeps":"240","planes":"80","choppers":"80","naval":"25","facilities":"0","life":"160","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"0","amount":null,"special":"0"},"40":{"name":"AH-64 Apache","type":"Chopper","cost":"19000000","team":"1","soldiers":"2060","tanks":"650","jeeps":"600","planes":"24","choppers":"300","naval":"30","facilities":"0","life":"385","soldiersave":"0","vehiclesave":"0","die":"0","men":"6","donator":"0","amount":null,"special":"0"},"44":{"name":"UH-60 Blackhawk","type":"Chopper","cost":"25000000","team":"1","soldiers":"1440","tanks":"50","jeeps":"300","planes":"0","choppers":"100","naval":"0","facilities":"0","life":"750","soldiersave":"0","vehiclesave":"0","die":"0","men":"4","donator":"0","amount":null,"special":"0"},"26":{"name":"F-16 Viper","type":"Aircraft","cost":"28000000","team":"1","soldiers":"300","tanks":"200","jeeps":"200","planes":"170","choppers":"200","naval":"50","facilities":"25","life":"520","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"0","amount":null,"special":"Air strike"},"30":{"name":"F-15 Eagle","type":"Aircraft","cost":"32000000","team":"1","soldiers":"25","tanks":"50","jeeps":"50","planes":"680","choppers":"470","naval":"64","facilities":"6","life":"750","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"0","amount":null,"special":"Air strike"},"31":{"name":"Panavia Tornado","type":"Aircraft","cost":"33000000","team":"1","soldiers":"825","tanks":"860","jeeps":"1125","planes":"165","choppers":"50","naval":"100","facilities":"40","life":"660","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"0","amount":null,"special":"Air strike"},"18":{"name":"Destroyer","type":"Naval","cost":"150000000","team":"0","soldiers":"600","tanks":"1800","jeeps":"1800","planes":"900","choppers":"650","naval":"300","facilities":"16","life":"1125","soldiersave":"0","vehiclesave":"0","die":"0","men":"300","donator":"0","amount":null,"special":"Bombardment"},"19":{"name":"Submarine","type":"Naval","cost":"200000000","team":"0","soldiers":"0","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"1560","facilities":"0","life":"1620","soldiersave":"0","vehiclesave":"0","die":"0","men":"50","donator":"0","amount":null,"special":"0"},"20":{"name":"Cruiser","type":"Naval","cost":"350000000","team":"0","soldiers":"750","tanks":"1050","jeeps":"750","planes":"4800","choppers":"2400","naval":"200","facilities":"33","life":"2160","soldiersave":"0","vehiclesave":"0","die":"0","men":"800","donator":"0","amount":null,"special":"Bombardment"},"48":{"name":"Frigate","type":"Naval","cost":"500000000","team":"0","soldiers":"0","tanks":"0","jeeps":"0","planes":"2250","choppers":"1000","naval":"3250","facilities":"0","life":"2430","soldiersave":"0","vehiclesave":"0","die":"0","men":"250","donator":"0","amount":null,"special":"0"},"21":{"name":"Battleship","type":"Naval","cost":"700000000","team":"0","soldiers":"12000","tanks":"3600","jeeps":"7200","planes":"3000","choppers":"3000","naval":"1000","facilities":"66","life":"3240","soldiersave":"0","vehiclesave":"0","die":"0","men":"1500","donator":"0","amount":null,"special":"Bombardment"},"36":{"name":"B-2 Stealth bomber","type":"Aircraft","cost":"900000000","team":"1","soldiers":"8000","tanks":"8000","jeeps":"8000","planes":"0","choppers":"0","naval":"8000","facilities":"1200","life":"12000","soldiersave":"0","vehiclesave":"0","die":"0","men":"2","donator":"1","amount":null,"special":"Air strike"},"22":{"name":"Aircraft carrier","type":"Naval","cost":"2500000000","team":"0","soldiers":"15000","tanks":"15000","jeeps":"15000","planes":"11000","choppers":"10000","naval":"5000","facilities":"0","life":"9000","soldiersave":"0","vehiclesave":"0","die":"0","men":"2000","donator":"0","amount":null,"special":"0"},"47":{"name":"Nuclear Submarine","type":"Naval","cost":"5000000000","team":"0","soldiers":"0","tanks":"0","jeeps":"0","planes":"0","choppers":"0","naval":"13000","facilities":"0","life":"22500","soldiersave":"0","vehiclesave":"0","die":"0","men":"400","donator":"1","amount":null,"special":"0"},"46":{"name":"Super Carrier","type":"Naval","cost":"7000000000","team":"0","soldiers":"25000","tanks":"25000","jeeps":"25000","planes":"25000","choppers":"25000","naval":"25000","facilities":"8333","life":"29490","soldiersave":"0","vehiclesave":"0","die":"0","men":"2500","donator":"1","amount":null,"special":"Bombardment"}}');
      _initialized = true;
    }
  }

  static Unit getById(int ID) {
    Unit.init();
    if (_UNITS_ID_INDEX.containsKey(ID)) {
      return _UNITS_ID_INDEX[ID];
    }
    // TODO: Throw error
    return;
  }

  static List<Unit> getByType (UnitType type) {

    Unit.init();
    return _UNITS_ID_INDEX.values.where((Unit elem) { return elem.type == type; }).toList();
  }
  static Unit getByName (String name) {
    Unit.init();
    if (_UNITS_NAME_INDEX.containsKey(name)) {
      return _UNITS_NAME_INDEX[name];
    }
    // TODO: throw error
    return;
  }
}
