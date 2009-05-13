! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test accessors arrays
       irc.messages.parser irc.messages ;
EXCLUDE: sequences => join ;
IN: irc.messages.tests


! { "someuser" } [ "someuser!n=user@some.where" parse-name ] unit-test

{ T{ privmsg
     { line ":someuser!n=user@some.where PRIVMSG #factortest :hi" }
     { prefix  "someuser!n=user@some.where" }
     { command "PRIVMSG" }
     { parameters { "#factortest" } }
     { trailing "hi" }
     { target "#factortest" }
     { text "hi" }
     { sender "someuser" } } }
[ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
  string>irc-message f >>timestamp ] unit-test

{ T{ join
     { line ":someuser!n=user@some.where JOIN :#factortest" }
     { prefix "someuser!n=user@some.where" }
     { command "JOIN" }
     { parameters { } }
     { trailing "#factortest" }
     { sender "someuser" }
     { channel "#factortest" } } }
[ ":someuser!n=user@some.where JOIN :#factortest"
  string>irc-message f >>timestamp ] unit-test

{ T{ mode
     { line ":ircserver.net MODE #factortest +ns" }
     { prefix "ircserver.net" }
     { command "MODE" }
     { parameters { "#factortest" "+ns" } }
     { name "#factortest" }
     { mode "+ns" } } }
[ ":ircserver.net MODE #factortest +ns"
  string>irc-message f >>timestamp ] unit-test

{ T{ mode
     { line ":ircserver.net MODE #factortest +o someuser" }
     { prefix "ircserver.net" }
     { command "MODE" }
     { parameters { "#factortest" "+o" "someuser" } }
     { name "#factortest" }
     { mode "+o" }
     { parameter "someuser" } } }
[ ":ircserver.net MODE #factortest +o someuser"
  string>irc-message f >>timestamp ] unit-test

{ T{ nick
     { line ":someuser!n=user@some.where NICK :someuser2" }
     { prefix "someuser!n=user@some.where" }
     { command "NICK" }
     { parameters  { } }
     { trailing "someuser2" }
     { sender "someuser" }
     { nickname "someuser2" } } }
[ ":someuser!n=user@some.where NICK :someuser2"
  string>irc-message f >>timestamp ] unit-test

{ T{ rpl-nickname-in-use
     { line ":ircserver.net 433 * nickname :Nickname is already in use" }
     { prefix "ircserver.net" }
     { command "433" }
     { parameters { "*" "nickname" } }
     { name "nickname" }
     { trailing "Nickname is already in use" } } }
[ ":ircserver.net 433 * nickname :Nickname is already in use"
  string>irc-message f >>timestamp ] unit-test

{ t } [ ":someuser!n=user@some.where PRIVMSG #factortest :ACTION jumps!"
        string>irc-message action? ] unit-test
