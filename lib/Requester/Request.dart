part of Requester;

class Request {
  static const MAXIMUM_BACK_OFF_TIME = 3600;
  static final Logger log = new Logger("Requester");
  String method;
  String url;
  int _attempts = 1;
  int maxAttempts = 10;
  bool _cancelled = false;
  Map data;
  Map<String, String> headers;
  Requester _requester;
  RequesterClient client;

  Request (Requester this._requester, String this.url, http.Client this.client, { this.method: "GET", this.headers: const {}, this.data: const {}, this.maxAttempts: 10 });

  /***
   * Sends the request to the server checking if the request has been cancelled before.
   * @throws [RequestCancelledException] Specifies the request has been cancelled by the client
   * @throws [NotFoundException] If the server responded that the page was not found
   * @throws [RequestMaxAttemptsReachedException]
   */

  Future<String> request() {
    return this._request().then((http.Response response) {
      if (response.headers.containsKey("set-cookie")) {
        client.setCookies(Uri.parse(this.url).host,response.headers["set-cookie"]);
      }
      if (response.statusCode == HttpStatus.OK) {
        return response.body;
      }
      if (response.statusCode == HttpStatus.FOUND) {
        this.data = {};
        this.url = response.headers["location"];
        return this.request();
      }
      if (response.statusCode == HttpStatus.NOT_FOUND) {
        throw new NotFoundException(this);
        return;
      }
      return reQueue();
    }).catchError((e) {
        Request.log.warning("Caught error: $e");
        return reQueue();
    });
  }

  Future<http.Response> _request () {
    if (this.isCancelled()) {
      return Future.error(new RequestCancelledException(this));
    }
    if (this.method.toUpperCase() == "POST") {
      return this.client.post(this.url, headers: this.headers, body: this.data);
    }
    if (this.method.toUpperCase() == "GET") {
      return this.client.get(this.url, headers: this.headers);
    }
    throw "METHOD NOT IMPLEMENTED EXCEPTION"; // TODO throw actual exception
  }

  /***
   * Receives an exception, returns true if it should ignore the error handling
   * and bubble it back up to the [Requestor].
   *
   * It uses this to ensure that its not re-attempting a request on exceptions
   * it itself threw.
   */
  bool _checkIfExceptionIsToBeIgnored (error) {
    return !(error is RequestException);
  }

  /***
   * Sends the request to [Requester]'s to be re-queued once the exponential
   * back off timeout has completed.
   */
  Future<HttpClientResponse> reQueue ([bool disregardMaxAttempts = false]) {
    if (!disregardMaxAttempts && this._attempts >  this.maxAttempts) {
      throw new RequestMaxAttemptsReachedException(this);
    }
    _attempts++;
    int backOffSeconds = getExponentialBackOffTime(_attempts++, Request.MAXIMUM_BACK_OFF_TIME);
    Request.log.info("Requeueing ${this.url} in ${backOffSeconds} seconds");
    return new Future.delayed(new Duration( seconds: backOffSeconds), () {
      return _requester.addToQueue(this);
    });
  }

  /***
   * Tells the Request to cancel.
   * When the [request] method is called it will not complete successfully
   * and throw a [RequestCancelledError]
   */
  void cancel () {
    this._cancelled = true;
  }

  /***
   * Returns true if the request has been cancelled
   */
  bool isCancelled () {
    return this._cancelled;
  }

}
