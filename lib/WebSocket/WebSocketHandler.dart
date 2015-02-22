part of FinalEarthCrawler;

class WebSocketHandler {
  static Logger log = new Logger("WebSocketHandler");
  // Holds all our clients currently connected
  Map<String, Client> clients = new Map<String, Client>();
  // Decoder used to decode JSON packets
  JsonDecoder decoder = new JsonDecoder(null);
  JsonEncoder encoder = new JsonEncoder(null);



  void start (InternetAddress ipAddress, int port) {
    WebSocketHandler.log.info ("Starting HTTP/Websocket server on $ipAddress:$port");

    // Listen to HTTP Connections on the specified port
    HttpServer.bind(ipAddress, port).then((HttpServer server) {


      // Listen to normal http connections and upgrade them to a WebSocket connection
      server.listen((HttpRequest request) {
        WebSocketHandler.log.info ("New connection to server");
        if (request.uri.path == "/websocket") {
          WebSocketHandler.log.info ("Websocket request found... TRANSFORMING (Websockets in disguise)...");
          WebSocketTransformer.upgrade(request).then((WebSocket conn) {
            Client cli;

            cli = addClient(conn, request);

            conn.listen(cli.onMessage,
            onDone: () => cli.destroyClient(new Duration(minutes: 15), removeClient),
            onError: (e) => cli.destroyClient(new Duration(minutes: 15), removeClient)
            );

          });
        }
      });

    });
  }

  /// Sends an object to all clients on the WebSocket
  void sendPacketToAll (ServerPacket message) {
    sendStringToAll(encoder.convert(message));
  }

  /// Sends a string to all clients on the WebSocket
  void sendStringToAll (String message) {
    clients.forEach((k, v) {
      v._websocket.add(message);
    });
  }


  /// Removes a client from the WebSocket client map
  void removeClient (Client cli) {
    if (clients.containsKey(cli._uniqueID)) {
      clients.remove(cli._uniqueID);
    }
  }

  /// Checks if a WebSocket is currently added to the WebSocket client map
  bool clientExists (String clientID) {
    return clients.containsKey(clientID);
  }

  /// Adds a client to the WebSocket client map
  Client addClient (WebSocket s, HttpRequest req) {
    Client t =  new Client(s, this, req);
    clients[t._uniqueID] = t;
    return t;
  }

  /// Gets a [client] from the WebSocket client map from the socket connection
  Client getClientFromSocket (String clientID) {
    if (clients.containsKey(clientID)) {
      return clients[clientID];
    }
    return;
  }

}