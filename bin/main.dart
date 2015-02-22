// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library FinalEarthServer;

import "dart:async";
import "dart:io";
import "dart:convert";
import "package:logging/logging.dart";
import "package:mongo_dart/mongo_dart.dart";
import 'package:FinalEarthCrawler/FinalEarthCrawler.dart';


import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast.dart';
import "package:args/args.dart";


main(List<String> args) async {
  ArgParser parser = new ArgParser();
  parser.addOption('username', abbr: 'u');
  parser.addOption('password', abbr: 'p');
  Map results = parser.parse(args);

  String dbPath ="quickDb.db";
  DatabaseFactory dbFactory = ioDatabaseFactory;
  Database db = await dbFactory.openDatabase(dbPath);
  int logID = await db.get("logID");
  if (logID == null) {
    logID = 1;
    await db.put(1, "logID");
  }
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    if (rec.loggerName == "Connection" || rec.loggerName == "ConnectionManager" || rec.loggerName == "MongoMessageTransformer") return;
    print('${rec.level.name}: [${rec.loggerName}] ${rec.time}: ${rec.message}');
  });
  ClientPacket.init();

  WebSocketHandler wsh = new WebSocketHandler();
  await wsh.start(InternetAddress.ANY_IP_V4, 8080);
//
  FinalEarthCrawler fec = new FinalEarthCrawler(results["username"], results["password"]);

  AttackMadeDispatcher.logID = logID;
  MongoAttackLogRespository attackLogRepo = new MongoAttackLogRespository();
  fec.onAttackMade.listen((AttackMadeEvent event) {
    db.put(event.attackLog.logID, "logID");
    attackLogRepo.store(event);
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

}
