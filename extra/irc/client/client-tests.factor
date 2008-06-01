USING: kernel ;
IN:
irc.client.private
: me? ( string -- ? )
    "factorbot" = ;

USING: irc.client irc.client.private kernel tools.test accessors arrays ;
IN: irc.client.tests

irc-message new
    ":someuser!n=user@some.where PRIVMSG #factortest :hi" >>line
    "someuser!n=user@some.where" >>prefix
    "PRIVMSG" >>command
    { "#factortest" } >>parameters
    "hi" >>trailing 1array
[ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
  string>irc-message f >>timestamp ] unit-test

privmsg new
    ":someuser!n=user@some.where PRIVMSG #factortest :hi" >>line
    "someuser!n=user@some.where" >>prefix
    "PRIVMSG" >>command
    { "#factortest" } >>parameters
    "hi" >>trailing
    "#factortest" >>name 1array
[ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
  parse-irc-line f >>timestamp ] unit-test

{ "someuser" } [ "someuser!n=user@some.where"
                 parse-name ] unit-test

{ "#factortest" } [ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
                    parse-irc-line irc-message-origin ] unit-test

{ "someuser" } [ ":someuser!n=user@some.where PRIVMSG factorbot :hi"
                 parse-irc-line irc-message-origin ] unit-test
