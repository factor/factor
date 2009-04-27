! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test accessors arrays sequences
io io.streams.duplex namespaces threads destructors
calendar concurrency.mailboxes classes assocs combinators
irc.messages.parser irc.client.base irc.client.chats
irc.client.participants irc.client.internals ;
EXCLUDE: irc.messages => join ;
RENAME: join irc.messages => join_
IN: irc.client.internals.tests

! Streams for testing
TUPLE: mb-writer lines last-line disposed ;
TUPLE: mb-reader lines disposed ;
: <mb-writer> ( -- mb-writer ) V{ } clone V{ } clone f mb-writer boa ;
: <mb-reader> ( -- mb-reader ) <mailbox> f mb-reader boa ;
: push-line ( line test-reader-stream -- ) lines>> mailbox-put ;
: <test-stream> ( -- stream ) <mb-reader> <mb-writer> <duplex-stream> ;
M: mb-writer stream-write ( line mb-writer -- ) last-line>> push ;
M: mb-writer stream-flush ( mb-writer -- ) drop ;
M: mb-reader stream-readln ( mb-reader -- str/f ) lines>> mailbox-get ;
M: mb-writer stream-nl ( mb-writer -- )
    [ [ last-line>> concat ] [ lines>> ] bi push ] keep
    V{ } clone >>last-line drop ;
M: mb-reader dispose f swap push-line ;
M: mb-writer dispose drop ;

: spawn-client ( -- irc-client )
    "someserver" irc-port "factorbot" f <irc-profile>
    <irc-client>
        t >>is-ready
        t >>is-running
        <test-stream> >>stream
    dup [ spawn-irc yield ] with-irc ;

! to be used inside with-irc quotations
: %add-named-chat ( chat -- ) (attach-chat) ;
: %push-line ( line -- ) irc> stream>> in>> push-line yield ;
: %push-lines ( lines -- ) [ %push-line ] each ;
: %join ( channel -- ) <irc-channel-chat> (attach-chat) ;
: %pop-output-line ( -- string ) irc> stream>> out>> lines>> pop ;

: read-matching-message ( chat quot: ( msg -- ? ) -- irc-message )
    [ in-messages>> 0.1 seconds ] dip mailbox-get-timeout? ; inline

: spawning-irc ( quot: ( -- ) -- )
    [ spawn-client ] dip [ (terminate-irc) ] compose with-irc ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                       TESTS
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[ { t } [ irc> nick>> me? ] unit-test

  { "factorbot" } [ irc> nick>> ] unit-test

  { "#factortest" } [ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
                      string>irc-message chat-name ] unit-test

  { "someuser" } [ ":someuser!n=user@some.where PRIVMSG factorbot :hi"
                   string>irc-message chat-name ] unit-test
] spawning-irc

{ privmsg "#channel" "hello" } [
    "#channel" "hello" strings>privmsg
    [ class ] [ target>> ] [ trailing>> ] tri
] unit-test

! Test login and nickname set
[ { "factorbot2" } [
    ":some.where 001 factorbot2 :Welcome factorbot2" %push-line
    irc> nick>>
  ] unit-test
] spawning-irc

! Test connect
{ V{ "NICK factorbot" "USER factorbot hostname servername :irc.factor" } } [
    "someserver" irc-port "factorbot" f <irc-profile> <irc-client>
    [ 2drop <test-stream> t ] >>connect
    [
        (connect-irc)
        (do-login)
        irc> stream>> out>> lines>>
        (terminate-irc)
    ] with-irc
] unit-test

! Test join
[ { "JOIN #factortest" } [
      "#factortest" %join %pop-output-line
  ] unit-test
] spawning-irc

[ { join_ "#factortest"} [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      { ":factorbot!n=factorbo@some.where JOIN :#factortest"
        ":ircserver.net 353 factorbot @ #factortest :@factorbot "
        ":ircserver.net 366 factorbot #factortest :End of /NAMES list."
        ":ircserver.net 477 factorbot #factortest :[ircserver-info] blah blah"
      } %push-lines
      [ join? ] read-matching-message
      [ class ] [ channel>> ] bi
  ] unit-test
] spawning-irc

[ { privmsg "#factortest" "hello" } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      ":somebody!n=somebody@some.where PRIVMSG #factortest :hello" %push-line
      [ privmsg? ] read-matching-message
      [ class ] [ target>> ] [ trailing>> ] tri
  ] unit-test
] spawning-irc

[ { privmsg "factorbot" "hello" } [
      "ircuser" <irc-nick-chat>  [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net PRIVMSG factorbot :hello" %push-line
      [ privmsg? ] read-matching-message
      [ class ] [ target>> ] [ trailing>> ] tri
  ] unit-test
] spawning-irc

[ { mode "#factortest" "+ns" } [
      "#factortest" <irc-channel-chat>  [ %add-named-chat ] keep
      ":ircserver.net MODE #factortest +ns" %push-line
      [ mode? ] read-matching-message
      [ class ] [ name>> ] [ mode>> ] tri
  ] unit-test
] spawning-irc

! Participant lists tests
[ { { "ircuser" } } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net JOIN :#factortest" %push-line
      participants>> keys
  ] unit-test
] spawning-irc

[ { { "ircuser2" } } [
      "#factortest" <irc-channel-chat>
      { "ircuser2" "ircuser" } [ over join-participant ] each
      [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net PART #factortest" %push-line
      participants>> keys
  ] unit-test
] spawning-irc

[ { { "ircuser2" } } [
      "#factortest" <irc-channel-chat>
      { "ircuser2" "ircuser" } [ over join-participant ] each
      [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net QUIT" %push-line
      participants>> keys
  ] unit-test
] spawning-irc

[ { { "ircuser2" } } [
      "#factortest" <irc-channel-chat>
      { "ircuser2" "ircuser" } [ over join-participant ] each
      [ %add-named-chat ] keep
      ":ircuser2!n=user2@isp.net KICK #factortest ircuser" %push-line
      participants>> keys
  ] unit-test
] spawning-irc

[ { H{ { "ircuser2" T{ participant { nick "ircuser2" } } } } } [
      "#factortest" <irc-channel-chat>
      "ircuser" over join-participant
      [ %add-named-chat ] keep
      ":ircuser!n=user2@isp.net NICK :ircuser2" %push-line
      participants>>
  ] unit-test
] spawning-irc

[ { H{ { "factorbot" T{ participant { nick "factorbot" } { operator t } } }
       { "ircuser" T{ participant { nick "ircuser" } } }
       { "voiced" T{ participant { nick "voiced" } { voice t } } } } } [
      "#factortest" <irc-channel-chat>
      "ircuser" over join-participant
      [ %add-named-chat ] keep
      { ":ircserver.net 353 factorbot @ #factortest :@factorbot "
        ":ircserver.net 353 factorbot @ #factortest :ircuser2 "
        ":ircserver.net 366 factorbot #factortest :End of /NAMES list."
        ":ircserver.net 353 factorbot @ #factortest :@factorbot +voiced "
        ":ircserver.net 353 factorbot @ #factortest :ircuser "
        ":ircserver.net 366 factorbot #factortest :End of /NAMES list."
      } %push-lines
      participants>>
  ] unit-test
] spawning-irc

[ { mode "#factortest" "+o" "ircuser" } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      "ircuser" over join-participant
      ":ircserver.net MODE #factortest +o ircuser" %push-line
      [ mode? ] read-matching-message
      { [ class ] [ name>> ] [ mode>> ] [ parameter>> ] } cleave
  ] unit-test
] spawning-irc

[ { T{ participant { nick "ircuser" } { operator t } } } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      "ircuser" over join-participant
      ":ircserver.net MODE #factortest +o ircuser" %push-line
      participants>> "ircuser" swap at
  ] unit-test
] spawning-irc

! Send privmsg
[ { "PRIVMSG #factortest :hello" } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      "hello" swap (speak) %pop-output-line
  ] unit-test
] spawning-irc
