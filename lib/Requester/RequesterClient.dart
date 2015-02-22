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
      print(cookieStr);
    }
    request.headers["origin"] = "http://${request.url.host}";
    request.headers["user-agent"] = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36";
    return _inner.send(request);
  }



}
