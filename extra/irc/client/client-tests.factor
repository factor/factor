USING: kernel tools.test accessors arrays sequences qualified
       io io.streams.duplex namespaces threads
       calendar irc.client.private irc.client irc.messages.private
       concurrency.mailboxes classes assocs combinators ;
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

: spawn-client ( -- irc-client )
    "someserver" irc-port "factorbot" f <irc-profile>
    <irc-client>
        t >>is-running
        <test-stream> >>stream
    dup [ spawn-irc yield ] with-irc-client ;

! to be used inside with-irc-client quotations
: %add-named-listener ( listener -- ) [ name>> ] keep set+run-listener ;
: %join ( channel -- ) <irc-channel-listener> irc> add-listener ;
: %push-line ( line -- ) irc> stream>> in>> push-line yield ;

: read-matching-message ( listener quot: ( msg -- ? ) -- irc-message )
    [ in-messages>> 0.1 seconds ] dip mailbox-get-timeout? ;

: with-irc ( quot: ( -- ) -- )
    [ spawn-client ] dip [ f %push-line ] compose with-irc-client ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                       TESTS
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[ { t } [ irc> nick>> me? ] unit-test

  { "factorbot" } [ irc> nick>> ] unit-test

  { "someuser" } [ "someuser!n=user@some.where" parse-name ] unit-test

  { "#factortest" } [ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
                      parse-irc-line forward-name ] unit-test

  { "someuser" } [ ":someuser!n=user@some.where PRIVMSG factorbot :hi"
                   parse-irc-line forward-name ] unit-test
] with-irc

! Test login and nickname set
[ { "factorbot2" } [
     ":some.where 001 factorbot2 :Welcome factorbot2" %push-line
      irc> nick>>
  ] unit-test
] with-irc

[ { join_ "#factortest" } [
      { ":factorbot!n=factorbo@some.where JOIN :#factortest"
        ":ircserver.net 353 factorbot @ #factortest :@factorbot "
        ":ircserver.net 366 factorbot #factortest :End of /NAMES list."
        ":ircserver.net 477 factorbot #factortest :[ircserver-info] blah blah"
      } [ %push-line ] each
      irc> join-messages>> 0.1 seconds mailbox-get-timeout
      [ class ] [ trailing>> ] bi
  ] unit-test
] with-irc

[ { T{ participant-changed f "somebody" +join+ } } [
      "#factortest" <irc-channel-listener> [ %add-named-listener ] keep
      ":somebody!n=somebody@some.where JOIN :#factortest" %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc

[ { privmsg "#factortest" "hello" } [
      "#factortest" <irc-channel-listener> [ %add-named-listener ] keep
      ":somebody!n=somebody@some.where PRIVMSG #factortest :hello" %push-line
      [ privmsg? ] read-matching-message
      [ class ] [ name>> ] [ trailing>> ] tri
  ] unit-test
] with-irc

[ { privmsg "factorbot" "hello" } [
      "somedude" <irc-nick-listener>  [ %add-named-listener ] keep
      ":somedude!n=user@isp.net PRIVMSG factorbot :hello" %push-line
      [ privmsg? ] read-matching-message
      [ class ] [ name>> ] [ trailing>> ] tri
  ] unit-test
] with-irc

[ { mode } [
      "#factortest" <irc-channel-listener>  [ %add-named-listener ] keep
      ":ircserver.net MODE #factortest +ns" %push-line
      [ mode? ] read-matching-message class
  ] unit-test
] with-irc

! Participant lists tests
[ { H{ { "somedude" +normal+ } } } [
      "#factortest" <irc-channel-listener> [ %add-named-listener ] keep
      ":somedude!n=user@isp.net JOIN :#factortest" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "somedude2" +normal+ } } } [
      "#factortest" <irc-channel-listener>
          H{ { "somedude2" +normal+ }
             { "somedude" +normal+ } } clone >>participants
      [ %add-named-listener ] keep
      ":somedude!n=user@isp.net PART #factortest" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "somedude2" +normal+ } } } [
      "#factortest" <irc-channel-listener>
          H{ { "somedude2" +normal+ }
             { "somedude" +normal+ } } clone >>participants
      [ %add-named-listener ] keep
      ":somedude!n=user@isp.net QUIT" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "somedude2" +normal+ } } } [
      "#factortest" <irc-channel-listener>
          H{ { "somedude2" +normal+ }
             { "somedude" +normal+ } } clone >>participants
      [ %add-named-listener ] keep
      ":somedude2!n=user2@isp.net KICK #factortest somedude" %push-line
      participants>>
  ] unit-test
] with-irc

[ { H{ { "somedude2" +normal+ } } } [
      "#factortest" <irc-channel-listener>
          H{ { "somedude" +normal+ } } clone >>participants
      [ %add-named-listener ] keep
      ":somedude!n=user2@isp.net NICK :somedude2" %push-line
      participants>>
  ] unit-test
] with-irc

! Namelist change notification
[ { T{ participant-changed f f f f } } [
      "#factortest" <irc-channel-listener> [ %add-named-listener ] keep
      ":ircserver.net 353 factorbot @ #factortest :@factorbot " %push-line
      ":ircserver.net 366 factorbot #factortest :End of /NAMES list." %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc

[ { T{ participant-changed f "somedude" +part+ f } } [
      "#factortest" <irc-channel-listener>
          H{ { "somedude" +normal+ } } clone >>participants
      [ %add-named-listener ] keep
      ":somedude!n=user@isp.net QUIT" %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc

[ { T{ participant-changed f "somedude" +nick+ "somedude2" } } [
      "#factortest" <irc-channel-listener>
          H{ { "somedude" +normal+ } } clone >>participants
      [ %add-named-listener ] keep
      ":somedude!n=user2@isp.net NICK :somedude2" %push-line
      [ participant-changed? ] read-matching-message
  ] unit-test
] with-irc
