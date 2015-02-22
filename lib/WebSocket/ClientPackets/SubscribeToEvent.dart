part of FinalEarthCrawler;

class SubscribeToEvent extends ClientPacket {
  static int ID = CLIENT_PACKETS.SUBSCRIBE_TO_EVENT.index;

  final String eventName;

  SubscribeToEvent.create(String this.eventName);

  void handlePacket(WebSocketHandler wsh, Client client) {
    List<String> subscribedEvents =
    client.getMetadataOrDefault("subscribed_events", new List<String>());

    if (subscribedEvents.contains(eventName)) {
      return;
    }
    subscribedEvents.add(this.eventName);
  }
}