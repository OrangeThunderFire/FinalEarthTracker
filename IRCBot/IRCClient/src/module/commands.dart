part of IrcModule;

abstract class Command {
  String description;
  bool invalid = false;
  String toString () {
    
  }
}
class Parameter {
  List<Object> params;
  Object trailing;
  String command;
  Parameter(this.command, {this.params, this.trailing});
  String toString() { 
    StringBuffer buffer = new StringBuffer();
    buffer.write(command);
    if (this.params != null) {
      
      params.forEach((p) { 
        if (p != null && p is List) {
          List temp = p;
          buffer.write(" ");
          buffer.write(temp.join(","));
        }
        else if (p != null) buffer.write(" $p"); 
      });
    }
    if (this.trailing != null) buffer.write(" :$trailing");
    buffer.write(STRINGS.crlf);
    return buffer.toString();
  }
}
class PassCommand extends Command {
  String password = "";
  PassCommand (this.password);
  
  String toString () => new Parameter(CLIENT_COMMANDS.PASS, params: [password]).toString();
}


class NickCommand extends Command {
  Nickname nick;
  NickCommand(this.nick);
  String toString() => new Parameter(CLIENT_COMMANDS.NICK, params: [nick]).toString();
}

class UserCommand extends Command {
  Nickname nick;
  String realName;
  int mode;
  UserCommand(this.nick, this.mode, this.realName);
  String toString() =>  new Parameter(CLIENT_COMMANDS.USER, params: [nick, mode, "*"], trailing: realName).toString();
}

class OperCommand extends Command {
  String name;
  String password;
  OperCommand (this.name, this.password);
  String toString() =>  new Parameter(CLIENT_COMMANDS.OPER, params: [name, password]).toString();
}


class UserModeCommand extends Command {
  UserMode mode;
  Nickname nickname;
  UserModeCommand (this.nickname, this.mode); 
  String toString() =>  new Parameter(CLIENT_COMMANDS.USER_MODE, params: [nickname, mode]).toString();
}


class ServiceCommand extends Command  {
  String serviceName;
  String distribution;
  int type;
  String info;
  ServiceCommand(this.serviceName, this.distribution, this.type, this.info);
  String toString() =>  new Parameter(CLIENT_COMMANDS.SERVICE, params: [serviceName, 0, distribution, type, 0], trailing: info).toString();
}


class QuitCommand extends Command  {
  String quitMessage = "";
  QuitCommand ([this.quitMessage]);
  String toString() =>  new Parameter(CLIENT_COMMANDS.QUIT, trailing: quitMessage).toString();
}

class SQuitCommand extends Command {
  ServerName server;
  String comment;
  SQuitCommand (this.server, this.comment);
  String toString() =>  new Parameter(CLIENT_COMMANDS.SQUIT, trailing: comment).toString();
}


/// Parameters: ( <channel> *( "," <channel> ) [ <key> *( "," <key> ) ] )
class JoinCommand extends Command {  
  Map<ChannelName, String> channels;
  bool zero = false;
  JoinCommand (ChannelName channel,[String key = ""]) {
    channels = new Map<ChannelName, String>();
    channels[channel] = key;
  }
  JoinCommand.fromMap (Map<ChannelName,String> this.channels);
  JoinCommand.joinZero () {
    zero = true;
  }
  String toString () {
    if (zero) return new Parameter(CLIENT_COMMANDS.JOIN, params: [0]).toString();
    else {
      return new Parameter(CLIENT_COMMANDS.JOIN,params: [channels.keys.toList(), channels.values.toList()]).toString();
    }
  }
}

/// Parameters: <channel> *( "," <channel> ) [ <Part Message> ]
class PartCommand extends Command {
  List<ChannelName> channels;
  String partMessage;
  PartCommand (ChannelName channel, [this.partMessage = ""]) {
    channels = new List<ChannelName>();
    channels.add(channel);
  }
  PartCommand.fromList (List<ChannelName> this.channels, [partMessage = ""]);
  String toString () {
    return new Parameter(CLIENT_COMMANDS.PART, params: [channels], trailing: partMessage).toString();
  }
}

/// Parameters: <channel> *( ( "-" / "+" ) *<modes> *<modeparams> )
class ChannelModeCommand extends Command {
  List<ChanMode> modes;
  ChannelName channel;
  ChannelModeCommand.fromList (this.channel, this.modes);
  String toString () { 
    StringBuffer modeText = new StringBuffer();
    StringBuffer modeParams = new StringBuffer();
    bool addSym = null;
    this.modes.forEach((ChanMode mode) {
      if (mode.add != addSym) {
        addSym = mode.add;
        modeText.write((mode.add ? "+" : "-"));
      }
      modeText.write(mode.modeText);
      if (mode.params != null) modeParams.write(mode.params);
    });
    return new Parameter(CLIENT_COMMANDS.CHAN_MODE, params: [modeText.toString(), modeParams.toString()]).toString();
  }
}

/// Parameters: <channel> [ <topic> ]
class TopicCommand extends Command {
  ChannelName channel;
  String topic;
  TopicCommand.setTopic (ChannelName this.channel, String this.topic);
  TopicCommand.getTopic (ChannelName this.channel);
  String toString() =>  new Parameter(CLIENT_COMMANDS.TOPIC, params: [channel], trailing: topic).toString();
}

/// Parameters: [ <channel> *( "," <channel> ) [ <target> ] ]
class NamesCommand extends Command {
  List<ChannelName> channels;
  ServerName target = new ServerName("");
  NamesCommand ({ChannelName channel, ServerName this.target}) {
    channels = new List<ChannelName>();
    channels.add(channel);
  }
  NamesCommand.fromList (List<ChannelName> this.channels, [ServerName this.target]);
  String toString() =>  new Parameter(CLIENT_COMMANDS.NAMES, params: [channels, target]).toString();
}

/// Parameters: [ <channel> *( "," <channel> ) [ <target> ] ]
class ListCommand extends Command {
  List<ChannelName> channels;
  ServerName target = new ServerName("");
  ListCommand ({ChannelName channel, ServerName this.target}) {
    channels = new List<ChannelName>();
    channels.add(channel);
  }
  ListCommand.fromList (List<ChannelName> this.channels, [ServerName this.target]);

  String toString() =>  new Parameter(CLIENT_COMMANDS.LIST, params: [channels, target]).toString();
}

/// Parameters: <nickname> <channel>
class InviteCommand extends Command {
  Nickname nick;
  ChannelName channel;
  InviteCommand (Nickname this.nick, ChannelName this.channel);
  String toString() =>  new Parameter(CLIENT_COMMANDS.INVITE, params: [nick, channel]).toString();
}

/// Parameters: <channel> *( "," <channel> ) <user> *( "," <user> ) <message>
class KickCommand extends Command {
  List<ChannelName> channels = new List<ChannelName>();
  List<Nickname> nicks = new List<Nickname>();
  ChannelName _fillChannel;
  Nickname _fillNickname;  
  String kickMessage;
  KickCommand (ChannelName channel, Nickname nick, [String this.kickMessage]) {
    channels = new List<ChannelName>();
    channels.add(channel);
    nicks = new List<Nickname>();
    nicks.add(nick);
  }
  KickCommand.fromLists (List<ChannelName> this.channels, List<Nickname> nicks, [String this.kickMessage]) {
    if (this.channels.length == this.nicks.length) {
      invalid = true;
    }
  }
  KickCommand.fromNickList (ChannelName channel, List<Nickname> this.nicks, [String this.kickMessage]) {
    _fillChannel = channel;
  }
  KickCommand.fromChannelList (List<ChannelName> channels, Nickname nick, [String this.kickMessage]) {
    _fillNickname = nick; 
  }
  String toString () {
    if (!invalid) {
      var cLength = (channels != null ? channels.length : (nicks != null ? nicks.length : 0));
      for (int x = 0; x < cLength; x++) {
        if (_fillChannel != null) 
          channels.add(_fillChannel);
        }
        if (_fillNickname != null) {
          nicks.add(_fillNickname);
        }
      }
      return new Parameter(CLIENT_COMMANDS.KICK, params: [channels, nicks], trailing: kickMessage).toString();
  }

}

/// Parameters: <msgtarget> <text to be sent>
class PrivMsgCommand extends Command {
  Target target;
  String message;
  List<String> _splitMsg;
  PrivMsgCommand (Target this.target, String this.message) {
    
  }
  int getl () {
    if (_splitMsg == null) _splitMsg = message.split(" ");
    return _splitMsg.length;
  }
  String get (int start, [int end]) {
    if (_splitMsg == null) _splitMsg = message.split(" ");
    if (end == null) {
      if (start < _splitMsg.length && start >= 0) return _splitMsg[start];
      else return "";
    }
    else {
      if (start < _splitMsg.length && start >= 0 && start < end) {
        if (end+1 > _splitMsg.length) end = _splitMsg.length - 1;
        return _splitMsg.getRange(start, end + 1).join(" ");
      }
      else return "";
    }
  }
  String toString () => new Parameter(CLIENT_COMMANDS.PRIV_MSG, params: [target], trailing: message).toString();
}

/// Parameters: <msgtarget> <text>
class NoticeCommand extends Command {
  Target target;
  String message;
  List<String> _splitMsg;
  NoticeCommand (Target this.target, String this.message);
  int getl () {
    if (_splitMsg == null) _splitMsg = message.split(" ");
    return _splitMsg.length;
  }
  String get (int start, [int end]) {
    if (_splitMsg == null) _splitMsg = message.split(" ");
    if (end == null) {
      if (start < _splitMsg.length && start >= 0) return _splitMsg[start];
      else return "";
    }
    else {
      if (start < _splitMsg.length && start >= 0 && start < end) {
        if (end+1 > _splitMsg.length) end = _splitMsg.length - 1;
        return _splitMsg.getRange(start, end + 1).join(" ");
      }
      else return "";
    }
  }
  String toString () => new Parameter(CLIENT_COMMANDS.NOTICE, params: [target], trailing: message).toString();
}

/// Parameters: [ <target> ]
class MotdCommand extends Command {
  ServerName target;
  MotdCommand ([this.target]);
  String toString () => new Parameter(CLIENT_COMMANDS.MOTD, params: [target]).toString();
}

/// Parameters: [ <mask> [ <target> ] ]
class LusersCommand extends Command {
  Target mask;
  ServerName serverTarget;
  LusersCommand ({this.mask, this.serverTarget});
  String toString () => new Parameter(CLIENT_COMMANDS.L_USERS, params: [mask,serverTarget]).toString();
}

/// Parameters: [ <target> ]
class VersionCommand extends Command {
  ServerName target;
  VersionCommand (ServerName target);
  String toString () => new Parameter(CLIENT_COMMANDS.VERSION, params: [target]).toString();
}

/// Parameters: [ <query> [ <target> ] ]
class StatsCommand extends Command {
  String query;
  ServerName target;
  StatsCommand (String this.query, [ServerName this.target]);
  StatsCommand.noQuery ();
  String toString () => new Parameter(CLIENT_COMMANDS.STATS, params: [query, target]).toString();
}

/// Parameters: [ [ <remote server> ] <server mask> ]
class LinksCommand extends Command {
  ServerName remoteServer;
  ServerName serverMask;
  LinksCommand (this.serverMask, [this.remoteServer]);
  String toString () => new Parameter(CLIENT_COMMANDS.LINKS, params: [remoteServer, serverMask]).toString();
}

/// Parameters: [ <target> ]
class TimeCommand extends Command {
  ServerName target;
  TimeCommand ([ServerName this.target]);
  String toString () => new Parameter(CLIENT_COMMANDS.TIME, params: [target]).toString();
}

/// Parameters: <target server> <port> [ <remote server> ]
class ConnectCommand extends Command {
  ServerName targetServer;
  int port;
  ServerName remoteServer;
  ConnectCommand (this.targetServer, this.port, [this.remoteServer]);
  String toString () => new Parameter(CLIENT_COMMANDS.CONNECT, params: [targetServer, port, remoteServer]).toString();
}

/// Parameters: [ <target> ]
class TraceCommand extends Command {
  ServerName target;
  TraceCommand ([this.target]);
  String toString () => new Parameter(CLIENT_COMMANDS.TRACE, params: [target]).toString();
}

/// Parameters: [ <target> ]
class AdminCommand extends Command {
  Target target;
  AdminCommand ([this.target]);
  String toString () =>  new Parameter(CLIENT_COMMANDS.ADMIN, params: [target]).toString();
}

/// Parameters: [ <target> ]
class InfoCommand extends Command {
  Target target;
  InfoCommand ([this.target]);
  String toString () =>  new Parameter(CLIENT_COMMANDS.INFO, params: [target]).toString();
}

/// Parameters: [ <mask> [ <type> ] ]
class ServListCommand extends Command {
  Target mask;
  int type;
  ServListCommand ([this.mask, this.type]);
  String toString () => new Parameter(CLIENT_COMMANDS.SERV_LIST, params:[this.mask, this.type]).toString();
}

/// Parameters: <servicename> <text>
class SQueryCommand extends Command {
  Target serviceName;
  String message;
  SQueryCommand (this.serviceName, this.message);
  String toString () => new Parameter(CLIENT_COMMANDS.SQUERY, params: [this.serviceName], trailing: this.message).toString();
}

/// Parameters: [ <mask> [ "o" ] ]
class WhoCommand extends Command {
  bool oper;
  Target mask;
  WhoCommand ({this.mask, this.oper});
  String toString () => new Parameter(CLIENT_COMMANDS.OPER, params: [mask, (oper ? "o" : null)]).toString();
}

/// Parameters: [ <target> ] <mask> *( "," <mask> )
class WhoIsCommand extends Command {
  ServerName targetServer;
  List<Target> masks;
  WhoIsCommand (Target mask, [this.targetServer]) {
   masks = new List<Target>();
   masks.add(mask);
  }
  WhoIsCommand.fromList (this.masks, [this.targetServer]);
  String toString () => new Parameter(CLIENT_COMMANDS.WHO_IS, params: [targetServer, masks]).toString();
}

/// Parameters: <nickname> *( "," <nickname> ) [ <count> [ <target> ] ]
class WhoWasCommand extends Command {
  ServerName target;
  int count;
  List<Nickname> nicks;
  WhoWasCommand.fromList (this.nicks, {this.target, this.count});
  WhoWasCommand (Target nick, {this.target, this.count}) {
    nicks = new List<Nickname>();
    nicks.add(nick);
  }
  String toString () => new Parameter(CLIENT_COMMANDS.WHO_WAS, params: [this.nicks, this.count, this.target]).toString();
}

/// Parameters: <nickname> <comment>
class KillCommand extends Command {
  Nickname nick;
  String comment;
  KillCommand (this.nick, this.comment);
  String toString () => new Parameter(CLIENT_COMMANDS.KILL, params: [this.nick, this.comment]).toString();
}

/// Parameters: <server1> [ <server2> ]
class PingCommand extends Command {
  Target server1;
  Target server2;
  PingCommand (Target this.server1, [Target this.server2]);
  String toString () => new Parameter(CLIENT_COMMANDS.PING, params: [server1, server2]).toString();
}

/// Parameters: <server> [ <server2> ]
class PongCommand extends Command {
  Target server1;
  Target server2;
  PongCommand (Target this.server1, [Target this.server2]);
  String toString () => new Parameter(CLIENT_COMMANDS.PONG, params: [server1, server2]).toString();
}

/// Parameters: <error message>
class ErrorCommand extends Command {
  String errorMessage;
  ErrorCommand (this.errorMessage);
  /// NOT A CLIENT COMMAND BUT IMPLEMENTED SOMEWHAT JUST FOR WHATEVER REASON 
  String toString () => new Parameter(CLIENT_COMMANDS.ERROR, trailing: errorMessage).toString();
}

/// Parameters: [ <text> ]
class AwayCommand extends Command {
  String awayMessage;
  AwayCommand (this.awayMessage);
  AwayCommand.remove();
  String toString () => new Parameter(CLIENT_COMMANDS.AWAY, trailing: awayMessage).toString();
}

/// Parameters: None
class RehashCommand extends Command {
  RehashCommand ();
  String toString () => new Parameter(CLIENT_COMMANDS.REHASH).toString();
}

/// Parameters: None
class DieCommand extends Command {
  DieCommand ();
  String toString () => new Parameter(CLIENT_COMMANDS.DIE).toString();
}

/// Parameters: None
class RestartCommand extends Command {
  RestartCommand ();
  String toString () => new Parameter(CLIENT_COMMANDS.RESTART).toString();
}

/// Parameters: <user> [ <target> [ <channel> ] ]
class SummonCommand extends Command {
  Nickname nick;
  Target target;
  ChannelName channel;
  SummonCommand (this.nick, {this.target, this.channel});
  String toString () => new Parameter(CLIENT_COMMANDS.SUMMON, params: [this.nick, this.target, this.channel]).toString();
}

/// Parameters: [ <target> ]
class UsersCommand extends Command {
  Target target;
  UsersCommand ([this.target]);
  String toString () => new Parameter(CLIENT_COMMANDS.USER, params: [target]).toString();
}

/// Parameters: <Text to be sent>
class WallOpsCommand extends Command {
  String message;
  WallOpsCommand (this.message);
  String toString () => new Parameter(CLIENT_COMMANDS.WALL_OPS, trailing: message).toString();
}

/// Parameters: <nickname> *( SPACE <nickname> )
class UserHostCommand extends Command {
  List<Nickname> nicks;
  UserHostCommand (Nickname nick) {
    nicks = new List<Nickname>();
  }
  UserHostCommand.fromList (List<Nickname> this.nicks) { 
    if (this.nicks.length > 5) {
      invalid = true;
    }
  }
  String toString () => new Parameter(CLIENT_COMMANDS.USER_HOST, params: [nicks.join(" ")]).toString();
}

/// Parameters: <nickname> *( SPACE <nickname> )
class IsOnCommand extends Command {
  String _nickList;
  IsOnCommand (Nickname nick) {
    this._nickList = nick.toString();    
  }
  IsOnCommand.fromList (List<Nickname> nicks) { 
    _nickList = nicks.join(" ");
    if (_nickList.length > (511 - CLIENT_COMMANDS.IS_ON.length)) {
      invalid = true;
    }
  }
  String toString () => new Parameter (CLIENT_COMMANDS.IS_ON, params: [_nickList]).toString();
}
