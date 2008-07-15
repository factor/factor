USING: kernel tools.test accessors arrays qualified
       irc.messages irc.messages.private ;
EXCLUDE: sequences => join ;
IN: irc.messages.tests

! Parsing tests
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

