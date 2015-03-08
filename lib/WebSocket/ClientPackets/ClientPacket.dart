part of FinalEarthCrawler;

// TODO: Make ID CLIENT_PACKETS not the int index of this enum.
enum CLIENT_PACKETS {
  SUBSCRIBE_TO_EVENT,
  UNSUBSCRIBE_FROM_EVENT,
  GET_USER_DATA,
  FIND_UNIT_TYPE
}

/// TODO: Work out a better way of doing this.
String getSymName (Symbol sym) {
  String str = sym.toString();
  return str.substring(8, str.length - 2);
}

class PacketInstancer {
  Map<String, String> positional = new Map<String, String>();
  Map<String, String> optional = new Map<String, String>();
  Map<String, String> named = new Map<String, String>();
  ClassMirror cm;
  PacketInstancer (ClassMirror this.cm) {
    Map<Symbol, DeclarationMirror> declarations = cm.declarations;
    Symbol createMethod = new Symbol("${getSymName(cm.simpleName)}.create");
    // Check if our packet has a create constructor
    if (declarations.containsKey(createMethod)) {
      DeclarationMirror dm = declarations[createMethod];
      if (dm is MethodMirror && dm.isConstructor) {
        List<ParameterMirror> pm = dm.parameters;
        // Loop through the parameters of the packet class
        pm.forEach((ParameterMirror parameter)  {
          TypeMirror paramType = parameter.type;
          String typeName = getSymName (paramType.simpleName);
          // Check if the parameters match JSON object specified types
          if (typeName == "String" || typeName == "num" || typeName == "int" || typeName == "bool" || typeName == "double" || typeName == "List" || typeName == "Map") {
            if (parameter.isNamed) {
              named[getSymName (parameter.simpleName)] = typeName;
            }
            else if (parameter.isOptional) {
              optional[getSymName (parameter.simpleName)] = typeName;
            }
            else {
              positional[getSymName(parameter.simpleName)] = typeName;
            }
          }
          else {
            ClientPacket.clientPacketLogger.severe("Cannot construct PacketInstancer as packet uses a unsuported type: $typeName");
          }
        });
      }
      else {
        ClientPacket.clientPacketLogger.severe("Cannot construct PacketInstancer as packets create declaration is not a constructor");
      }
    }
    else {
      ClientPacket.clientPacketLogger.severe("Cannot construct PacketInstancer as packet does not have create method.");
    }
  }
  ClientPacket getPacket (Map params) {
    List<dynamic> posArguments = new List<dynamic>();
    // Loop through our params map and check the parameter type to the parameter name
    // and ensure they match what the packet class allows for
    positional.forEach((String parameterName, String paramType) {
      if (params.containsKey(parameterName)) {
        dynamic obj = params[parameterName];
        if (compareTypes(obj, paramType)) {
          posArguments.add(obj);
        }
        else {
          ffpServerLog.info("$parameterName: $obj != $paramType");
        }
      }
      else {
        ffpServerLog.info("$parameterName does not exist");
      }
    });

    Map<Symbol, dynamic> namedParams = new Map<Symbol, dynamic>();
    named.forEach((String parameterName, String paramType) {
      if (params.containsKey(parameterName)) {
        dynamic obj = params[parameterName];

        if (compareTypes(obj, paramType)) {
          namedParams[new Symbol(parameterName)] = obj;
        }
        else {
          ClientPacket.clientPacketLogger.info("Dropping parameter $parameterName as it doesnt match type == $paramType");
        }
      }
      else {
        ClientPacket.clientPacketLogger.info("Dropping parameter $parameterName");
      }
    });
    if (posArguments.length == positional.length) {
      // return an instance of our packet as the json object matches up.
      return cm.newInstance(const Symbol("create"), posArguments, namedParams).reflectee;
    }
    else {
      ClientPacket.clientPacketLogger.warning("Incorrect parameters found.");
    }
  }
}

abstract class ClientPacket {
  static Logger clientPacketLogger = new Logger("ClientPacket");
  static int ID = 0;
  ClientPacket();
  ClientPacket.create();
  void handlePacket (WebSocketHandler wsh, Client client);

  static Map<int, PacketInstancer> packets = new Map<int, PacketInstancer>();

  static bool init() {
    clientPacketLogger.info("Initializing");
    MirrorSystem ms = currentMirrorSystem();
    // Allows us to refactor the name of the class and not have to update the symbol name
    TypeMirror tm = reflectType(ClientPacket);
    Symbol thisSymbol = tm.simpleName;
    Symbol packetSym = const Symbol("ID");
    ms.libraries.forEach((Uri libUri, LibraryMirror libM) {
      libM.declarations.forEach((Symbol declarationN, DeclarationMirror dm) {
        if (dm is ClassMirror) {
          ClassMirror superClass = dm.superclass;
          if (superClass != null)  {
            if (superClass.simpleName == thisSymbol) {
              InstanceMirror packetField;
              try {
                packetField = dm.getField(packetSym);
              }
              catch (E) { }
              if (packetField != null) {
                int packetID = packetField.reflectee;
                if (!packets.containsKey(packetID)) {
                  packets[packetID] = new PacketInstancer(dm);
                }
                else {
                  clientPacketLogger.severe("Could not load packet ${dm.simpleName} as its ID conflicts");
                  return false;
                }
              }
              else {
                clientPacketLogger.severe("Could not load packet ${dm.simpleName} as it does not have a packet ID");
                return false;
              }
            }
          }
        }
      });
    });
    return true;
  }


  static ClientPacket getPacket (int packetID, Map props) {
    if (packets.containsKey(packetID)) {
      return packets[packetID].getPacket(props);
    }
    else {
      clientPacketLogger.warning("Unknown packet ID $packetID received by getPacket");
    }
    return;
  }
}

bool compareTypes (dynamic obj, String type) {
  ///TODO: PROPER REFLECTION AND NOT HARD CODED.
  String t = obj.runtimeType.toString();
  if (t == "_LinkedHashMap") {
    t = "Map";
  }
  else if (t == "_GrowableList") {
    t = "List";
  }
  return t == type;
}
