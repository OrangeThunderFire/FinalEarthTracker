part of FinalEarthModels;

enum TEAM {
 NEUTRAL,
  ALLIES,
    AXIS
}

String convertTeamToString(TEAM team) {
  // TODO: refactor
  String ret = team.toString();
  ret = ret.replaceFirst("TEAM.", "").toLowerCase();
  return "${ret[0].toUpperCase()}${ret.split("").getRange(1,ret.length).join("")}";
}

TEAM convertTeamFromString (String team) {
  // TODO: refactor
  switch (team) {
   case "Axis":
    return TEAM.AXIS;
   case "Allies":
    return TEAM.ALLIES;
   case "Neutral":
    return TEAM.NEUTRAL;
  }
  return;
}
