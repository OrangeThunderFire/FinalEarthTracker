// Copyright (c) 2015, Thomas Caserta. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The FinalEarthCrawler library.
library FinalEarthCrawler;

import "dart:async";
import "dart:io";
import "dart:convert";
import "dart:math" as Math;
import "package:logging/logging.dart";
import "Requester/Requester.dart";
import 'package:boilerplate/boilerplate.dart';
import 'package:mongo_dart/mongo_dart.dart';
import "package:uuid/uuid.dart";
import "package:intl/intl.dart";
import "dart:mirrors";
import "package:html5lib/dom.dart";
import "package:html5lib/parser.dart" show parse;
import 'Models/lib/Models.dart';

part "Events/WorldUpdateEvent.dart";
part "Events/FinalEarthEvent.dart";
part 'Events/CountryChangeEvent.dart';
part "Events/UnitChangeEvent.dart";
part "Events/FacilityChangeEvent.dart";
part "Events/TravelDetectEvent.dart";
part "Events/AttackMadeEvent.dart";
part 'EventDispatchers/FinalEarthDispatcher.dart';
part 'EventDispatchers/WorldUpdateDispatcher.dart';
part 'EventDispatchers/CountryChangeDispatcher.dart';
part 'EventDispatchers/UnitChangeDispatcher.dart';
part 'EventDispatchers/FacilityChangeDispatcher.dart';
part 'EventDispatchers/TravelDetectDispatcher.dart';
part 'EventDispatchers/AttackMadeDispatcher.dart';
part "Database/FacilityChangeRepository.dart";
part "Database/UnitChangeRepository.dart";
part "Database/WorldRepository.dart";
part "Database/MongoInstance.dart";
part "Database/AttackLogRepository.dart";
part "Database/UserRepository.dart";
part "WebSocket/WebSocketHandler.dart";
part "WebSocket/Client.dart";
part "WebSocket/ClientPackets/ClientPacket.dart";
part "WebSocket/ClientPackets/SubscribeToEvent.dart";
part "WebSocket/ClientPackets/UnsubscribeFromEvent.dart";
part "WebSocket/ServerPackets/ServerPacket.dart";
part "WebSocket/ServerPackets/DisconnectServerPacket.dart";
part "WebSocket/ServerPackets/WorldUpdatePacket.dart";
part "WebSocket/ServerPackets/CountryUpdatePacket.dart";
part "WebSocket/ServerPackets/UnitUpdatePacket.dart";
part "WebSocket/ServerPackets/FacilityUpdatePacket.dart";
part "WebSocket/ServerPackets/TravelDetectPacket.dart";
part "WebSocket/ServerPackets/AttackMadePacket.dart";

class FinalEarthCrawler {
  Requester _requester = new Requester(interval: 3000);

  WorldUpdateDispatcher _worldUpdateDispatcher;
  CountryChangeDispatcher _countryChangeDispatcher;
  UnitChangeDispatcher _unitChangeDispatcher;
  FacilityChangeDispatcher _facilityChangeDispatcher;
  TravelDetectDispatcher _travelDetectDispatcher;
  AttackMadeDispatcher _attackMadeDispatcher;
  bool _loggedIn = false;
  get loggedIn => _loggedIn;
  String username;
  String password;

  FinalEarthCrawler (this.username, this.password) {
    _worldUpdateDispatcher = new WorldUpdateDispatcher(this);
    _countryChangeDispatcher = new CountryChangeDispatcher(this);
    _unitChangeDispatcher = new UnitChangeDispatcher(this);
    _facilityChangeDispatcher = new FacilityChangeDispatcher(this);
    _travelDetectDispatcher = new TravelDetectDispatcher(this);
    _attackMadeDispatcher = new AttackMadeDispatcher(this);
  }

  Future<bool> login () {
    return this._requester.request("http://finalearth.com/users/login", method: "POST", data: { "_method": "POST", "name": this.username, "pass": this.password }).then((String response) {
      this._loggedIn = response.contains("Continue to HQ");
      print("Got loginr response ${_loggedIn}");
      return this._loggedIn;
    });
  }

  Future<String> getLogData (int logID) async {
    //""
    if (this.loggedIn == false) {
      print("Logging in");
      int attempts = 0;
      while (this.loggedIn == false && attempts++ <= 3) {
        print("Awaiting login return");
        await this.login();
        print("Login completed?");
      }
    }

    return this._requester.request("http://finalearth.com/details/logUser?ID=$logID", headers: { "X-Requested-With": "XMLHttpRequest"});
  }

  Stream<WorldUpdateEvent> get onWorldUpdate {
    return _worldUpdateDispatcher.eventStream;
  }

  Stream<CountryChangeEvent> get onCountryChange {
    return _countryChangeDispatcher.eventStream;
  }

  Stream<CountryChangeEvent> get onUnitChange {
    return _unitChangeDispatcher.eventStream;
  }

  Stream<FacilityChangeEvent> get onFacilityChange {
    return _facilityChangeDispatcher.eventStream;
  }

  Stream<TravelDetectEvent> get onTravelDetect {
    return _travelDetectDispatcher.eventStream;
  }

  Stream<AttackMadeEvent> get onAttackMade {
    return _attackMadeDispatcher.eventStream;
  }
  Future<String> getWorldData () {
    return _requester.request("http://finalearth.com/users/map");
  }

}