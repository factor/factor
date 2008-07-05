USING: kernel tools.test accessors arrays sequences qualified
       io.streams.string io.streams.duplex namespaces threads
       calendar irc.client.private concurrency.mailboxes classes ;
EXCLUDE: irc.client => join ;
RENAME: join irc.client => join_
IN: irc.client.tests

! Utilities
: <test-stream> ( lines -- stream )
  "\n" join <string-reader> <string-writer> <duplex-stream> ;

: make-client ( lines -- irc-client )
   "someserver" irc-port "factorbot" f <irc-profile> <irc-client>
   swap [ 2nip <test-stream> f ] curry >>connect ;

: set-nick ( irc-client nickname -- )
     [ nick>> ] dip >>name drop ;

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

{ "" } make-client dup "factorbot" set-nick current-irc-client [
    { t } [ irc> nick>> name>> me? ] unit-test

    { "factorbot" } [ irc> nick>> name>> ] unit-test

    { "someuser" } [ "someuser!n=user@some.where" parse-name ] unit-test

    { "#factortest" } [ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
                        parse-irc-line irc-message-origin ] unit-test

    { "someuser" } [ ":someuser!n=user@some.where PRIVMSG factorbot :hi"
                     parse-irc-line irc-message-origin ] unit-test
] with-variable

! Test login and nickname set
{ "factorbot" } [ { "NOTICE AUTH :*** Looking up your hostname..."
                    "NOTICE AUTH :*** Checking ident"
                    "NOTICE AUTH :*** Found your hostname"
                    "NOTICE AUTH :*** No identd (auth) response"
                    ":some.where 001 factorbot :Welcome factorbot"
                  } make-client
                  [ connect-irc ] keep 1 seconds sleep
                    nick>> name>> ] unit-test

{ join_ "#factortest" } [
             { ":factorbot!n=factorbo@some.where JOIN :#factortest"
             ":ircserver.net MODE #factortest +ns"
             ":ircserver.net 353 factorbot @ #factortest :@factorbot "
             ":ircserver.net 366 factorbot #factortest :End of /NAMES list."
             ":ircserver.net 477 factorbot #factortest :[ircserver-info] blah blah"
             } make-client dup "factorbot" set-nick
             [ connect-irc ] keep 1 seconds sleep
             join-messages>> 5 seconds mailbox-get-timeout
             [ class ] [ trailing>> ] bi ] unit-test
! TODO: user join
! ":somedude!n=user@isp.net JOIN :#factortest"
! TODO: channel message
! ":somedude!n=user@isp.net PRIVMSG #factortest :hello"
! TODO: direct private message
! ":somedude!n=user@isp.net PRIVMSG factorbot2 :hello"