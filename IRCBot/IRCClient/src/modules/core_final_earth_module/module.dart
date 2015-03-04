library CoreFinalEarthModule;

import '../../module/main.dart';
import 'dart:async';
import 'dart:io';
import "dart:convert";
import "package:intl/intl.dart";
import 'package:math_expressions/math_expressions.dart';
import 'package:dirty/dirty.dart';
import "../../../../../lib/Models/lib/Models.dart";

enum SERVER_PACKETS {
DISCONNECT_SERVER,
WORLD_UPDATE_EVENT,
COUNTRY_UPDATE_EVENT,
UNIT_UPDATE_EVENT,
FACILITY_UPDATE_EVENT,
TRAVEL_DETECT_EVENT,
ATTACK_MADE_EVENT,
USER_DATA_RESPONSE,
USER_NOT_FOUND
}
enum CLIENT_PACKETS {
SUBSCRIBE_TO_EVENT,
UNSUBSCRIBE_FROM_EVENT,
GET_USER_DATA
}

String theme = "${k}07";
void main (args, ModuleStartPacket packet) {
  Language.add("Testing", "${theme}Testing this shitty IRC bot");
  Language.add("SUBSCRIBE", "${theme}Subscribed to event ${b}&1${b}");
  Language.add("UNIT_UPDATE", "${theme} Unit Change - ${b}&1${b} - Axis Units: ${b}&2${b} (Total: &4) Allied Units: ${b}&3${b} (Total: &5)");
  CoreModule cm = new CoreModule(packet);
}


class CoreModule extends Module {
  static  List<String> idCommands = new List<String>();
  World currentWorld;
  WebSocket socket;
  String version = "v0.3";
  bool suppressAttackLogs = false;
  Timer postCountryUpdate;
  Dirty storage = new Dirty("quick.db");

  Map<Country, Country> countriesToNotify = new Map<Country, Country>();

  CoreModule (ModuleStartPacket packet):super(packet) {

    WebSocket.connect("ws://127.0.0.1:8080/websocket").then((WebSocket ws) {
      this.socket = ws;

      this.socket.listen(this._onWebSocketData, onError: () {
        this.SendMessage(new ChannelName("#allies"), "$theme$b[Error]$b An error has occurred and the back end server has closed.");
      }, onDone:() {
        this.SendMessage(new ChannelName("#allies"), "$theme$b[Error]$b An error has occurred and the back end server has closed.");
      });
      subscribeEvent("UnitUpdateEvent");
      subscribeEvent("FacilityUpdateEvent");
      subscribeEvent("WorldUpdateEvent");
      subscribeEvent("CountryUpdateEvent");
      subscribeEvent("AttackMadeEvent");
    });
  }
  void subscribeEvent (String eventName) {
    this.socket.add('{ "ID": ${CLIENT_PACKETS.SUBSCRIBE_TO_EVENT.index}, "eventName": "${eventName}" }');
  }

  void getUser (String userName) {
    this.socket.add(JSON.encode({ "ID": CLIENT_PACKETS.GET_USER_DATA.index, "name": userName }));
  }

  String formatTeam (String team,[ dynamic message = null]) {
    if (message == null) message = "$b$team$b";
    return (team == "Axis" ? "${k}04$message${theme}" : (team == "Allies" ? "${k}03$message${theme}" : "${k}14$message${theme}"));
  }


  String formatUnitChange (Country country,int axisUnits, int alliesUnits) {
    return "${theme}[${new DateFormat("HH:mm:ss").format(new DateTime.now())}] ${formatCountry(country)}"
    "${(axisUnits != 0 ? " ${(axisUnits > 0 ? "+" : "")}$axisUnits ${formatTeam("Axis")} ${(alliesUnits != 0 ? "and": "units")}" : "")}"
    "${(alliesUnits != 0 ? " ${(alliesUnits > 0 ? "+" : "")}$alliesUnits ${formatTeam("Allies")} units" : "")}";
  }

  String formatCountry (Country country) {
    return "${formatTeam(convertTeamToString(country.controllingTeam),country.name)}"
    " (${formatTeam("Allies","${country.control}%")}|${formatTeam("Axis", country.axisUnits)}|"
    "${formatTeam("Allies", country.alliesUnits)})";
  }

  int getDistance (Country countryOne, Country countryTwo) {



  }

  void SendMessage (Target target, String message, [String splitOn = " "]) {
    if (message.length > 240) {
      List<String> messages = message.split(splitOn);
      int currLen = theme.length; // for theme
      String currMessage = "$theme";
      for (int x = 0; x < messages.length; x++) {
        if ((currLen + (messages[x].length+1)) <= 400) {
          currLen += messages[x].length + 1;
          currMessage = "$currMessage${(x == 0 ? "" : splitOn)}${messages[x]}";
        }
        else {
          super.SendMessage(target, currMessage);
          currMessage = "$theme${messages[x]}";
          currLen = currMessage.length;
        }
      }
      if (currMessage.length != 0) {
        super.SendMessage(target, currMessage);
      }
    }
    else {
      super.SendMessage(target, message);
    }
  }
  void _onWebSocketData(String packet) {
    Map data = JSON.decode(packet);
    if (data["ID"] == SERVER_PACKETS.UNIT_UPDATE_EVENT.index) {
      this.SendMessage(new ChannelName("#Allies"),
        this.formatUnitChange(new Country.fromCountryJson(data["country"]), data["axisUnits"], data["alliesUnits"]));
    }
    if (data["ID"] == SERVER_PACKETS.WORLD_UPDATE_EVENT.index) {
      currentWorld = new World.fromWorldJson(data["world"]);
    }

    if (data["ID"] == SERVER_PACKETS.COUNTRY_UPDATE_EVENT.index) {
      if (data["changedFields"].contains("land")) {
        Country c = new Country.fromCountryJson(data["country"]);
        if (c.land == 0) {
          this.SendMessage(new ChannelName("#Allies"), "$k04$b[WARNING]$b ${c.name} has been destroyed.");
        }
      }
      if (data["changedFields"].contains("control")) {

        if (postCountryUpdate != null && postCountryUpdate.isActive) {
          postCountryUpdate.cancel();
        }
        countriesToNotify[new Country.fromCountryJson(data["previousCountry"])] = new Country.fromCountryJson(data["country"]);
        postCountryUpdate = new Timer (new Duration(seconds: 1), this._sendCountryUpdates);
      }

    }
    if (data["ID"] == SERVER_PACKETS.ATTACK_MADE_EVENT.index) {
      if (!suppressAttackLogs) {
        this.SendMessage(new ChannelName("#Allies"), this.formatAttackLog(new AttackLog.fromJson(data["attackLog"])));
      }
    }

    if (data["ID"] == SERVER_PACKETS.USER_DATA_RESPONSE.index) {
      this.outputUser(new ChannelName("#Allies"),new User.fromJson(data["user"]));
    }

    if (data["ID"] == SERVER_PACKETS.USER_NOT_FOUND.index) {
      this.SendMessage(new ChannelName("#Allies"),"$theme$b[User Information]$b I do not know of that user, please make sure you use the correct capitalization of the name.");
    }
  }
  void _sendCountryUpdates () {
    List<Map<String, dynamic>> teamCountries = new List<Map<String, dynamic>>();
    this.countriesToNotify.forEach((Country previousCountry, Country currentCountry) {
      if (currentCountry.control > previousCountry.control) {
        // Allies Gain or Neutral takeover
        if (currentCountry.alliesUnits <= 0) {
          // Neutral takeover
          teamCountries.add({ "type": "neutralLoss", "team": TEAM.AXIS, "percent": previousCountry.control - currentCountry.control, "country": currentCountry  });
        }
        else {
          teamCountries.add({ "type": "gain", "team": TEAM.ALLIES, "percent": currentCountry.control - previousCountry.control, "country": currentCountry });
        }
      }
      if (currentCountry.control < previousCountry.control) {
        if (currentCountry.axisUnits <= 0) {
          teamCountries.add({ "type": "neutralLoss", "team": TEAM.ALLIES, "percent": 0-(previousCountry.control - currentCountry.control), "country": currentCountry  });
        }
        else {
          teamCountries.add({ "type": "gain", "team": TEAM.AXIS, "percent": 0-(currentCountry.control - previousCountry.control), "country": currentCountry });
        }
      }
    });
    this.countriesToNotify.clear();
    String axisNeutralMessage = teamCountries.where((Map element) { return element["team"] == TEAM.AXIS && element["type"] == "neutralLoss"; })
                                      .map((Map element) { return "(${element["percent"]}%) ${formatCountry(element["country"])}"; })
                                      .join(", ");
    String axisGainedMessage = teamCountries.where((Map element) { return element["team"] == TEAM.AXIS && element["type"] == "gain"; })
    .map((Map element) { return "(+${element["percent"]}%) ${formatCountry(element["country"])}"; })
    .join(", ");
    String alliedNeutralMessage = teamCountries.where((Map element) { return element["team"] == TEAM.ALLIES && element["type"] == "neutralLoss"; })
    .map((Map element) { return "(${element["percent"]}%) ${formatCountry(element["country"])}"; })
    .join(", ");
    String alliedGainedMessage = teamCountries.where((Map element) { return element["team"] == TEAM.ALLIES && element["type"] == "gain"; })
    .map((Map element) { return "(+${element["percent"]}%) ${formatCountry(element["country"])}"; })
    .join(", ");

//    this.SendMessage(new ChannelName("#Allies"), "$theme$b[Hour Update]$b The ${formatTeam("Axis")} gained control in ${axisGainedMessage}",",");
//    this.SendMessage(new ChannelName("#Allies"), "$theme$b[Hour Update]$b The ${formatTeam("Axis")} lost control to local malitia in ${axisNeutralMessage}", ",");
//
//    this.SendMessage(new ChannelName("#Allies"), "$theme$b[Hour Update]$b The ${formatTeam("Allies")} gained control in ${alliedGainedMessage}",",");
//    this.SendMessage(new ChannelName("#Allies"), "$theme$b[Hour Update]$b The ${formatTeam("Allies")} lost control to local malitia in ${alliedNeutralMessage}",",");

  }
  String outputUser (ChannelName chName, User user) {
    this.SendMessage(chName, "$theme$b[User Information]$b ${formatUser(user)} - \$${formatNum(user.losses)} losses, \$${formatNum(user.dealt)} destroyed");
    String unitInfo = user.knownUnits.where((UnitAmount umt) { return umt.total > 0; }).map((UnitAmount umt) {

        return "${formatTeam(convertTeamToString(umt.unit.team), umt.unit.name)}: ${formatNum(umt.total)} (\$${formatNum(umt.total * umt.unit.cost)})";
    }).join (", ");
    this.SendMessage(chName, "$theme$b[Unit Information]$b ${unitInfo.length > 0 ? unitInfo : "This user has no known units."}", ",");

  }
  dynamic gMValue(Map map, dynamic key, [dynamic def = 0]) {
    if (map.containsKey(key)) {
      return map[key];
    }
    return def;
  }
  String formatUser (User user) {
    Map<UnitType, int> typeAmounts= new Map<UnitType, int>();
    user.knownUnits.forEach((UnitAmount uae) {
      if (!typeAmounts.containsKey(uae.unit.type)) {
        typeAmounts[uae.unit.type] = 0;
      }
      typeAmounts[uae.unit.type] += uae.total;
    });
    return "${formatTeam(convertTeamToString(user.team),user.name)} (F:${gMValue(typeAmounts,UnitType.SOLDIER)}|J:${gMValue(typeAmounts,UnitType.JEEP)}|T:${gMValue(typeAmounts,UnitType.TANK)}|C:${gMValue(typeAmounts,UnitType.CHOPPER)}|A:${gMValue(typeAmounts,UnitType.AIR_CRAFT)}|N:${gMValue(typeAmounts,UnitType.NAVAL)})";
  }
  String formatAttackLog(AttackLog log) {
    if (log.isNukeLog) {
      return "$theme$b[Nuke][${new DateFormat("hh:mm:ss d/M").format(log.time)}]$b Nuke detonated destroying $b${log.destroyAmount}%$b of ${formatUser(log.defender)} units - ${u}http://finalearth.com/game#details/logUser?ID=${log.logID}";
    }
    else {
      return "$theme$b[Attack][${new DateFormat("hh:mm:ss d/M").format(log.time)}]$b ${formatUser(log.attacker)}"
      "(-\$${formatNum(log.attackerLosses)}) vs ${formatUser(log.defender)} (-\$${formatNum(log.defenderLosses)}) - ${u}http://finalearth.com/game#details/logUser?ID=${log.logID}";

    }
  }
  String formatNum (num number) {
    if (number != null) {
      return "${new NumberFormat("###,###,###,###,###", "en_US").format(number.round())}";
    }
    else {
      return "0";
    }
  }

  Country getCountry (String nameOrCountryCode) {
    try {
      if (currentWorld != null && nameOrCountryCode != null) {
        Country country;
        try {
          country = currentWorld.getCountryByName(nameOrCountryCode);
        }
        catch (E) {
          country = currentWorld.getCountryByCountryCode(nameOrCountryCode);
        }
        if (country != null) {
          return country;
        }
      }
    }
    catch (E) {
    }
    return null;
  }
  
  bool onChannelMessage (Nickname user, PrivMsgCommand command) {
    if (command.get(0) == "!sub") {
      this.SendMessage(command.target,Language.get("SUBSCRIBE",[command.get(1)]));
      subscribeEvent(command.get(1));
    }
    if (command.get(0) == "!calc") {
      String s2on = command.get(1, command.getl());
      if (s2on != "") {
        List<String> calc = s2on.split(new RegExp(r" ?> ?"));
        try {
        ContextModel cm = new ContextModel();
        if (calc.length > 1) {
          List<String> vars = calc[1].split(new RegExp(r", ?"));
          vars.forEach((String variable) {
            List<String> variableInp = variable.split(new RegExp(r" ?= ?"));
            if (variableInp.length == 2) {
              cm.bindVariableName(variableInp[0].trim(), new Number(num.parse(variableInp[1].trim())));

            }
          });
        }
          Parser p = new Parser();
          Expression exp = p.parse(calc[0]);

          num eval = exp.evaluate(EvaluationType.REAL, cm);
          this.SendMessage(command.target, "${theme}$b[!CALC]$b ${exp.simplify()} = $eval");
        }
        catch (E) {
          this.SendMessage(command.target, "$theme$b[!CALC]$b Could not parse the input. ${E}");
        }
      }
    }
    if (command.get(0) == "!dis") {
      RegExp percentReg = new RegExp(r"[0-9]+?%");
      int percent = 0;
      int from = 1;
      if (percentReg.hasMatch(command.get(1))) {
        percent = int.parse(command.get(1).replaceAll("%",""), onError: (String src) {
          return 0;
        });
        from = 2;
      }
      String restOfCommand = command.get(from, command.getl());
      List<String> hops = restOfCommand.split(new RegExp(" ?- ?"));
      if (hops.length > 1) {
        Country prevCountry;
        List<String> currentHops = new List<String>();
        Duration totalDuration = new Duration(seconds: 0);
        while (hops.length != 0) {
          String cName = hops.removeAt(0);
          Country country = this.getCountry(cName.trim());
          if (country != null) {
            if (prevCountry != null) {
              Duration hopDuration = prevCountry.getTravelDuration(country, percent);
              totalDuration = new Duration(microseconds: totalDuration.inMicroseconds + hopDuration.inMicroseconds);
              currentHops.add("${prevCountry.countryCode} to ${country.countryCode} (${formatNum(prevCountry.getDistance(country))}km) (${hopDuration.toString()})");
            }
            prevCountry = country;
          }
          else {
            this.SendMessage(command.target, "$theme$b[Distance]$b I could not find the country: ${command.get(1, command.getl())}");
            return;
          }
        }
        if (currentHops.isNotEmpty) {
          this.SendMessage(command.target, "$theme$b[Distance]$b ${currentHops.join(", ")} - Total Travel Time${percent != 0 ? " with bonus $percent%:": ":"} ${totalDuration.toString()}");
        }
      }
      else {
        this.SendMessage(command.target, "$theme$b[Distance]$b You must specify atleast 2 countries to work out the distance. Eg !dis US-GB");
      }
    }
    if (command.get(0) == "!topfactories" && currentWorld != null) {
      List<Country> factoryListSort = new List.from(this.currentWorld.countries)..sort((Country a, Country b) {
        return b.factories - a.factories;
      });
      String message = factoryListSort.getRange(0, 10).map((Country c) {
        return "${this.formatCountry(c)} (${formatNum(c.factories)} facs)";
      }).join(", ");
      this.SendMessage(command.target, "$theme$b[Top Factories]$b $message", ",");
    }

    if (command.get(0) == "!toprigs" && currentWorld != null) {
      List<Country> listSort = new List.from(this.currentWorld.countries)..sort((Country a, Country b) {
        return b.oilRigs - a.oilRigs;
      });
      String message = listSort.getRange(0, 10).map((Country c) {
        return "${this.formatCountry(c)} (${formatNum(c.oilRigs)} rigs)";
      }).join(", ");
      this.SendMessage(command.target, "$theme$b[Top Rigs]$b $message", ",");
    }
    if (command.get(0) == "!topmines" && currentWorld != null) {
      List<Country> listSort = new List.from(this.currentWorld.countries)..sort((Country a, Country b) {
        return b.mines - a.mines;
      });
      String message = listSort.getRange(0, 10).map((Country c) {
        return "${this.formatCountry(c)} (${formatNum(c.mines)} mines)";
      }).join(", ");
      this.SendMessage(command.target, "$theme$b[Top Mines]$b $message", ",");
    }
    if (command.get(0) == "!info") {
      Country country = this.getCountry(command.get(1, command.getl()));
      if(country != null) {
        this.SendMessage(command.target, "$theme$b[Info]$b ${formatCountry(country)}", ",");
      }
      else {
        this.SendMessage(command.target, "$theme$b[Info]$b I could not find that country - ${command.get(1, command.getl())}");
      }

    }
    if (command.get(0) == "!suppressLogs") {
      this.suppressAttackLogs = !suppressAttackLogs;
    }
    if (command.get(0) == "!user" && command.get(1) != "") {
      String name = command.get(1);
      this.getUser(name);
    }
    if (command.get(0) == "!units") {
      if (currentWorld != null) {
        int min = 0;
        int max = 0;
        List minMax = command.get(1).split(new RegExp(" ?- ?"));
        if (minMax.length == 2) {

          min = int.parse(minMax[0], onError: (String inp) { return 0; });
          max = int.parse(minMax[1], onError: (String inp) { return 0; });
        }
        if (minMax.length <= 1) {
          max = int.parse(minMax[0], onError: (String inp) { return 999999999; });
        }
        List<String> unitsStr = currentWorld.countries.where((Country e) {
          return (e.axisUnits > min && e.axisUnits < max) || (e.alliesUnits > min && e.alliesUnits < max);
        }).map((Country e) {
          return formatCountry(e);
        }).toList();
        this.SendMessage(command.target, "$theme$b[Unit Search] Countries where units are between $min - $max:");
        for (int i = 0; i < unitsStr.length; i+=7) {
          this.SendMessage(command.target, "$theme$b[Results] ${unitsStr.getRange(i, (i+7 > unitsStr.length ? unitsStr.length : i+7)).join(", ")}", ",");
        }
      }
    }
    if (command.get(0) == "!module") {
      this.SendMessage(command.target,"Module VERSION $version");
    }
    if (command.get(0) == "!totals") {
      if (currentWorld != null) {
        Map<TEAM, Map<String, int>> totals = new Map<TEAM, Map<String, num>>();
        num axisUnitsTotal = 0;
        num alliesUnitsTotal = 0;
        List definedCountries = currentWorld.countries;
        if (!command.get(1).isEmpty) {
          String regionName = command.get(1, command.getl());
          try {
            if (regionName.toUpperCase() == "AMERICAS") {
              definedCountries = new List.from(currentWorld.getCountriesByRegion("North America"));
              definedCountries.addAll(currentWorld.getCountriesByRegion("South America"));
            }
            else {
              definedCountries = currentWorld.getCountriesByRegion(regionName);
            }
          }
          catch (E) {
            this.SendMessage(command.target,"$theme$b[Totals]$b Could not find region $regionName");
            return;
          }
        }
        num totalPercent = definedCountries.length * 100;
        totals[TEAM.NEUTRAL] = new Map<String, num>();
        definedCountries.forEach((Country c) {
          if (!totals.containsKey(c.controllingTeam)) {
            totals[c.controllingTeam] = new Map<String, int>();
          }
          Map container = totals[c.controllingTeam];
          int teamControl = (c.controllingTeam == TEAM.NEUTRAL ? 100 : (c.controllingTeam == TEAM.AXIS ? 100 - c.control : c.control));

          if (c.controllingTeam == TEAM.NEUTRAL && teamControl != 100) {
            this.SendMessage(command.target, "Error on country ${c.name} ${c.control}");
          }
          if (teamControl == 100) {
            addMap(container, "factories", c.factories);
            addMap(container, "mines", c.mines);
            addMap(container, "oilRigs", c.oilRigs);
          }
          else {

            addMap(totals[TEAM.NEUTRAL], "factories", c.factories);
            addMap(totals[TEAM.NEUTRAL], "mines", c.mines);
            addMap(totals[TEAM.NEUTRAL], "oilRigs", c.oilRigs);
            addMap(totals[TEAM.NEUTRAL], "totalPercent", 100-teamControl);
          }

          addMap(container, "axisUnits", c.axisUnits);
          addMap(container, "alliesUnits", c.alliesUnits);
          addMap(container, "totalPercent", teamControl);
          axisUnitsTotal += c.axisUnits;
          alliesUnitsTotal += c.alliesUnits;
        });
      //  this.SendMessage(command.target, "DEBUG: $totalPerc = $totalPercent Looped through $country / ${currentWorld.countries.length}");
        this.SendMessage(command.target, "$theme$b[Unit Stats]$b ${formatTeam("Axis")}"
        " $b${formatNum(axisUnitsTotal)}$b units - ${formatTeam("Allies")} $b${formatNum(alliesUnitsTotal)}$b units");
        totals.forEach((TEAM team, Map vars) {
          this.SendMessage(command.target, "$theme$b[Stats]$b ${formatTeam(convertTeamToString(team))} has"
          " $b${formatNum(vars["factories"])}$b factories, $b${formatNum(vars["mines"])}$b mines, $b${formatNum(vars["oilRigs"])} rigs$b"
          " and a total ${command.get(1).isEmpty ? "map":"region"} percentage of ${(((vars["totalPercent"] / totalPercent) as num) * 100).round()}%. "
           "They currently have $b${formatNum(vars["axisUnits"])} ${formatTeam("Axis")}$b units and $b${formatNum(vars["alliesUnits"])} ${formatTeam("Allies")}$b fighting in their countries.");

        });
      }
    }
    if (command.get(0) == "!proximity") {
      RegExp percentReg = new RegExp(r"[0-9]+?%");
      int percent = 0;
      int from = 1;
      if (percentReg.hasMatch(command.get(1))) {
        percent = int.parse(command.get(1).replaceAll("%",""), onError: (String src) {
          return 0;
        });
        from = 2;
      }
      String duration = command.get(from);
      int dur = int.parse(duration, onError: (String d) {
        return 0;
      });
      String countryName = command.get(from+1, command.getl());
      if (currentWorld != null) {
        Country c = currentWorld.getCountryByName(countryName);
        if (c != null) {
          String countries =currentWorld.countries.where((Country e) {
            return e.getTravelDuration(c, percent).inMinutes <= dur && e != c;
          }).map((Country e) {
            return formatCountry(e);
          }).join(", ");
          this.SendMessage(command.target, "$theme$b[Proximity]$b Countries within $b$dur$b minutes of $b${formatCountry(c)}:");
          this.SendMessage(command.target, "$theme$b[Proximity]$b $countries");
        }
        else {
          this.SendMessage(command.target, "$theme$b[Proximity]$b Could not find the country: $countryName. Please make sure you are using the syntax: $b!proximity $u[travelModifier%]$u $u<Duration in Minutes>$u $u<Country Name>$u");
        }
      }
    }
    if (command.get(0) == "!region") {
      try {
        String regionName = command.get(1, command.getl());
        if (currentWorld != null && regionName != null) {
          List<Country> countries = new List<Country>();
          if (regionName.toUpperCase() == "AMERICAS") {
            countries.addAll(currentWorld.getCountriesByRegion("North America"));
            countries.addAll(currentWorld.getCountriesByRegion("South America"));
          }
          else {
            countries.addAll(currentWorld.getCountriesByRegion(regionName));
          }
          if (countries != null) {
            String regionStr = countries.map((Country e) { return formatCountry(e); }).join(", ");
            this.SendMessage(command.target, "$theme$b[Region]$b $regionStr",",");
          }
        }
        else {
          this.SendMessage(command.target, "$theme$b[Info]$b Regions list has not been loaded yet.");
        }
      }
      catch (E) {
        this.SendMessage(command.target, "$theme$b[Info]$b Could not find the region. Debug $E");
      }
    }
    return true;
  }

  void addMap (Map container, String key, num amount) {
    if (!container.containsKey(key)) {
      container[key] = 0;
    }
    container[key] += amount;
  }

  bool onModuleDeactivate(){
    this.SendMessage(new ChannelName("#Allies"), "$theme$b[Module Shutdown]$b The module has been requested to shutdown.");
  }
  bool onChannelJoin (Target user, JoinCommand command) {
    
  }
  bool onConnect () {
    
  }
}


