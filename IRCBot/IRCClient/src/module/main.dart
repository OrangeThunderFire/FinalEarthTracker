library IrcModule;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

part 'types.dart';
part 'commands.dart';
part 'enum.dart';
part 'module_handler.dart';
part 'isolate_packet.dart';
part 'parsers.dart';

void throwError (String error) {
  throw "Error found: $error"
        "Please pass this message on to the developers of this IRCBot.";
}





class Language {
  static Map<String, String> language = new Map<String, String>();
  static void add (String key, String message) {
    language[key]  = message;
  }
  static String get (String key, List<dynamic> arguments) {
    if (language.containsKey(key)) {
      RegExp langMatch = new RegExp(r"&([0-9]+?)");
      int x = 0;
      String sentence = language[key].replaceAllMapped(langMatch, (Match match) {
        x = int.parse(match.group(1)) - 1;
        return arguments[x];
      });
      return sentence;
    }
    else return "Language file error";
  }
}