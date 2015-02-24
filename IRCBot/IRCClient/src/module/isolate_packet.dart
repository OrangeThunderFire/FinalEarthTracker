part of IrcModule;

abstract class IsolatePacket {
  void handleMessage () {
    
  }
}

/// Used to request the sendport from a module
class ModuleStartPacket extends IsolatePacket {
  SendPort sendBack;
  Nickname myName;
  String serverPassword;
  ModuleStartPacket (SendPort this.sendBack, this.myName, [this.serverPassword]);
}

/// Used to send the sendport to the handler
class SendportResponsePacket extends IsolatePacket {
  SendPort port;
  SendportResponsePacket (SendPort this.port);
}

/// Used to request a command to be sent to the server
class SendCommandPacket extends IsolatePacket {
  Command comm;
  SendCommandPacket (this.comm);
}

/// Received by the module handler 
class CommandEventPacket extends IsolatePacket {
  Target sender;
  Command event;
  CommandEventPacket.withTarget (this.sender,this.event);
}


/// Received by the module handler 
class RawPacket extends IsolatePacket {
  int raw;
  String command;
  RawPacket (this.raw, this.command);
}

class StopModulePacket extends IsolatePacket {
  StopModulePacket();
}

class SocketStatusPacket extends IsolatePacket {
  bool isConnected = true;
  SocketStatusPacket(this.isConnected);
}

class IRCConnectionPacket extends IsolatePacket {
  bool connected;
  IRCConnectionPacket (this.connected);
}

class ModuleStatusChangePacket extends IsolatePacket {
  String moduleName;
  int status = 0;
  ModuleStatusChangePacket(this.moduleName, this.status);
}

class ModuleDependencyPacket {
  SendPort port; 
  String moduleName;
  ModuleDependencyPacket(this.port, this.moduleName);
}

class AllModulesLoadedPacket {
  AllModulesLoadedPacket();
}
