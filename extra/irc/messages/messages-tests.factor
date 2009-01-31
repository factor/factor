USING: kernel tools.test accessors arrays
       irc.messages irc.messages.private ;
EXCLUDE: sequences => join ;
IN: irc.messages.tests


{ "someuser" } [ "someuser!n=user@some.where" parse-name ] unit-test

{ T{ irc-message
     { line ":someuser!n=user@some.where PRIVMSG #factortest :hi" }
     { prefix "someuser!n=user@some.where" }
     { command  "PRIVMSG" }
     { parameters { "#factortest" } }
     { trailing "hi" } } }
[ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
  string>irc-message f >>timestamp ] unit-test

{ T{ privmsg
     { line ":someuser!n=user@some.where PRIVMSG #factortest :hi" }
     { prefix  "someuser!n=user@some.where" }
     { command "PRIVMSG" }
     { parameters { "#factortest" } }
     { trailing "hi" }
     { name "#factortest" } } }
[ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
  parse-irc-line f >>timestamp ] unit-test

{ T{ join
     { line ":someuser!n=user@some.where JOIN :#factortest" }
     { prefix "someuser!n=user@some.where" }
     { command "JOIN" }
     { parameters { } }
     { trailing "#factortest" } } }
[ ":someuser!n=user@some.where JOIN :#factortest"
  parse-irc-line f >>timestamp ] unit-test

{ T{ mode
     { line ":ircserver.net MODE #factortest +ns" }
     { prefix "ircserver.net" }
     { command "MODE" }
     { parameters { "#factortest" "+ns" } }
     { name "#factortest" }
     { mode "+ns" } } }
[ ":ircserver.net MODE #factortest +ns"
  parse-irc-line f >>timestamp ] unit-test

{ T{ mode
     { line ":ircserver.net MODE #factortest +o someuser" }
     { prefix "ircserver.net" }
     { command "MODE" }
     { parameters { "#factortest" "+o" "someuser" } }
     { name "#factortest" }
     { mode "+o" }
     { parameter "someuser" } } }
[ ":ircserver.net MODE #factortest +o someuser"
  parse-irc-line f >>timestamp ] unit-test

{ T{ nick
     { line ":someuser!n=user@some.where NICK :someuser2" }
     { prefix "someuser!n=user@some.where" }
     { command "NICK" }
     { parameters  { } }
     { trailing "someuser2" } } }
[ ":someuser!n=user@some.where NICK :someuser2"
  parse-irc-line f >>timestamp ] unit-test

{ T{ nick-in-use
     { line ":ircserver.net 433 * nickname :Nickname is already in use" }
     { prefix "ircserver.net" }
     { command "433" }
     { parameters { "*" "nickname" } }
     { name "nickname" }
     { trailing "Nickname is already in use" } } }
[ ":ircserver.net 433 * nickname :Nickname is already in use"
  parse-irc-line f >>timestamp ] unit-test