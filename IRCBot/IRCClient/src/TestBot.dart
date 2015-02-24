import 'main.dart';
import 'module/main.dart';
import 'dart:io';
import 'dart:async';

void main () {
  //Future<List<InternetAddress>> lookup(String host, {InternetAddressType type: InternetAddressType.ANY})
  InternetAddress.lookup("irc.torn.com", type: InternetAddressType.IP_V4).then((List<InternetAddress> ips) {
      if (ips.length > 0) {
        IrcHandler handler = new IrcHandler(ips[0], 6667, new Nickname("NorthernLights"));
        handler.startClient();
      }
  });
}