USING: kernel tools.test accessors arrays sequences
       io io.streams.duplex namespaces threads destructors
       calendar irc.client.private irc.client irc.messages
       concurrency.mailboxes classes assocs combinators irc.messages.parser ;
EXCLUDE: irc.messages => join ;
RENAME: join irc.messages => join_
IN: irc.client.tests

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
    dup [ spawn-irc yield ] with-irc-client ;

! to be used inside with-irc-client quotations
: %add-named-chat ( chat -- ) irc> attach-chat ;
: %push-line ( line -- ) irc> stream>> in>> push-line yield ;
: %join ( channel -- ) <irc-channel-chat> irc> attach-chat ;

: read-matching-message ( chat quot: ( msg -- ? ) -- irc-message )
    [ in-messages>> 0.1 seconds ] dip mailbox-get-timeout? ;

: with-irc ( quot: ( -- ) -- )
    [ spawn-client ] dip [ irc> terminate-irc ] compose with-irc-client ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                       TESTS
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[ { t } [ irc> nick>> me? ] unit-test

  { "factorbot" } [ irc> nick>> ] unit-test

!  { "someuser" } [ "someuser!n=user@some.where" parse-name ] unit-test

  { "#factortest" } [ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
                      string>irc-message forward-name ] unit-test

  { "someuser" } [ ":someuser!n=user@some.where PRIVMSG factorbot :hi"
                   string>irc-message forward-name ] unit-test
] with-irc

{ privmsg "#channel" "hello" } [
    "#channel" "hello" strings>privmsg
    [ class ] [ target>> ] [ trailing>> ] tri
] unit-test

! Test login and nickname set
[ { "factorbot2" } [
    ":some.where 001 factorbot2 :Welcome factorbot2" %push-line
    irc> nick>>
  ] unit-test
] with-irc

! Test connect
{ V{ "NICK factorbot" "USER factorbot hostname servername :irc.factor" } } [
    "someserver" irc-port "factorbot" f <irc-profile> <irc-client>
    [ 2drop <test-stream> t ] >>connect
    [ connect-irc ] [ stream>> out>> lines>> ] [ terminate-irc ] tri
] unit-test

! Test join
[ { "JOIN #factortest" } [
      "#factortest" %join
      irc> stream>> out>> lines>> pop
  ] unit-test
] with-irc

[ { join_ "#factortest" } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      { ":factorbot!n=factorbo@some.where JOIN :#factortest"
        ":ircserver.net 353 factorbot @ #factortest :@factorbot "
        ":ircserver.net 366 factorbot #factortest :End of /NAMES list."
        ":ircserver.net 477 factorbot #factortest :[ircserver-info] blah blah"
      } [ %push-line ] each
      in-messages>> 0.1 seconds mailbox-get-timeout
      [ class ] [ trailing>> ] bi
  ] unit-test
] with-irc

[ { T{ participant-changed f "somebody" +join+ } } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      ":somebody!n=somebody@some.where JOIN :#factortest" %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc

[ { privmsg "#factortest" "hello" } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      ":somebody!n=somebody@some.where PRIVMSG #factortest :hello" %push-line
      [ privmsg? ] read-matching-message
      [ class ] [ target>> ] [ trailing>> ] tri
  ] unit-test
] with-irc

[ { privmsg "factorbot" "hello" } [
      "ircuser" <irc-nick-chat>  [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net PRIVMSG factorbot :hello" %push-line
      [ privmsg? ] read-matching-message
      [ class ] [ target>> ] [ trailing>> ] tri
  ] unit-test
] with-irc

[ { mode } [
      "#factortest" <irc-channel-chat>  [ %add-named-chat ] keep
      ":ircserver.net MODE #factortest +ns" %push-line
      [ mode? ] read-matching-message class
  ] unit-test
] with-irc

! Participant lists tests
[ { H{ { "ircuser" +normal+ } } } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net JOIN :#factortest" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "ircuser2" +normal+ } } } [
      "#factortest" <irc-channel-chat>
          H{ { "ircuser2" +normal+ }
             { "ircuser" +normal+ } } clone >>participants
      [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net PART #factortest" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "ircuser2" +normal+ } } } [
      "#factortest" <irc-channel-chat>
          H{ { "ircuser2" +normal+ }
             { "ircuser" +normal+ } } clone >>participants
      [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net QUIT" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "ircuser2" +normal+ } } } [
      "#factortest" <irc-channel-chat>
          H{ { "ircuser2" +normal+ }
             { "ircuser" +normal+ } } clone >>participants
      [ %add-named-chat ] keep
      ":ircuser2!n=user2@isp.net KICK #factortest ircuser" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "ircuser2" +normal+ } } } [
      "#factortest" <irc-channel-chat>
          H{ { "ircuser" +normal+ } } clone >>participants
      [ %add-named-chat ] keep
      ":ircuser!n=user2@isp.net NICK :ircuser2" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "factorbot" +operator+ } { "ircuser" +normal+ } } } [
      "#factortest" <irc-channel-chat>
          H{ { "ircuser" +normal+ } } clone >>participants
      [ %add-named-chat ] keep
      ":ircserver.net 353 factorbot @ #factortest :@factorbot " %push-line
      ":ircserver.net 353 factorbot @ #factortest :ircuser2 " %push-line
      ":ircserver.net 366 factorbot #factortest :End of /NAMES list." %push-line
      ":ircserver.net 353 factorbot @ #factortest :@factorbot " %push-line
      ":ircserver.net 353 factorbot @ #factortest :ircuser " %push-line
      ":ircserver.net 366 factorbot #factortest :End of /NAMES list." %push-line
      participants>>
  ] unit-test
] with-irc

! Namelist change notification
[ { T{ participant-changed f f f f } } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      ":ircserver.net 353 factorbot @ #factortest :@factorbot " %push-line
      ":ircserver.net 366 factorbot #factortest :End of /NAMES list." %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc

[ { T{ participant-changed f "ircuser" +part+ f } } [
      "#factortest" <irc-channel-chat>
          H{ { "ircuser" +normal+ } } clone >>participants
      [ %add-named-chat ] keep
      ":ircuser!n=user@isp.net QUIT" %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc

[ { T{ participant-changed f "ircuser" +nick+ "ircuser2" } } [
      "#factortest" <irc-channel-chat>
          H{ { "ircuser" +normal+ } } clone >>participants
      [ %add-named-chat ] keep
      ":ircuser!n=user2@isp.net NICK :ircuser2" %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc

! Mode change
[ { T{ participant-changed f "ircuser" +mode+ "+o" } } [
      "#factortest" <irc-channel-chat> [ %add-named-chat ] keep
      ":ircserver.net MODE #factortest +o ircuser" %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc
