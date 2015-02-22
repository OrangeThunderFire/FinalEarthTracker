//
//JsonEncoder jsonenc = new JsonEncoder();
//print("Connected to self");
//WebSocket socket = await WebSocket.connect("ws://127.0.0.1:8080/websocket");
//socket.add(jsonenc.convert({ "ID": 0, "eventName": "CountryUpdateEvent" }));
//socket.listen((data) {
//    Logger.root.info("Got data: $data");
//});
(function (exports) {
    var ServerPackets = {
        DISCONNECT_SERVER: 0,
        WORLD_UPDATE_EVENT: 1,
        COUNTRY_UPDATE_EVENT: 2,
        UNIT_UPDATE_EVENT: 3,
        FACILITY_UPDATE_EVENT: 4,
        TRAVEL_DETECT_EVENT: 5
    };
    var ClientPackets = {
        SUBSCRIBE_TO_EVENT: 0,
        UNSUBSCRIBE_FROM_EVENT: 1
    };

    function SocketHandler (uri) {
        this.uri = uri;
        this.websocket = null;
        this.connected = false;
        this.handlers = {};
    }
    SocketHandler.prototype.addHandler = function (ID, handler) {
        this.handlers[ID] = handler;
    };
    SocketHandler.prototype.connect = function (onopen) {
        this.websocket = new WebSocket(this.uri);
        var self = this;
        this.websocket.onopen = function () {
            self.connected = true;
            onopen();
            self.websocket.onmessage = self.onMessage.bind(self);
        };

    }
    SocketHandler.prototype.onMessage = function (event) {
        var packet = JSON.parse(event.data);
        if (packet.ID != null) {
            if (this.handlers.hasOwnProperty(packet.ID)) {
                this.handlers[packet.ID](packet);
            }
        }
    };

    SocketHandler.prototype.subscribeEvent = function (eventName) {
        if (this.connected) {
            this.websocket.send(JSON.stringify({ "ID": ClientPackets.SUBSCRIBE_TO_EVENT, "eventName": eventName }));
        }
    };

    SocketHandler.prototype.unsubscribeEvent = function (eventName) {
        if (this.connected) {
            this.websocket.send(JSON.stringify({ "ID": ClientPackets.UNSUBSCRIBE_FROM_EVENT, "eventName": eventName }));
        }
    };

    exports.SocketHandler = SocketHandler;
    exports.ClientPackets = ClientPackets;
    exports.ServerPackets = ServerPackets;
})(window);

