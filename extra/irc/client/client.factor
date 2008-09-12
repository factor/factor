! Copyright (C) 2008 Bruno Deferrari, Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.mailboxes kernel io.sockets io.encodings.8-bit calendar
       accessors destructors namespaces io assocs arrays qualified fry
       continuations threads strings classes combinators splitting hashtables
       ascii irc.messages ;
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
SYMBOL: +nick+

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

TUPLE: participant-changed nick action parameter ;
C: <participant-changed> participant-changed

SINGLETON: irc-listener-end ! send to a listener to stop its execution
SINGLETON: irc-end          ! sent when the client isn't running anymore
SINGLETON: irc-disconnected ! sent when connection is lost
SINGLETON: irc-connected    ! sent when connection is established

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
: irc-send ( irc-message -- ) irc> out-messages>> mailbox-put ;
: listener> ( name -- listener/f ) irc> listeners>> at ;

: maybe-mailbox-get ( mailbox quot: ( irc-message -- ) -- )
    [ dup mailbox-empty? [ drop 0.1 sleep ] ] dip '[ mailbox-get @ ] if ; inline

GENERIC: to-listener ( message obj -- )

M: string to-listener ( message string -- )
    listener> [ +server-listener+ listener> ] unless*
    [ to-listener ] [ drop ] if* ;

M: irc-listener to-listener ( message irc-listener -- )
    in-messages>> mailbox-put ;

: unregister-listener ( name -- )
    irc> listeners>>
        [ at [ irc-listener-end ] dip to-listener ]
        [ delete-at ]
    2bi ;

: (remove-participant) ( nick listener -- )
    [ participants>> delete-at ]
    [ [ +part+ f <participant-changed> ] dip to-listener ] 2bi ;

: remove-participant ( nick channel -- )
    listener> [ (remove-participant) ] [ drop ] if* ;

: listeners-with-participant ( nick -- seq )
    irc> listeners>> values
    [ dup irc-channel-listener? [ participants>> key? ] [ 2drop f ] if ]
    with filter ;

: to-listeners-with-participant ( message nickname -- )
    listeners-with-participant [ to-listener ] with each ;

: remove-participant-from-all ( nick -- )
    dup listeners-with-participant [ (remove-participant) ] with each ;

: notify-rename ( newnick oldnick listener -- )
    [ participant-changed new +nick+ >>action
      [ (>>nick) ] [ (>>parameter) ] [ ] tri ] dip to-listener ;

: rename-participant ( newnick oldnick listener -- )
    [ participants>> [ delete-at* drop ] [ [ swap ] dip set-at ] bi ]
    [ notify-rename ] 3bi ;

: rename-participant-in-all ( oldnick newnick -- )
    swap dup listeners-with-participant [ rename-participant ] with with each ;

: add-participant ( mode nick channel -- )
    listener> [
        [ participants>> set-at ]
        [ [ +join+ f <participant-changed> ] dip to-listener ] 2bi
    ] [ 2drop ] if* ;

DEFER: me?

: maybe-forward-join ( join -- )
    [ irc-message-sender me? ] keep and
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

: /PONG ( text -- )
    "PONG " irc-write irc-print ;

! ======================================
! Server message handling
! ======================================

: me? ( string -- ? )
    irc> profile>> nickname>> = ;

GENERIC: forward-name ( irc-message -- name )
M: join forward-name ( join -- name ) trailing>> ;
M: part forward-name ( part -- name ) channel>> ;
M: kick forward-name ( kick -- name ) channel>> ;
M: mode forward-name ( mode -- name ) channel>> ;
M: privmsg forward-name ( privmsg -- name )
    dup name>> me? [ irc-message-sender ] [ name>> ] if ;

UNION: single-forward join part kick mode privmsg ;
UNION: multiple-forward nick quit ;
UNION: broadcast-forward irc-end irc-disconnected irc-connected ;
GENERIC: forward-message ( irc-message -- )

M: irc-message forward-message ( irc-message -- )
    +server-listener+ listener> [ to-listener ] [ drop ] if* ;

M: single-forward forward-message ( forward-single -- )
    dup forward-name to-listener ;

M: multiple-forward forward-message ( multiple-forward -- )
    dup irc-message-sender to-listeners-with-participant ;

M: join forward-message ( join -- )
    [ maybe-forward-join ] [ call-next-method ] bi ;
    
M: broadcast-forward forward-message ( irc-broadcasted-message -- )
    irc> listeners>> values [ to-listener ] with each ;

GENERIC: process-message ( irc-message -- )

M: object process-message ( object -- )
    drop ;
    
M: logged-in process-message ( logged-in -- )
    name>> irc> profile>> (>>nickname) ;

M: ping process-message ( ping -- )
    trailing>> /PONG ;

M: nick-in-use process-message ( nick-in-use -- )
    name>> "_" append /NICK ;

M: join process-message ( join -- )
    [ drop +normal+ ] [ irc-message-sender ] [ trailing>> ] tri add-participant ;

M: part process-message ( part -- )
    [ irc-message-sender ] [ channel>> ] bi remove-participant ;

M: kick process-message ( kick -- )
    [ [ who>> ] [ channel>> ] bi remove-participant ]
    [ dup who>> me? [ unregister-listener ] [ drop ] if ]
    bi ;

M: quit process-message ( quit -- )
    irc-message-sender remove-participant-from-all ;

M: nick process-message ( nick -- )
    [ irc-message-sender ] [ trailing>> ] bi rename-participant-in-all ;

: >nick/mode ( string -- nick mode )
    dup first "+@" member? [ unclip ] [ 0 ] if participant-mode ;

: names-reply>participants ( names-reply -- participants )
    trailing>> [ blank? ] trim " " split
    [ >nick/mode 2array ] map >hashtable ;

M: names-reply process-message ( names-reply -- )
    [ names-reply>participants ] [ channel>> listener> ] bi [
        [ (>>participants) ]
        [ [ f f f <participant-changed> ] dip name>> to-listener ] bi
    ] [ drop ] if* ;

: handle-incoming-irc ( irc-message -- )
    [ forward-message ] [ process-message ] bi ;

! ======================================
! Client message handling
! ======================================

: handle-outgoing-irc ( irc-message -- )
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
    [ \ current-irc-client ] dip with-variable ; inline

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
