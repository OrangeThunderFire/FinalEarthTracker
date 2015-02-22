part of FinalEarthCrawler;

class UnsubscribeFromEvent extends ClientPacket {
  static int ID = CLIENT_PACKETS.UNSUBSCRIBE_FROM_EVENT.index;

  final String eventName;

  UnsubscribeFromEvent.create(String this.eventName);

  void handlePacket(WebSocketHandler wsh, Client client) {
    List<String> subscribedEvents =
    client.getMetadataOrDefault("subscribed_events", new List<String>());

    if (subscribedEvents.contains(eventName)) {
      subscribedEvents.remove(eventName);
    }
    return;
  }
}