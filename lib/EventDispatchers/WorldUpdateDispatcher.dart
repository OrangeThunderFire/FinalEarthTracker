part of FinalEarthCrawler;

class WorldUpdateDispatcher extends FinalEarthDispatcher {
  World _currentWorld;

  WorldUpdateDispatcher (FinalEarthCrawler crawler):super(crawler);

  void _checkForEvents () {
    if (!_isCancelled) {
      this.crawler.getWorldData().then((String worldResponse) {
          JsonCodec decoder = new JsonCodec();
          try {
            Map data = decoder.decode(worldResponse);

            World previousWorld = _currentWorld;
            _currentWorld = new World.fromMapJson(data);

            WorldUpdateEvent updateEvent = new WorldUpdateEvent(_currentWorld, previousWorld);


            this._eventStream.add(updateEvent);
          }
          catch (error) {
            this._eventStream.addError(error);
          }
          if (!_isCancelled) {
            new Timer(new Duration(seconds: 1),() { _checkForEvents(); });
          }
        });
    }
  }

}