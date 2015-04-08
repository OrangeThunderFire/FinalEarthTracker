# FinalEarthTracker

Tracks unit changes across the game, tracks logs.

IRCBot/ contains the IRC bot that posts unit data to the channel.

The rest of the core code is in lib

To run:

cd into `bin`. then run the command:

`dart --enable-async main.dart -u <username> -p <password> -l <lastLogID>`

And log tracking will begin.


Then run `dart TestBot.dart` to begin the IRC bot in the /IRCBot/IRClient/src' folder

To run the website jump into the web directory and opeen index.html. Its all using websockets the core server is hosting on port 8080.


# TODO

- Move directory structure so that each folder is its own package
- Refactor some of the basic data
- Move the IRC commands into their own separate module
