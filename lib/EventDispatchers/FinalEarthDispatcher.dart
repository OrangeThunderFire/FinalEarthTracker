part of FinalEarthCrawler;

abstract class FinalEarthDispatcher {
  FinalEarthCrawler crawler;
  bool _isCancelled = true;
  StreamController _eventStream;

  FinalEarthDispatcher (FinalEarthCrawler this.crawler);

  Stream<WorldUpdateEvent> get eventStream {
    if (_eventStream == null) {
      _eventStream = new StreamController.broadcast(onListen: _onListen, onCancel: _onCancel);
    }
    return _eventStream.stream;
  }


  void _onCancel () {
    _isCancelled = true;
  }

  void _onListen () {
    if (_isCancelled == true) {
      _isCancelled = false;
      _checkForEvents();
    }
  }

  void _checkForEvents();
}