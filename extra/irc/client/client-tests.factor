USING: kernel tools.test accessors arrays sequences qualified
       io.streams.string io.streams.duplex namespaces
       irc.client.private ;
EXCLUDE: irc.client => join ;
IN: irc.client.tests

! Utilities
: <test-stream> ( lines -- stream )
  "\n" join <string-reader> <string-writer> <duplex-stream> ;

: make-client ( lines -- irc-client )
   "someserver" irc-port "factorbot" f <irc-profile> <irc-client>
   swap [ 2nip <test-stream> f ] curry >>connect ;

: with-dummy-client ( quot -- )
     rot with-variable ; inline

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

{ "" } make-client dup nick>> "factorbot" >>name drop current-irc-client [
    { t } [ irc-client> nick>> name>> me? ] unit-test

    { "factorbot" } [ irc-client> nick>> name>> ] unit-test

    { "someuser" } [ "someuser!n=user@some.where" parse-name ] unit-test

    { "#factortest" } [ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
                        parse-irc-line irc-message-origin ] unit-test

    { "someuser" } [ ":someuser!n=user@some.where PRIVMSG factorbot :hi"
                     parse-irc-line irc-message-origin ] unit-test
] with-variable

! Client tests
{ } [ { "" } make-client connect-irc ] unit-test