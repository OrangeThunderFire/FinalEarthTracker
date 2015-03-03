part of FinalEarthCrawler;


class AttackMadeDispatcher extends FinalEarthDispatcher {
  static int logID = 0;
  static MongoUserRepository userRepo = new MongoUserRepository ();

  AttackMadeDispatcher (FinalEarthCrawler crawler):super(crawler);

  // TODO: Refactor
  _checkForEvents () async {
    if (!_isCancelled && logID !=0) {
      String response = await this.crawler.getLogData(logID);
      if (response.contains("Don't have an account? Create one")) {
        await this.crawler.login();
        _checkForEvents();
      }
      else {
        if (!response.contains("Not Found")) {
          Document doc = parse(response);
          Element resultOutput = doc.querySelector('.w90p.alleft');
          if (resultOutput != null) {
            String output = resultOutput.innerHtml;
            RegExp timeReg = new RegExp(r'([0-9]+\-[0-9]+\-[0-9]+ \- [0-9]+\:[0-9]+\:[0-9]+ (?:AM|PM))');
            Match timeR = timeReg.firstMatch(output);
            DateTime time = new DateFormat("y-M-d - h:m:s a").parse(timeR.group(1));
            List<Element> userLinks = resultOutput.querySelectorAll("a");
            if (userLinks.length == 1) {
              // Nuke Log

              String nukedUserName = userLinks[0].text.trim();
              int nukedUserId = userLinks[0].attributes["href"].replaceFirst("details?userID=", "");
              TEAM nukedUserTeam = userLinks[0].querySelector("font").attributes["color"] == "#00D8A3" ? TEAM.ALLIES : TEAM.AXIS;
              List<Element> logTable = doc.querySelectorAll(".scroll_bar table");
              List<Element> nukedUserTableRows = logTable[0].querySelectorAll("tr");
              Map nukedUserData = parseTable(nukedUserTableRows);
              RegExp damageReg = new RegExp(r'Damaged ([0-9]+?)% of the land.');
              int damage = int.parse(damageReg.firstMatch(output).group(1), onError: (String src) {
                return 0;
              });
              User nukedUser = await AttackMadeDispatcher.userRepo.getById(nukedUserId);
              if (nukedUser == null) {
                nukedUser = new User(nukedUserId, nukedUserName, nukedUserTeam, [], 0, 0, []);
              }
              _updateUser(nukedUser, nukedUserName, nukedUserTeam, nukedUserData, null, logID);
              userRepo.store(nukedUser);

              AttackLog atl = new AttackLog(logID, time, null, nukedUser,
              null, nukedUserData["units"], 0, nukedUserData["totalLost"], true, damage);
              AttackMadeEvent ame = new AttackMadeEvent(atl);
              this._eventStream.add(ame);
            }
            else {
              String attackerName = userLinks[0].text.trim();
              int attackerID = userLinks[0].attributes["href"].replaceFirst("details?userID=", "");
              String defenderName = userLinks[1].text.trim();
              int defenderID = userLinks[1].attributes["href"].replaceFirst("details?userID=", "");
              TEAM attackerTeam = userLinks[0].querySelector("font").attributes["color"] == "#00D8A3" ? TEAM.ALLIES : TEAM.AXIS;
              TEAM defenderTeam = userLinks[1].querySelector("font").attributes["color"] == "#00D8A3" ? TEAM.ALLIES : TEAM.AXIS;

              List<Element> logTable = doc.querySelectorAll(".scroll_bar table");
              List<Element> attackerTableRows = logTable[0].querySelectorAll("tr");
              List<Element> defenderTableRows = logTable[1].querySelectorAll("tr");
              Map attackerData = parseTable(attackerTableRows);
              Map defenderData = parseTable(defenderTableRows);
              User attacker = await AttackMadeDispatcher.userRepo.getById(attackerID);
              if (attacker == null) {
                attacker = new User(attackerID, attackerName, attackerTeam, [], 0, 0, []);
              }

              User defender = await AttackMadeDispatcher.userRepo.getById(defenderID);
              if (defender == null) {
                defender = new User(defenderID, defenderName, defenderTeam, [], 0, 0, []);
              }
              _updateUser(attacker, attackerName, attackerTeam, attackerData, defenderData, logID);
              _updateUser(defender, defenderName, defenderTeam, defenderData, attackerData, logID);
              userRepo.store(attacker);
              userRepo.store(defender);
              AttackLog atl = new AttackLog(logID, time, attacker, defender,
              attackerData["units"], defenderData["units"], attackerData["totalLost"], defenderData["totalLost"]);
              AttackMadeEvent ame = new AttackMadeEvent(atl);
              this._eventStream.add(ame);
            }
            AttackMadeDispatcher.logID++;

          }
        }
        _checkForEvents();
      }
    }
  }

  void _updateUser (User user, String name, TEAM team, Map logData, Map otherUsersLogData, int logId) {
    // update
    user.name = name;
    user.team = team;
    // todo: seriously refactor.
    logData["units"].forEach((UnitAmount uAmt) {
      UnitAmount oldData;
      if (user.knownUnits.length > 0) {
        try {
          oldData = user.knownUnits.firstWhere((UnitAmount e) {
            return e.unit.ID == uAmt.unit.ID;
          });
        }
        catch (E) {
        }
      }
      if (oldData != null) {
        user.knownUnits.remove(oldData);
      }
      user.knownUnits.add(uAmt);
    });

    user.losses += logData["totalLost"];
    if (otherUsersLogData != null) {
      user.dealt += otherUsersLogData["totalLost"];
    }
    user.attackLogIds.add(logId);
  }

  Map<String, dynamic> parseTable (List<Element> trs) {
    List<UnitAmount> unitTallys = new List<UnitAmount>();
    int unitLostTotal;
    for (int i = 0; i < trs.length; i++) {
      if (i+1 == trs.length) {

        unitLostTotal = num.parse(trs[i].text.trim().replaceAll(",", "").replaceAll("(", "").replaceAll(")", "").replaceAll(r"$", ""), (String e) {
          return 0;
        });
      }
      else {
        Element tr = trs[i];
        unitTallys.add(parseUnitTd(tr));
      }
    }
    return {  "units": unitTallys, "totalLost": unitLostTotal };
  }
  UnitAmount parseUnitTd (Element tr) {
    List<Element> tds = tr.querySelectorAll("td");
    if (tds.length == 2) {
      String unitName = tds[0].text.trim();
      String unitData = tds[1].text.trim();
      List<String> unitValues = unitData.split(new RegExp(" */ *"));
      int unitLost = int.parse(unitValues[0], onError: (String e) { return 0; });
      int unitsTotal = int.parse(unitValues[1], onError: (String e) { return 0; });
      return new UnitAmount(unitLost, unitsTotal, Unit.getByName(unitName));

    }
    return;
  }
}