library AdminModule;

import 'dart:io';
import 'dart:convert';
import '../../module/main.dart';
void main (args, ModuleStartPacket packet) { 
  AdminModule cm = new AdminModule(packet);
  
}


class AdminModule extends Module {
  String serverPassword;
  int state = 0;
  String prevTestedNick = "";
  AdminModule (ModuleStartPacket packet):super(packet) {
    serverPassword = packet.serverPassword;
    
  }
  
  bool onPrivateMessage (Target user, PrivMsgCommand command) {
    if (command.get(0) == "identify") {
      
    }         
  }

  bool onConnect () {

  }
}


