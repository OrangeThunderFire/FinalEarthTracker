library Requester;

import "dart:io";
import "dart:async";
import "dart:collection";
import "dart:math" as Math;
import "package:logging/logging.dart";
import "dart:convert";
import "package:http/http.dart" as http;

part "Request.dart";
part 'Exceptions.dart';
part "Functions.dart";
part "RequesterClient.dart";

class Requester {
  final Logger log = new Logger("Requester");

  int interval;
  RequesterClient client = new RequesterClient(new http.Client());
  Queue<List> _queuedRequests = new Queue<List>();
  List<String> _visitedUrls = new List<String>();
  Timer _waitForInterval;

  Requester ({ this.interval: 2000 }) {
    this.log.config("Configuration for Requester:");
    this.log.config("Interval is ${this.interval}");
  }

  /***
   *   Request the URL from the server once the queue has been fulfilled.
   *   @params String [url] The requested URL to retrieve data from
   *   @params bool [visitOnce?] Specifies if you want the Requester to keep track of the URL and only allow it to
   *                             request the URL once per session.
   *   @returns [HttpClientResponse] The response stream that was sent by the server.
   */
  Future<HttpClientResponse> request (String url, { bool visitOnce: false, method: "GET", data: const {}, headers: const {} }) {
    this._visitedUrls.add(url);
    Request request = new Request(this, url, client, method: method, data: data, headers: headers);
    return this.addToQueue(request);
  }

  /***
   * Adds the Request to the end of the queue.
   */
  Future<HttpClientResponse> addToQueue (Request request, [bool visitOnce = false]) {
    String url = request.url;
    if (visitOnce && this._visitedUrls.contains(url)) {
      this.log.warning("Url ${url} has already been visited.");
      return Completer.completeError(new UrlAlreadyVisitedException(url));
    }
    this.log.fine("Added ${url} to queue.");
    Completer deferred = new Completer();
    this._queuedRequests.add([deferred, request]);
    this._processQueue();
    return deferred.future;
  }

  /***
   * Processes the queue for completion
   */
  void _processQueue () {
    if (this._waitForInterval != null && this._waitForInterval.isActive) {
      return;
    }

    if (this._queuedRequests.length <= 0) {
      this.log.info("There is no more requests to process");
      return;
    }

    List currentQueueItem = this._queuedRequests.removeFirst();
    Request currentRequest = currentQueueItem[1];
    Completer currentCompleter = currentQueueItem[0];

    this.log.fine("Requesting ${currentRequest.url} [${this._queuedRequests.length}]");

    currentCompleter.complete(currentRequest.request());
    _waitForInterval = new Timer(new Duration(milliseconds: this.interval), () {
      this._processQueue();
    });
  }
}