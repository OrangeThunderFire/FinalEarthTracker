part of FinalEarthCrawler;

class Client {
  static Logger log = new Logger("Client");

  Map<String, dynamic> _metadata = new Map<String, dynamic>();
  WebSocket _websocket;
  bool loggedIn = false;
  Timer destroyer;
  JsonEncoder encoder = new JsonEncoder(null);
  Map<String, Completer> responsePacket = new Map<String, Completer>();

  /// NEVER EXPOSE TO CLIENTS - IT IS ESSENTIALLY THE SESSION KEY
  String _uniqueID;
  WebSocketHandler wsh;
  HttpRequest _req;

  Client (this._websocket, this.wsh, this._req) {
    _uniqueID = new Uuid().v4();
  }

  void send (String message) {
    _websocket.add(message);
  }
  void sendPacket (ServerPacket message) {
    _websocket.add(encoder.convert(message.toMap()));
  }

  /// Disconnect the client and remove them from the listener.
  void disconnect (String reason) {
    this.sendPacket(new DisconnectServerPacket(reason));
    wsh.removeClient(this);
    _websocket.close();
  }

  bool isResponse (String respID) {
    return responsePacket.containsKey(respID);
  }

  void foundResponse (String respID, WebSocketHandler handler, ClientPacket packet) {
    if (responsePacket.containsKey(respID)) {
      if (!responsePacket[respID].isCompleted) {
        responsePacket[respID].complete(packet);
        responsePacket.remove(respID);
      }
      else {
        Client.log.warning("Response had already timed out...");
      }
    }
  }

  void onMessage(message) {
    try {
      // Parse the sent message into JSON
      dynamic obj = JSON.decode(message);
      Client.log.info(message);
      if (obj is Map) {
        if (obj.containsKey("ID") && obj["ID"] is int) {
          // Construct our client packet
          ClientPacket c = ClientPacket.getPacket(obj["ID"], obj);
          // Send the client and websocket handler to the packet and ask it to handle the packet.
          if (c != null) {
            if (obj.containsKey("rID") && obj["rID"] is String) {
              String rID = obj["rID"];
              if (this.isResponse(rID)) {
                this.foundResponse(obj["rID"], wsh, c);
              }
              else c.handlePacket(wsh, this);
            }
            else c.handlePacket(wsh, this);
          }
        }
      }
    }
    catch (e) {
      log.warning("Error when parsing packet $e");
    }
  }

  void destroyClient (Duration duration, onDestroyClient onDestroyClient) {
    cancelDestroy();
    destroyer = new Timer(duration, () {
      onDestroyClient(this);
    });
  }


  void cancelDestroy () {
    if (destroyer != null) {
      if (destroyer.isActive) {
        destroyer.cancel();
      }
    }
  }

  void mergeWith(updated, [bool forceMerge = false]) {
    if (this.runtimeType == updated.runtimeType || forceMerge) {
      InstanceMirror origIM = reflect(this);
      InstanceMirror updatedIM = reflect(updated);
      ClassMirror origCM = reflectClass(this.runtimeType);
      _merge(origCM, origIM, updatedIM);
    } else throw new Exception("Cannot merge two objects of different types. To override set forceMerge to true");
  }

  void _merge(ClassMirror fromClass, InstanceMirror original, InstanceMirror newValues) {
    fromClass.declarations.forEach((Symbol s, DeclarationMirror dm) {
      if (dm is VariableMirror && dm.isPrivate == false) {
        dynamic val = newValues.getField(s).reflectee;
        if (val != null) {
          original.setField(s, val);
        }
      }
    });
    if (fromClass.superclass != null) {
      _merge(fromClass.superclass, original, newValues);
    }
  }

  /***
   * Sets some metadata on the client.
   * @returns The value inputted
   */
  dynamic setMetaData (String key, dynamic value) {
    _metadata[key] = value;
    return value;
  }

  /***
   * Retreives the value for the associated key in the metadata storage
   * @returns Value of the supplied key, if it does not exist then null.
   */
  dynamic getMetaData(String key) {
    if (!this.hasMetaData(key)) {
      return;
    }
    return _metadata[key];
  }

  /***
   * Checks if the client has the metadata for [key]
   */
  bool hasMetaData (String key) {
    return _metadata.containsKey(key);
  }

  dynamic getMetadataOrDefault (key, def) {
    if (this.hasMetaData(key)) {
      return this.getMetaData(key);
    }
    return this.setMetaData(key, def);
  }

  /***
   * Sends a packet to the client and returns a future to await for a response
   * Times out after the time specified.
   */
  Future<ClientPacket> sendGetResponse(ResponsePacket packet, { timeoutSeconds: 5 }) {
    Completer c = new Completer();
    String id = _Uuid.v4();
    new Timer(new Duration(seconds: timeoutSeconds), () {
      c.completeError("Response timed out. $id");
      disconnect("Client did not respond in time");
    });
    responsePacket[id] = c;
    return c.future;
  }
}

typedef void onDestroyClient (Client cli);