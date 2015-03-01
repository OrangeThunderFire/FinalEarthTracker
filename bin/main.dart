// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library FinalEarthServer;

import "dart:async";
import "dart:io";
import "dart:convert";
import "package:logging/logging.dart";
import "package:mongo_dart/mongo_dart.dart";
import 'package:FinalEarthCrawler/FinalEarthCrawler.dart';
import 'package:FinalEarthCrawler/Models/lib/Models.dart';


import "package:args/args.dart";

var crlf = "\r\n";
List<Socket> plainSocketClients = new List<Socket> ();
String _formatLosses (List<UnitAmount> uae) {
  String knownUnits = uae.map((UnitAmount uae) {
    if (uae.total != 0) {
      return "${uae.unit.name}^${uae.amount}^${uae.left}^${uae.unit.ID}";
    }
  }).join(",");
  return knownUnits;
}
void sendToPlainSocketClients (String packet) {
  plainSocketClients.forEach((Socket c) {
    c.add(new Utf8Decoder.convert("$packet$crlf"));
  });
}
String _formatUser (User u) {
  String knownUnits = u.knownUnits.map((UnitAmount uae) {
    if (uae.total != 0) {
      return "${uae.unit.name}^${uae.total}^${uae.unit.ID}";
    }
  }).join(",");
  return "${u.name}|${u.id}|${knownUnits}";
}
String _formatLog(AttackLog atl) {
  if (!atl.isNukeLog) {
  return "${atl.logID}|${_formatUser(atl.attacker)}|${_formatUser(atl.defender)}|${atl.attackerLosses}|${atl.defenderLosses}|${_formatLosses(atl.attackerUnitData)}|${_formatLosses(atl.defenderUnitData)}";
  }
  else {
    return "${atl.logID}|${_formatUser(atl.defender)}|${atl.defenderLosses}|${_formatLosses(atl.defenderUnitData)}";
  }
}
String _formatLogPacket (AttackLog atl) {
  if (atl.isNukeLog == false) {
    return "LOG ${_formatLog(atl)}$crlf";
  }
  else {
    return "NUKELOG ${_formatLog(atl)}";
  }
}
void _sendLog (Socket client, AttackLog atl) {
  client.add(new Utf8Encoder().convert(_formatLogPacket(atl)));
}

main(List<String> args) async {
  ArgParser parser = new ArgParser();
  parser.addOption('username', abbr: 'u');
  parser.addOption('password', abbr: 'p');
  parser.addOption('logid', abbr: 'l');
  Map results = parser.parse(args);

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    if (rec.loggerName == "Connection" || rec.loggerName == "ConnectionManager" || rec.loggerName == "MongoMessageTransformer") return;
    //print('${rec.level.name}: [${rec.loggerName}] ${rec.time}: ${rec.message}');
  });
  ClientPacket.init();

  WebSocketHandler wsh = new WebSocketHandler();
  await wsh.start(InternetAddress.ANY_IP_V4, 8080);
//
  FinalEarthCrawler fec = new FinalEarthCrawler(results["username"], results["password"]);

  AttackMadeDispatcher.logID = int.parse(results["logid"], onError: (String src) { return 1; });
  MongoAttackLogRespository attackLogRepo = new MongoAttackLogRespository();
  fec.onAttackMade.listen((AttackMadeEvent event) {
    attackLogRepo.store(event);
    sendToPlainSocketClients(_formatLogPacket(event.attackLog));
    wsh.clients.forEach((String key, Client client) {
      List<String> subscribedEvents = client.getMetadataOrDefault("subscribed_events", new List<String> ());
      if (subscribedEvents.contains("AttackMadeEvent")) {
        Logger.root.info("Sending AttackMadeEvent");
        client.sendPacket(new AttackMadePacket(event));
      }
    });
  });

  MongoWorldRepository worldRepo = new MongoWorldRepository();
  fec.onWorldUpdate.listen((WorldUpdateEvent event) {
    Logger.root.info("Storing world in database");
    worldRepo.store(event);
    wsh.clients.forEach((String key, Client client) {
      List<String> subscribedEvents = client.getMetadataOrDefault("subscribed_events", new List<String> ());
      if (subscribedEvents.contains("WorldUpdateEvent")) {
        Logger.root.info("Sending WorldUpdateEvent");
        client.sendPacket(new WorldUpdatePacket(event));
      }
    });
  });

  fec.onCountryChange.listen((CountryChangeEvent event) {
    wsh.clients.forEach((String key, Client client) {
      List<String> subscribedEvents = client.getMetadataOrDefault("subscribed_events", new List<String> ());
      if (subscribedEvents.contains("CountryUpdateEvent")) {
        client.sendPacket(new CountryUpdatePacket(event));
      }
    });
  });

  MongoUnitChangeRepository unitModRepo = new MongoUnitChangeRepository();
  fec.onUnitChange.listen((UnitChangeEvent event) {
    Logger.root.info("Storing Unit modification in database");
    unitModRepo.store(event);
    wsh.clients.forEach((String key, Client client) {
      List<String> subscribedEvents = client.getMetadataOrDefault("subscribed_events", new List<String> ());
      if (subscribedEvents.contains("UnitUpdateEvent")) {
        client.sendPacket(new UnitUpdatePacket(event));
      }
    });
  });

  MongoFacilityChangeRepository facilityModRepo = new MongoFacilityChangeRepository();
  fec.onFacilityChange.listen((FacilityChangeEvent event) {
    Logger.root.info("Storing Facility modification in database");
    facilityModRepo.store(event);
    wsh.clients.forEach((String key, Client client) {
      List<String> subscribedEvents = client.getMetadataOrDefault("subscribed_events", new List<String> ());
      if (subscribedEvents.contains("FacilityUpdateEvent")) {
        client.sendPacket(new FacilityUpdatePacket(event));
      }
    });
  });

  fec.onTravelDetect.listen((TravelDetectEvent event) {
    wsh.clients.forEach((String key, Client client) {
      List<String> subscribedEvents = client.getMetadataOrDefault("subscribed_events", new List<String> ());
      if (subscribedEvents.contains("TravelDetectEvent")) {
        client.sendPacket(new TravelDetectPacket(event));
      }
    });
  });

  MongoUserRepository userRepo = new MongoUserRepository();

  ServerSocket.bind(InternetAddress.ANY_IP_V4, 41135).then((ServerSocket socket) {
    socket.listen((Socket client) {
      client.add(new Utf8Encoder().convert("Final Earth Logger Interface Connected$crlf"));
      client.transform(new Utf8Decoder()).transform(new LineSplitter()).listen((String data) {
        print("GOT DATA $data");
        List<String> spl = data.split(" ");
        if (spl[0] == "GETLOG") {
          if (spl.length > 1) {
            int parse = int.parse(spl[1], onError: (String source) { return 1; });
            attackLogRepo.findByLogId(parse).then((AttackLog atl) {
              if (atl != null) {
                _sendLog(client, atl);
              }
              else {
                client.add(new Utf8Encoder().convert("LOGNOTFOUND ${spl[1]}$crlf"));
              }
            }).catchError((e) { });
          }
        }
        if (spl[0] == "GETUSER") {
          if (spl.length > 1) {
            int parse = int.parse(spl[1], onError: (String source) { return -1; });
              userRepo.getById(spl[1]).then((User u) {
                if (u != null) {
                  client.add(new Utf8Encoder().convert("${_formatUser(u)}$crlf"));
                }
                else {
                  userRepo.getByName(spl[1]).then((User u) {
                    if (u != null) {
                      client.add(new Utf8Encoder().convert("${_formatUser(u)}$crlf"));
                    }
                    else {
                      client.add(new Utf8Encoder().convert("USERNOTFOUND ${spl[1]}$crlf"));
                    }
                  });
                }
              });
          }
        }
      }, onError: () {
        plainSocketClients.remove(client);
      }, onDone: () {
        plainSocketClients.remove(client);
      });

    });
  });
}
