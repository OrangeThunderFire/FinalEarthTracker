part of IRCClient;

class ModuleHandler {
  static Map<String, ModuleContainer> modules = new Map<String, ModuleContainer>();
 IrcHandler ircHandler;
 String serverPassword;
 
 ModuleHandler (this.ircHandler, [this.serverPassword]);
 
 
 void initialize () {
   Directory thisFolder = new Directory("./modules/");
   print("Checking folder exists");
   if (thisFolder.existsSync()) {
     List<FileSystemEntity> listSync = thisFolder.listSync(recursive: false);
     listSync.forEach((FileSystemEntity f) { 
       if (f is Directory) {
          File moduleCheck = new File("${f.path}/module.dart");
          print("Checking if module exists");
          if (moduleCheck.existsSync()) {
            List<String> folderName = moduleCheck.path.split("/");
            print("Loading module ${folderName[folderName.length - 2]}");
            this.loadModule(folderName[folderName.length -2]);
          }
       }
     });
   }

 }
 void loadModule (String moduleName) {
   if (!modules.containsKey(moduleName)) {
    modules[moduleName] = new ModuleContainer(moduleName, this);
    modules[moduleName].initialize();
   }
 }
 void unloadModule (String moduleName) {
   if (modules.containsKey(moduleName)) {
     modules[moduleName].unloadModule();
     modules.remove(moduleName);
   }
 }
 void reloadModule (String moduleName) {
   if (modules.containsKey(moduleName)) {
     modules[moduleName].reloadModule();
   }
 }
 
 void sendAllPacket(IsolatePacket packet) {
   modules.forEach((modulename, module) {
     if (module.active) {
       module.sendMessage(packet);
     }
   });
 }
 
 void sendPacket (String moduleName, IsolatePacket packet) {
   if (modules.containsKey(moduleName)) {
     modules[moduleName].sendMessage(packet);
   }
 }
 
 void sendCommand (Command comm, [Nickname sender = null]) {
   sendAllPacket(new CommandEventPacket.withTarget(sender, comm));
 }
 
 
 
}

class ModuleContainer {
  Module module;
  ModuleHandler handler;
  Isolate _isolate;
  ReceivePort _port;
  SendPort _sender;
  bool _loaded = false;
  bool active = true;
  String moduleFolder;
  
  // Metadata
  String moduleName = "";
  String moduleAuthor = "";
  String moduleDescription = "";
  String moduleImage = "";
  num moduleVersion = 0;
  
  
  ModuleContainer (String this.moduleFolder, ModuleHandler this.handler);
  
  void initialize () {
    print("INIT MODULE $moduleFolder");
    File f = new File(".\\modules\\$moduleFolder\\module.dart");
    if (f.existsSync()) {
      File _moduleDescription = new File(".\\modules\\$moduleFolder\\module.json");
      if (_moduleDescription.existsSync()) {
        try {
          dynamic obj = new JsonDecoder(null).convert(_moduleDescription.readAsStringSync());
          if (obj != null) {
            if (obj["name"] != null && obj["name"] is String) { moduleName = obj["name"]; }
            if (obj["author"] != null && obj["author"] is String) { moduleAuthor = obj["author"]; }
            if (obj["description"] != null && obj["description"] is String) { moduleDescription = obj["description"]; }
            if (obj["image"] != null && obj["image"] is String) { moduleImage = obj["image"]; }
            if (obj["version"] != null && obj["version"] is num) { moduleVersion = obj["version"]; }
          }
        }
        catch (e) {
          // Dont stop the script running, not that important that the module has a proper json file
          print ("Malformed json file in module $moduleFolder");
        }
      }
      _port = new ReceivePort();
      SendPort sendPort = _port.sendPort;
      print(Uri.parse("./modules/$moduleFolder/module.dart"));
      Isolate.spawnUri(Uri.parse("./modules/$moduleFolder/module.dart"),[],new ModuleStartPacket(sendPort, handler.ircHandler.myNick)).then((Isolate iso) {
        _isolate = iso;
        active = true;
        _loaded = true;
        _port.listen(handleMessage);
      });
    }
  }
  
  void unloadModule () {
    if (_loaded == true) {
      this.sendMessage(new StopModulePacket());
      _port.close();
      _loaded = false;
      active = false;
    }
  }
  
  void sendMessage(IsolatePacket packet) {
    if (_loaded) {
      _sender.send(packet);
    }
  }
  
  void reloadModule() {
    if (_loaded == true) {
      this.sendMessage(new StopModulePacket());
      _loaded = false;
      active = false;
      _port.close();
      
      this.initialize();
    }
  }
  
  void handleMessage (dynamic message) {
     if (message is SendportResponsePacket) {
       _sender = message.port;
     }
     else if (message is SendCommandPacket) {
       this.handler.ircHandler.sendCommand(message.comm);
     }
     else if (message is ModuleStatusChangePacket) {
          if (message.status == 1) {
            this.handler.unloadModule(message.moduleName);
          }
          else if (message.status == 2) {
            this.handler.reloadModule(message.moduleName);
          }
          else if (message.status == 3) {
            this.handler.loadModule(message.moduleName);
          }
     }
     else if (message is ModuleDependencyPacket) {
       //this.handler
     }
  }
}

