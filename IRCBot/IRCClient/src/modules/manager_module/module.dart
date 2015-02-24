library ManagementModule;

import '../../module/main.dart';

void main (args, ModuleStartPacket packet) { 
  ManagementModule cm = new ManagementModule(packet);
}

class ManagementModule extends Module {
  String serverPassword;
  int state = 0;
  String prevTestedNick = "";
  ManagementModule (ModuleStartPacket packet):super(packet) {
    serverPassword = packet.serverPassword;
  
  }
  
  bool onChannelMessage (Target user, PrivMsgCommand command) {
    if (command.get(0) == "!disconnect") {
      this.sendCommand(new QuitCommand("BYE CRUEL WORLD"));
    }
    else if (command.get(0) == "!loadModule" && command.get(1).isNotEmpty) {
      this.SendMessage(command.target, "Attempting to load module...");
      this.sendPacket(new ModuleStatusChangePacket(command.get(1), 3));
    }
    else if (command.get(0) == "!reloadModule" && command.get(1).isNotEmpty) {
      this.SendMessage(command.target, "Attempting to reload module...");
      this.sendPacket(new ModuleStatusChangePacket(command.get(1), 2));
      
    }
    else if (command.get(0) == "!stopModule" && command.get(1).isNotEmpty) {
      this.SendMessage(command.target, "Stopping module...");
      this.sendPacket(new ModuleStatusChangePacket(command.get(1), 1));
    }
    else if (command.get(0) == "!pbotAdd") {
      
    }
    else if (command.get(0) == "!about") {
      this.SendMessage(command.target, "${k}03PBot is running version 0.1 alpha IRClient. Coded 100% in Dartlang.");
    }
    else if (command.get(0) == "!join") {
      if (command.get(1).isNotEmpty && command.get(2) == this.getBotName().toString()) {
        this.sendCommand(new JoinCommand(new ChannelName(command.get(1))));
      }
    }
    else if (command.get(0) == "!leave") {
        if (command.get(1).isNotEmpty && command.get(2) == this.getBotName().toString()) {
          this.sendCommand(new PartCommand(new ChannelName(command.get(1), "Requested to leave")));
        }
      }
  }
  bool onChannelJoin (Target user, JoinCommand command) {
    if (user is Nickname) {
      if (user.name == this.getBotName().name) {
        ChannelName lobby = new ChannelName("#Lobby");
        if (command.channels.keys.elementAt(0).channel == "#Lobby") {
          this.sendCommand(new PartCommand(lobby, "I am a bot! :("));
        }
      }
    }
    
  }
  bool onConnect () {
    this.SendMessage(new Nickname("nickserv"), "identify roflman1");
    this.sendCommand(new JoinCommand(new ChannelName("#Allies")));
  }
}


