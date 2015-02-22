part of Requester;

/** REQUESTER ERRORS **/

abstract class RequesterException implements Exception {
  final String url;
  const RequesterException(this.url);
  String toString();
}


class UrlAlreadyVisitedException extends RequesterException {
  UrlAlreadyVisitedException(String url):super(url);
  String toString () =>  "${this.url} has already been visited which violates the visitOnce option supplied when making the Request";
}

/** REQUEST ERRORS **/

abstract class RequestException implements Exception {
  final Request request;
  RequestException(this.request) {  }
  String toString();
}

class NotFoundException extends RequestException {
  NotFoundException(Request request):super(request);
  String toString () =>  "The server returned a 404 Not Found code for ${this.request.url}";
}

class RequestCancelledException extends RequestException {
  RequestCancelledException(Request request):super(request);
  String toString () =>  "The client cancelled the request before it could complete for ${this.request.url}";
}

class RequestMaxAttemptsReachedException extends RequestException {
  RequestMaxAttemptsReachedException(Request request):super(request);
  String toString () => "The total attempts made on this request exceeded the maximum of ${this.request.maxAttempts}";
}