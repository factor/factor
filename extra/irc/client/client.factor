! Copyright (C) 2008 Bruno Deferrari, Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.mailboxes kernel io.sockets io.encodings.8-bit calendar
       accessors destructors namespaces io assocs arrays qualified fry
       continuations threads strings classes combinators splitting hashtables
       ascii irc.messages irc.messages.private ;
RENAME: join sequences => sjoin
EXCLUDE: sequences => join ;
IN: irc.client

! ======================================
! Setup and running objects
! ======================================

SYMBOL: current-irc-client

: irc-port 6667 ; ! Default irc port

TUPLE: irc-profile server port nickname password ;
C: <irc-profile> irc-profile

TUPLE: irc-client profile stream in-messages out-messages join-messages
       listeners is-running connect reconnect-time ;
: <irc-client> ( profile -- irc-client )
    f <mailbox> <mailbox> <mailbox> H{ } clone f
    [ <inet> latin1 <client> ] 15 seconds irc-client boa ;

TUPLE: irc-listener in-messages out-messages ;
TUPLE: irc-server-listener < irc-listener ;
TUPLE: irc-channel-listener < irc-listener name password timeout participants ;
TUPLE: irc-nick-listener < irc-listener name ;
SYMBOL: +server-listener+

: <irc-listener> ( -- irc-listener ) <mailbox> <mailbox> irc-listener boa ;

: <irc-server-listener> ( -- irc-server-listener )
     <mailbox> <mailbox> irc-server-listener boa ;

: <irc-channel-listener> ( name -- irc-channel-listener )
     [ <mailbox> <mailbox> ] dip f 60 seconds H{ } clone irc-channel-listener boa ;

: <irc-nick-listener> ( name -- irc-nick-listener )
     [ <mailbox> <mailbox> ] dip irc-nick-listener boa ;

! ======================================
! Message objects
! ======================================

SINGLETON: irc-end          ! sent when the client isn't running anymore
SINGLETON: irc-disconnected ! sent when connection is lost
SINGLETON: irc-connected    ! sent when connection is established
UNION: irc-broadcasted-message irc-end irc-disconnected irc-connected ;

: terminate-irc ( irc-client -- )
    [ [ irc-end ] dip in-messages>> mailbox-put ]
    [ [ f ] dip (>>is-running) ]
    [ stream>> dispose ]
    tri ;

<PRIVATE

! ======================================
! Utils
! ======================================

: irc> ( -- irc-client ) current-irc-client get ;
: irc-stream> ( -- stream ) irc> stream>> ;
: irc-write ( s -- ) irc-stream> stream-write ;
: irc-print ( s -- ) irc-stream> [ stream-print ] keep stream-flush ;
: listener> ( name -- listener/f ) irc> listeners>> at ;
: unregister-listener ( name -- ) irc> listeners>> delete-at ;

: to-listener ( message name -- )
    listener> [ +server-listener+ listener> ] unless*
    [ in-messages>> mailbox-put ] [ drop ] if* ;

: remove-participant ( nick channel -- )
    listener> [ participants>> delete-at ] [ drop ] if* ;

: remove-participant-from-all ( nick -- )
    irc> listeners>>
    [ irc-channel-listener? [ swap remove-participant ] [ 2drop ] if ] with
    assoc-each ;

: add-participant ( nick mode channel -- )
    listener> [ participants>> set-at ] [ 2drop ] if* ;

DEFER: me?

: maybe-forward-join ( join -- )
    [ prefix>> parse-name me? ] keep and
    [ irc> join-messages>> mailbox-put ] when* ;

! ======================================
! IRC client messages
! ======================================

: /NICK ( nick -- )
    "NICK " irc-write irc-print ;

: /LOGIN ( nick -- )
    dup /NICK
    "USER " irc-write irc-write
    " hostname servername :irc.factor" irc-print ;

: /CONNECT ( server port -- stream )
    irc> connect>> call drop ;

: /JOIN ( channel password -- )
    "JOIN " irc-write
    [ [ " :" ] dip 3append ] when* irc-print ;

: /PART ( channel text -- )
    [ "PART " irc-write irc-write ] dip
    " :" irc-write irc-print ;

: /KICK ( channel who -- )
    [ "KICK " irc-write irc-write ] dip
    " " irc-write irc-print ;

: /PRIVMSG ( nick line -- )
    [ "PRIVMSG " irc-write irc-write ] dip
    " :" irc-write irc-print ;

: /ACTION ( nick line -- )
    [ 1 , "ACTION " % % 1 , ] "" make /PRIVMSG ;

: /QUIT ( text -- )
    "QUIT :" irc-write irc-print ;

: /PONG ( text -- )
    "PONG " irc-write irc-print ;

! ======================================
! Server message handling
! ======================================

: me? ( string -- ? )
    irc> profile>> nickname>> = ;

: irc-message-origin ( irc-message -- name )
    dup name>> me? [ prefix>> parse-name ] [ name>> ] if ;

: broadcast-message-to-listeners ( message -- )
    irc> listeners>> values [ in-messages>> mailbox-put ] with each ;

GENERIC: handle-incoming-irc ( irc-message -- )

M: irc-message handle-incoming-irc ( irc-message -- )
    +server-listener+ listener> [ in-messages>> mailbox-put ] [ drop ] if* ;

M: logged-in handle-incoming-irc ( logged-in -- )
    name>> irc> profile>> (>>nickname) ;

M: ping handle-incoming-irc ( ping -- )
    trailing>> /PONG ;

M: nick-in-use handle-incoming-irc ( nick-in-use -- )
    name>> "_" append /NICK ;

M: privmsg handle-incoming-irc ( privmsg -- )
    dup irc-message-origin to-listener ;

M: join handle-incoming-irc ( join -- )
    [ maybe-forward-join ]
    [ dup trailing>> to-listener ]
    [ [ drop f ] [ prefix>> parse-name ] [ trailing>> ] tri add-participant ]
    tri ;

M: part handle-incoming-irc ( part -- )
    [ dup channel>> to-listener ] keep
    [ prefix>> parse-name ] [ channel>> ] bi remove-participant ;

M: kick handle-incoming-irc ( kick -- )
    [ dup channel>>  to-listener ]
    [ [ who>> ] [ channel>> ] bi remove-participant ] 
    [ dup who>> me? [ unregister-listener ] [ drop ] if ]
    tri ;

M: quit handle-incoming-irc ( quit -- )
    [ prefix>> parse-name remove-participant-from-all ] keep
    call-next-method ;

: >nick/mode ( string -- nick mode )
    dup first "+@" member? [ unclip ] [ f ] if ;

: names-reply>participants ( names-reply -- participants )
    trailing>> [ blank? ] trim " " split
    [ >nick/mode 2array ] map >hashtable ;

M: names-reply handle-incoming-irc ( names-reply -- )
    [ names-reply>participants ] [ channel>> listener> ] bi (>>participants) ;

M: irc-broadcasted-message handle-incoming-irc ( irc-broadcasted-message -- )
    broadcast-message-to-listeners ;

! ======================================
! Client message handling
! ======================================

GENERIC: handle-outgoing-irc ( obj -- )

! M: irc-message handle-outgoing-irc ( irc-message -- )
!    irc-message>string irc-print ;

M: privmsg handle-outgoing-irc ( privmsg -- )
    [ name>> ] [ trailing>> ] bi /PRIVMSG ;

M: part handle-outgoing-irc ( privmsg -- )
    [ channel>> ] [ trailing>> "" or ] bi /PART ;

! ======================================
! Reader/Writer
! ======================================

: irc-mailbox-get ( mailbox quot -- )
    [ 5 seconds ] dip
    '[ , , ,  [ mailbox-get-timeout ] dip call ]
    [ drop ] recover ; inline

: handle-reader-message ( irc-message -- )
    irc> in-messages>> mailbox-put ;

DEFER: (connect-irc)

: (handle-disconnect) ( -- )
    irc>
        [ [ irc-disconnected ] dip in-messages>> mailbox-put ]
        [ dup reconnect-time>> sleep (connect-irc) ]
        [ profile>> nickname>> /LOGIN ]
    tri ;

! FIXME: do something with the exception, store somewhere to help debugging
: handle-disconnect ( error -- )
    drop irc> is-running>> [ (handle-disconnect) ] when ;

: (reader-loop) ( -- )
    irc> stream>> [
        |dispose stream-readln [
            parse-irc-line handle-reader-message
        ] [
            irc> terminate-irc
        ] if*
    ] with-destructors ;

: reader-loop ( -- )
    [ (reader-loop) ] [ handle-disconnect ] recover ;

: writer-loop ( -- )
    irc> out-messages>> [ handle-outgoing-irc ] irc-mailbox-get ;

! ======================================
! Processing loops
! ======================================

: in-multiplexer-loop ( -- )
    irc> in-messages>> [ handle-incoming-irc ] irc-mailbox-get ;

: strings>privmsg ( name string -- privmsg )
    privmsg new [ (>>trailing) ] keep [ (>>name) ] keep ;

: maybe-annotate-with-name ( name obj -- obj )
    {
        { [ dup string? ] [ strings>privmsg ] }
        { [ dup privmsg instance? ] [ swap >>name ] }
    } cond ;

: listener-loop ( name listener -- )
    out-messages>> swap
    '[ , swap maybe-annotate-with-name irc> out-messages>> mailbox-put ]
    irc-mailbox-get ;

: spawn-irc-loop ( quot name -- )
    [ '[ irc> is-running>> [ @ ] when irc> is-running>> ] ] dip
    spawn-server drop ;

: spawn-irc ( -- )
    [ reader-loop ] "irc-reader-loop" spawn-irc-loop
    [ writer-loop ] "irc-writer-loop" spawn-irc-loop
    [ in-multiplexer-loop ] "in-multiplexer-loop" spawn-irc-loop ;

! ======================================
! Listener join request handling
! ======================================

: set+run-listener ( name irc-listener -- )
    [ '[ , , listener-loop ] "listener" spawn-irc-loop ]
    [ swap irc> listeners>> set-at ]
    2bi ;

GENERIC: (add-listener) ( irc-listener -- )

M: irc-channel-listener (add-listener) ( irc-channel-listener -- )
    [ [ name>> ] [ password>> ] bi /JOIN ]
    [ [ [ drop irc> join-messages>> ]
        [ timeout>> ]
        [ name>> '[ trailing>> , = ] ]
        tri mailbox-get-timeout? trailing>> ] keep set+run-listener
    ] bi ;

M: irc-nick-listener (add-listener) ( irc-nick-listener -- )
    [ name>> ] keep set+run-listener ;

M: irc-server-listener (add-listener) ( irc-server-listener -- )
    [ +server-listener+ ] dip set+run-listener ;

GENERIC: (remove-listener) ( irc-listener -- )

M: irc-nick-listener (remove-listener) ( irc-nick-listener -- )
    name>> unregister-listener ;

M: irc-channel-listener (remove-listener) ( irc-channel-listener -- )
    [ [ out-messages>> ] [ name>> ] bi
      [ \ part new ] dip >>channel mailbox-put ] keep
    name>> unregister-listener ;

M: irc-server-listener (remove-listener) ( irc-server-listener -- )
   drop +server-listener+ unregister-listener ;

: (connect-irc) ( irc-client -- )
    [ profile>> [ server>> ] [ port>> ] bi /CONNECT ] keep
        swap >>stream
        t >>is-running
    in-messages>> [ irc-connected ] dip mailbox-put ;

: with-irc-client ( irc-client quot -- )
    [ current-irc-client ] dip with-variable ; inline

PRIVATE>

: connect-irc ( irc-client -- )
    dup [
        [ (connect-irc) ] [ profile>> nickname>> /LOGIN ] bi
        spawn-irc
    ] with-irc-client ;

: add-listener ( irc-listener irc-client -- )
    swap '[ , (add-listener) ] with-irc-client ;

: remove-listener ( irc-listener irc-client -- )
    swap '[ , (remove-listener) ] with-irc-client ;

: write-message ( message irc-listener -- ) out-messages>> mailbox-put ;
: read-message ( irc-listener -- message ) in-messages>> mailbox-get ;
