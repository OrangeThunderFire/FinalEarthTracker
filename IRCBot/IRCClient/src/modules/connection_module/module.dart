import '../../module/main.dart';

void main (args, ModuleStartPacket packet) { 
  ConnectionModule cm = new ConnectionModule(packet);
}

class ConnectionModule extends Module {
  String serverPassword;
  int state = 0;
  String prevTestedNick = "";
  ConnectionModule (ModuleStartPacket packet):super(packet) {
    serverPassword = packet.serverPassword;
   
    
  }
  bool onReceiveRaw (int code, String packet) {
  
    if (code == NUMERIC_REPLIES.ERR_NICKNAMEINUSE || code == NUMERIC_REPLIES.ERR_NICKCOLLISION) {
      print("Nickname in use");
      if (prevTestedNick == "") prevTestedNick = this.getBotName().name;
      prevTestedNick = "${prevTestedNick}_";
        this.setBotName(prevTestedNick);
    }
    
  }
  bool onPing (ServerName name) {
    this.sendCommand(new PongCommand(name));
  }
  bool onSocketStart () {
    print("Sending user registration...");
    if (serverPassword != null) this.sendCommand(new PassCommand(serverPassword));
    
    this.sendCommand(new NickCommand(this.getBotName()));
    this.sendCommand(new UserCommand(this.getBotName(),0, "iRC Client"));
  }
}


