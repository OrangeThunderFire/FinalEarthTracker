part of Requester;

class RequesterClient extends http.BaseClient {
  final http.Client _inner;
  Map<String, List<Cookie>> _cookieJar = new Map<String, List<Cookie>>();

  RequesterClient(this._inner);

  void setCookies (String host, String cookieHeader) {
    cookieHeader.split(",").forEach((String splitCookie) {
      List<String> furtherSplit = splitCookie.split(";")[0].split("=");
      if (furtherSplit.length == 2) {
        Cookie newCookie = new Cookie(Uri.encodeComponent(furtherSplit[0]), furtherSplit[1]);
        if (_cookieJar.containsKey(host)) {
          _cookieJar[host].removeWhere((e) => e.name == newCookie.name);
        } else {
          _cookieJar[host] = new List<Cookie>();
        }
        _cookieJar[host].add(newCookie);
      }
    });
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_cookieJar.containsKey(request.url.host)) {
      String cookieStr =  _cookieJar[request.url.host].map((e) => "${Uri.decodeComponent(e.name)}=${e.value}").join("; ");
      request.headers["cookie"] = cookieStr;
    }
    return _inner.send(request);
  }



}
