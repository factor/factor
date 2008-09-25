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

TUPLE: irc-client profile stream in-messages out-messages
       listeners is-running nick connect reconnect-time ;
: <irc-client> ( profile -- irc-client )
    [ f <mailbox> <mailbox> H{ } clone f ] keep nickname>>
    [ <inet> latin1 <client> ] 15 seconds irc-client boa ;

TUPLE: irc-listener in-messages client ;
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
     <mailbox> f irc-server-listener boa ;

: <irc-channel-listener> ( name -- irc-channel-listener )
     [ <mailbox> f ] dip f 60 seconds H{ } clone
     irc-channel-listener boa ;

: <irc-nick-listener> ( name -- irc-nick-listener )
     [ <mailbox> f ] dip irc-nick-listener boa ;

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
        f >>is-running
        [ in-messages>> ] [ out-messages>> ] bi 2array
        [ irc-end swap mailbox-put ] each
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
: channel-mode? ( mode -- ? ) name>> first "#&" member? ;
: me? ( string -- ? ) irc> nick>> = ;

GENERIC: to-listener ( message obj -- )

M: string to-listener
    listener> [ +server-listener+ listener> ] unless*
    [ to-listener ] [ drop ] if* ;

M: irc-listener to-listener in-messages>> mailbox-put ;

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
    [ [ irc-channel-listener? ] keep and [ participants>> key? ] when* ]
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
    listener>
    [ participants>> set-at ]
    [ [ +join+ f <participant-changed> ] dip to-listener ] 2bi ;

: change-participant-mode ( channel mode nick -- )
    rot listener>
    [ participants>> set-at ]
    [ [ [ +mode+ ] dip <participant-changed> ] dip to-listener ] 3bi ; ! FIXME

DEFER: me?

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

GENERIC: forward-name ( irc-message -- name )
M: join forward-name trailing>> ;
M: part forward-name channel>> ;
M: kick forward-name channel>> ;
M: mode forward-name name>> ;
M: privmsg forward-name dup name>> me? [ irc-message-sender ] [ name>> ] if ;

UNION: single-forward join part kick mode privmsg ;
UNION: multiple-forward nick quit ;
UNION: broadcast-forward irc-end irc-disconnected irc-connected ;
GENERIC: forward-message ( irc-message -- )

M: irc-message forward-message
    +server-listener+ listener> [ to-listener ] [ drop ] if* ;

M: single-forward forward-message dup forward-name to-listener ;

M: multiple-forward forward-message
    dup irc-message-sender to-listeners-with-participant ;
  
M: broadcast-forward forward-message
    irc> listeners>> values [ to-listener ] with each ;

GENERIC: process-message ( irc-message -- )
M: object      process-message drop ; 
M: logged-in   process-message name>> irc> (>>nick) ;
M: ping        process-message trailing>> /PONG ;
M: nick-in-use process-message name>> "_" append /NICK ;

M: join process-message
    [ drop +normal+ ] [ irc-message-sender ] [ trailing>> ] tri
    dup listener> [ add-participant ] [ 3drop ] if ;

M: part process-message
    [ irc-message-sender ] [ channel>> ] bi remove-participant ;

M: kick process-message
    [ [ who>> ] [ channel>> ] bi remove-participant ]
    [ dup who>> me? [ unregister-listener ] [ drop ] if ]
    bi ;

M: quit process-message
    irc-message-sender remove-participant-from-all ;

M: nick process-message
    [ irc-message-sender ] [ trailing>> ] bi rename-participant-in-all ;

! M: mode process-message ( mode -- )
!    [ channel-mode? ] keep and [
!        [ name>> ] [ mode>> ] [ parameter>> ] tri
!        [ change-participant-mode ] [ 2drop ] if*
!    ] when* ;

: >nick/mode ( string -- nick mode )
    dup first "+@" member? [ unclip ] [ 0 ] if participant-mode ;

: names-reply>participants ( names-reply -- participants )
    trailing>> [ blank? ] trim " " split
    [ >nick/mode 2array ] map >hashtable ;

M: names-reply process-message
    [ names-reply>participants ] [ channel>> listener> ] bi [
        [ (>>participants) ]
        [ [ f f f <participant-changed> ] dip name>> to-listener ] bi
    ] [ drop ] if* ;

! ======================================
! Client message handling
! ======================================

GENERIC: handle-outgoing-irc ( irc-message -- ? )
M: irc-end     handle-outgoing-irc drop f ;
M: irc-message handle-outgoing-irc irc-message>client-line irc-print t ;

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
        [ nick>> /LOGIN ]
    tri ;

! FIXME: do something with the exception, store somewhere to help debugging
: handle-disconnect ( error -- )
    drop irc> is-running>> [ (handle-disconnect) ] when ;

: (reader-loop) ( -- ? )
    irc> stream>> [
        |dispose stream-readln [
            parse-irc-line handle-reader-message t
        ] [
            irc> terminate-irc f
        ] if*
    ] with-destructors ;

: reader-loop ( -- ? )
    [ (reader-loop) ] [ handle-disconnect t ] recover ;

: writer-loop ( -- ? )
    irc> out-messages>> mailbox-get handle-outgoing-irc ;

! ======================================
! Processing loops
! ======================================

: in-multiplexer-loop ( -- ? )
    irc> in-messages>> mailbox-get
    [ forward-message ] [ process-message ] [ irc-end? not ] tri ;

: strings>privmsg ( name string -- privmsg )
    privmsg new [ (>>trailing) ] keep [ (>>name) ] keep ;

: maybe-annotate-with-name ( name obj -- obj )
    { { [ dup string? ] [ strings>privmsg ] }
      { [ dup privmsg instance? ] [ swap >>name ] }
      [ nip ]
    } cond ;

GENERIC: annotate-message ( listener object -- object )
M: object  annotate-message nip ;
M: part    annotate-message swap name>> >>channel ;
M: privmsg annotate-message swap name>> >>name ;
M: string  annotate-message [ name>> ] dip strings>privmsg ;

: spawn-irc ( -- )
    [ reader-loop ] "irc-reader-loop" spawn-server
    [ writer-loop ] "irc-writer-loop" spawn-server
    [ in-multiplexer-loop ] "in-multiplexer-loop" spawn-server
    3drop ;

GENERIC: (add-listener) ( irc-listener -- )

M: irc-listener (add-listener)
    [ irc> >>client ] [ name>> ] bi irc> listeners>> set-at ;

M: irc-server-listener (add-listener)
    irc> >>client +server-listener+ irc> listeners>> set-at ;

GENERIC: (remove-listener) ( irc-listener -- )

M: irc-nick-listener (remove-listener)
    name>> unregister-listener ;

M: irc-channel-listener (remove-listener)
    [ part new annotate-message irc> out-messages>> mailbox-put  ] keep
    name>> unregister-listener ;

M: irc-server-listener (remove-listener)
   drop +server-listener+ unregister-listener ;

: (connect-irc) ( irc-client -- )
    {
        [ profile>> [ server>> ] [ port>> ] bi /CONNECT ]
        [ (>>stream) ]
        [ t swap (>>is-running) ]
        [ in-messages>> [ irc-connected ] dip mailbox-put ]
    } cleave ;

: with-irc-client ( irc-client quot: ( -- ) -- )
    [ \ current-irc-client ] dip with-variable ; inline

PRIVATE>

: connect-irc ( irc-client -- )
    dup [ [ (connect-irc) ] [ nick>> /LOGIN ] bi spawn-irc ] with-irc-client ;

: add-listener ( irc-listener irc-client -- )
    swap '[ _ (add-listener) ] with-irc-client ;

: remove-listener ( irc-listener -- )
    [ client>> ] keep '[ _ (remove-listener) ] with-irc-client ;

: join-irc-channel ( irc-channel-listener -- )
    dup client>> [ [ name>> ] [ password>> ] bi /JOIN ] with-irc-client ;

: write-message ( message irc-listener -- )
    [ swap annotate-message ] [ client>> out-messages>> mailbox-put ] bi ;

: read-message ( irc-listener -- message ) in-messages>> mailbox-get ;
