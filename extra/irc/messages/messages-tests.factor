USING: kernel tools.test accessors arrays qualified
       irc.messages irc.messages.private ;
EXCLUDE: sequences => join ;
IN: irc.messages.tests


{ "someuser" } [ "someuser!n=user@some.where" parse-name ] unit-test

irc-message new
    ":someuser!n=user@some.where PRIVMSG #factortest :hi" >>line
    "someuser!n=user@some.where" >>prefix
                       "PRIVMSG" >>command
               { "#factortest" } >>parameters
                            "hi" >>trailing
1array
[ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
  string>irc-message f >>timestamp ] unit-test

privmsg new
    ":someuser!n=user@some.where PRIVMSG #factortest :hi" >>line
    "someuser!n=user@some.where" >>prefix
                       "PRIVMSG" >>command
               { "#factortest" } >>parameters
                            "hi" >>trailing
                   "#factortest" >>name
1array
[ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
  parse-irc-line f >>timestamp ] unit-test

join new
    ":someuser!n=user@some.where JOIN :#factortest" >>line
    "someuser!n=user@some.where" >>prefix
                          "JOIN" >>command
                             { } >>parameters
                   "#factortest" >>trailing
1array
[ ":someuser!n=user@some.where JOIN :#factortest"
  parse-irc-line f >>timestamp ] unit-test

mode new
    ":ircserver.net MODE #factortest +ns" >>line
                          "ircserver.net" >>prefix
                                   "MODE" >>command
                  { "#factortest" "+ns" } >>parameters
                            "#factortest" >>channel
                                    "+ns" >>mode
1array
[ ":ircserver.net MODE #factortest +ns"
  parse-irc-line f >>timestamp ] unit-test

nick new
    ":someuser!n=user@some.where NICK :someuser2" >>line
                     "someuser!n=user@some.where" >>prefix
                                           "NICK" >>command
                                              { } >>parameters
                                      "someuser2" >>trailing
1array
[ ":someuser!n=user@some.where NICK :someuser2"
  parse-irc-line f >>timestamp ] unit-test