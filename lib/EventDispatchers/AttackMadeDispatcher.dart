part of FinalEarthCrawler;


class AttackMadeDispatcher extends FinalEarthDispatcher {
  static int logID = 0;

  AttackMadeDispatcher (FinalEarthCrawler crawler):super(crawler);

  void _checkForEvents () {
    print("CHECKING ATTACK LOG");
    if (!_isCancelled && logID !=0) {
      this.crawler.getLogData(logID).then((String response) {
        if (!response.contains("Not Found")) {
          Document doc = parse(response);
          Element resultOutput = doc.querySelector('.w90p.alleft');
          List<Element> userLinks = resultOutput.querySelectorAll("a");
          String attacker = userLinks[0].text.trim();
          int attackerID = userLinks[0].attributes["href"].replaceFirst("details?userID=", "");
          String defender = userLinks[1].text.trim();
          int defenderID = userLinks[1].attributes["href"].replaceFirst("details?userID=", "");

          List<Element> logTable = doc.querySelectorAll(".scroll_bar table");
          List<Element> attackerTableRows = logTable[0].querySelectorAll("tr");
          List<Element> defenderTableRows = logTable[1].querySelectorAll("tr");
          Map attackerData = parseTable(attackerTableRows);
          Map defenderData = parseTable(defenderTableRows);
          String output = resultOutput.innerHtml;
          RegExp timeReg = new RegExp(r'([0-9]+\-[0-9]+\-[0-9]+ \- [0-9]+\:[0-9]+\:[0-9]+ (?:AM|PM))');
          Match timeR = timeReg.firstMatch(output);
          DateTime time = new DateFormat("y-M-d - h:m:s a").parse(timeR.group(1));
          AttackLog atl = new AttackLog(logID, time, attacker, defender, attackerID, defenderID,
          attackerData["units"], defenderData["units"], attackerData["totalLost"], defenderData["totalLost"]);
          AttackMadeEvent ame = new AttackMadeEvent(atl);
          this._eventStream.add(ame);
          AttackMadeDispatcher.logID++;

        }
        _checkForEvents();
      });
    }
  }

  Map<String, dynamic> parseTable (List<Element> trs) {
    List<UnitAmount> unitTallys = new List<UnitAmount>();
    int unitLostTotal;
    for (int i = 0; i < trs.length; i++) {
      if (i+1 == trs.length) {

        unitLostTotal = num.parse(trs[i].text.trim().replaceAll(",", ""), (String e) {
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