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

! participant modes
SYMBOL: +operator+
SYMBOL: +voice+
SYMBOL: +normal+

: participant-mode ( n -- mode )
    H{ { 64 +operator+ } { 43 +voice+ } { 0 +normal+ } } at ;

! participant changed actions
SYMBOL: +join+
SYMBOL: +part+
SYMBOL: +mode+

! listener objects
: <irc-listener> ( -- irc-listener ) <mailbox> <mailbox> irc-listener boa ;

: <irc-server-listener> ( -- irc-server-listener )
     <mailbox> <mailbox> irc-server-listener boa ;

: <irc-channel-listener> ( name -- irc-channel-listener )
     [ <mailbox> <mailbox> ] dip f 60 seconds H{ } clone
     irc-channel-listener boa ;

: <irc-nick-listener> ( name -- irc-nick-listener )
     [ <mailbox> <mailbox> ] dip irc-nick-listener boa ;

! ======================================
! Message objects
! ======================================

TUPLE: participant-changed nick action ;
C: <participant-changed> participant-changed

SINGLETON: irc-listener-end ! send to a listener to stop its execution
SINGLETON: irc-end          ! sent when the client isn't running anymore
SINGLETON: irc-disconnected ! sent when connection is lost
SINGLETON: irc-connected    ! sent when connection is established
UNION: irc-broadcasted-message irc-end irc-disconnected irc-connected ;

: terminate-irc ( irc-client -- )
    [ is-running>> ] keep and [
        [ [ irc-end ] dip in-messages>> mailbox-put ]
        [ [ f ] dip (>>is-running) ]
        [ stream>> dispose ]
        tri
    ] when* ;

<PRIVATE

SYMBOL: current-irc-client

! ======================================
! Utils
! ======================================

: irc> ( -- irc-client ) current-irc-client get ;
: irc-stream> ( -- stream ) irc> stream>> ;
: irc-write ( s -- ) irc-stream> stream-write ;
: irc-print ( s -- ) irc-stream> [ stream-print ] keep stream-flush ;
: listener> ( name -- listener/f ) irc> listeners>> at ;

: maybe-mailbox-get ( mailbox quot: ( irc-message -- ) -- )
    [ dup mailbox-empty? [ drop yield ] ] dip '[ mailbox-get @ ] if ; inline

GENERIC: to-listener ( message obj -- )

M: string to-listener ( message string -- )
    listener> [ +server-listener+ listener> ] unless*
    [ to-listener ] [ drop ] if* ;

: unregister-listener ( name -- )
    irc> listeners>>
        [ at [ irc-listener-end ] dip to-listener ]
        [ delete-at ]
    2bi ;

M: irc-listener to-listener ( message irc-listener -- )
    in-messages>> mailbox-put ;

: remove-participant ( nick channel -- )
    listener> [ participants>> delete-at ] [ drop ] if* ;

: listeners-with-participant ( nick -- seq )
    irc> listeners>> values
    [ dup irc-channel-listener? [ participants>> key? ] [ 2drop f ] if ]
    with filter ;

: remove-participant-from-all ( nick -- )
    dup listeners-with-participant [ delete-at ] with each ;

: add-participant ( mode nick channel -- )
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
    irc> listeners>> values [ to-listener ] with each ;

GENERIC: handle-participant-change ( irc-message -- )

M: join handle-participant-change ( join -- )
    [ prefix>> parse-name +join+ <participant-changed> ]
    [ trailing>> ] bi to-listener ;

M: part handle-participant-change ( part -- )
    [ prefix>> parse-name +part+ <participant-changed> ]
    [ channel>> ] bi to-listener ;

M: kick handle-participant-change ( kick -- )
    [ who>> +part+ <participant-changed> ]
    [ channel>> ] bi to-listener ;

M: quit handle-participant-change ( quit -- )
    prefix>> parse-name
    [ +part+ <participant-changed> ] [ listeners-with-participant ] bi
    [ to-listener ] with each ;

GENERIC: handle-incoming-irc ( irc-message -- )

M: irc-message handle-incoming-irc ( irc-message -- )
    +server-listener+ listener> [ to-listener ] [ drop ] if* ;

M: logged-in handle-incoming-irc ( logged-in -- )
    name>> irc> profile>> (>>nickname) ;

M: ping handle-incoming-irc ( ping -- )
    trailing>> /PONG ;

M: nick-in-use handle-incoming-irc ( nick-in-use -- )
    name>> "_" append /NICK ;

M: privmsg handle-incoming-irc ( privmsg -- )
    dup irc-message-origin to-listener ;

M: join handle-incoming-irc ( join -- )
    { [ maybe-forward-join ] ! keep
      [ dup trailing>> to-listener ]
      [ [ drop f ] [ prefix>> parse-name ] [ trailing>> ] tri add-participant ]
      [ handle-participant-change ]
    } cleave ;

M: part handle-incoming-irc ( part -- )
    [ dup channel>> to-listener ]
    [ [ prefix>> parse-name ] [ channel>> ] bi remove-participant ]
    [ handle-participant-change ]
    tri ;

M: kick handle-incoming-irc ( kick -- )
    { [ dup channel>>  to-listener ]
      [ [ who>> ] [ channel>> ] bi remove-participant ]
      [ handle-participant-change ]
      [ dup who>> me? [ unregister-listener ] [ drop ] if ]
    } cleave ;

M: quit handle-incoming-irc ( quit -- )
    { [ dup prefix>> parse-name listeners-with-participant
        [ to-listener ] with each ]
      [ handle-participant-change ]
      [ prefix>> parse-name remove-participant-from-all ]
      [ call-next-method ]
    } cleave ;

: >nick/mode ( string -- nick mode )
    dup first "+@" member? [ unclip ] [ 0 ] if participant-mode ;

: names-reply>participants ( names-reply -- participants )
    trailing>> [ blank? ] trim " " split
    [ >nick/mode 2array ] map >hashtable ;

M: names-reply handle-incoming-irc ( names-reply -- )
    [ names-reply>participants ] [ channel>> listener> ] bi
    [ (>>participants) ] [ drop ] if* ;

M: irc-broadcasted-message handle-incoming-irc ( irc-broadcasted-message -- )
    broadcast-message-to-listeners ;

! ======================================
! Client message handling
! ======================================

GENERIC: handle-outgoing-irc ( obj -- )

M: irc-message handle-outgoing-irc ( irc-message -- )
    irc-message>client-line irc-print ;

! ======================================
! Reader/Writer
! ======================================

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

: reader-loop ( -- ? )
    [ (reader-loop) ] [ handle-disconnect ] recover t ;

: writer-loop ( -- ? )
    irc> out-messages>> [ handle-outgoing-irc ] maybe-mailbox-get t ;

! ======================================
! Processing loops
! ======================================

: in-multiplexer-loop ( -- ? )
    irc> in-messages>> [ handle-incoming-irc ] maybe-mailbox-get t ;

: strings>privmsg ( name string -- privmsg )
    privmsg new [ (>>trailing) ] keep [ (>>name) ] keep ;

: maybe-annotate-with-name ( name obj -- obj )
    { { [ dup string? ] [ strings>privmsg ] }
      { [ dup privmsg instance? ] [ swap >>name ] }
      [ nip ]
    } cond ;

: listener-loop ( name -- ? )
    dup listener> [
        out-messages>> [ maybe-annotate-with-name
                         irc> out-messages>> mailbox-put ] with
        maybe-mailbox-get t
    ] [ drop f ] if* ;

: spawn-irc-loop ( quot: ( -- ? ) name -- )
    [ '[ irc> is-running>> [ @ ] [ f ] if ] ] dip
    spawn-server drop ;

: spawn-irc ( -- )
    [ reader-loop ] "irc-reader-loop" spawn-irc-loop
    [ writer-loop ] "irc-writer-loop" spawn-irc-loop
    [ in-multiplexer-loop ] "in-multiplexer-loop" spawn-irc-loop ;

! ======================================
! Listener join request handling
! ======================================

: set+run-listener ( name irc-listener -- )
    over irc> listeners>> set-at
    '[ , listener-loop ] "listener" spawn-irc-loop ;

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
    [ [ name>> ] [ out-messages>> ] bi
      [ [ part new ] dip >>channel ] dip mailbox-put ] keep
    name>> unregister-listener ;

M: irc-server-listener (remove-listener) ( irc-server-listener -- )
   drop +server-listener+ unregister-listener ;

: (connect-irc) ( irc-client -- )
    [ profile>> [ server>> ] [ port>> ] bi /CONNECT ] keep
        swap >>stream
        t >>is-running
    in-messages>> [ irc-connected ] dip mailbox-put ;

: with-irc-client ( irc-client quot: ( -- ) -- )
    [ current-irc-client ] dip with-variable ; inline

PRIVATE>

: connect-irc ( irc-client -- )
    [ irc>
      [ (connect-irc) ] [ profile>> nickname>> /LOGIN ] bi
      spawn-irc ] with-irc-client ;

: add-listener ( irc-listener irc-client -- )
    swap '[ , (add-listener) ] with-irc-client ;

: remove-listener ( irc-listener irc-client -- )
    swap '[ , (remove-listener) ] with-irc-client ;

: write-message ( message irc-listener -- ) out-messages>> mailbox-put ;
: read-message ( irc-listener -- message ) in-messages>> mailbox-get ;
