! Copyright (C) 2008 Bruno Deferrari, Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.mailboxes kernel io.sockets io.encodings.8-bit calendar
       accessors destructors namespaces io assocs arrays fry
       continuations threads strings classes combinators splitting hashtables
       ascii irc.messages irc.messages.base irc.messages.parser call ;
RENAME: join sequences => sjoin
EXCLUDE: sequences => join ;
IN: irc.client

! ======================================
! Setup and running objects
! ======================================

CONSTANT: irc-port 6667 ! Default irc port

TUPLE: irc-profile server port nickname password ;
C: <irc-profile> irc-profile

TUPLE: irc-client profile stream in-messages out-messages
       chats is-running nick connect reconnect-time is-ready ;

: <irc-client> ( profile -- irc-client )
    irc-client new
        swap >>profile
        <mailbox> >>in-messages
        <mailbox> >>out-messages
        H{ } clone >>chats
        dup profile>> nickname>> >>nick
        [ <inet> latin1 <client> ] >>connect
        15 seconds >>reconnect-time ;

TUPLE: irc-chat in-messages client ;
TUPLE: irc-server-chat < irc-chat ;
TUPLE: irc-channel-chat < irc-chat name password timeout participants clean-participants ;
TUPLE: irc-nick-chat < irc-chat name ;
SYMBOL: +server-chat+

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

! chat objects
: <irc-server-chat> ( -- irc-server-chat )
     <mailbox> f irc-server-chat boa ;

: <irc-channel-chat> ( name -- irc-channel-chat )
     [ <mailbox> f ] dip f 60 seconds H{ } clone t
     irc-channel-chat boa ;

: <irc-nick-chat> ( name -- irc-nick-chat )
     [ <mailbox> f ] dip irc-nick-chat boa ;

! ======================================
! Message objects
! ======================================

TUPLE: participant-changed nick action parameter ;
C: <participant-changed> participant-changed

SINGLETON: irc-chat-end     ! sent to a chat to stop its execution
SINGLETON: irc-end          ! sent when the client isn't running anymore
SINGLETON: irc-disconnected ! sent when connection is lost
SINGLETON: irc-connected    ! sent when connection is established

: terminate-irc ( irc-client -- )
    dup is-running>> [
        f >>is-running
        [ stream>> dispose ] keep
        [ in-messages>> ] [ out-messages>> ] bi 2array
        [ irc-end swap mailbox-put ] each
    ] [ drop ] if ;

<PRIVATE

SYMBOL: current-irc-client

! ======================================
! Utils
! ======================================

: irc> ( -- irc-client ) current-irc-client get ;
: irc-write ( s -- ) irc> stream>> stream-write ;
: irc-print ( s -- ) irc> stream>> [ stream-print ] keep stream-flush ;
: irc-send ( irc-message -- ) irc> out-messages>> mailbox-put ;
: chat> ( name -- chat/f ) irc> chats>> at ;
: channel-mode? ( mode -- ? ) name>> first "#&" member? ;
: me? ( string -- ? ) irc> nick>> = ;

GENERIC: to-chat ( message obj -- )

M: string to-chat
    chat> [ +server-chat+ chat> ] unless*
    [ to-chat ] [ drop ] if* ;

M: irc-chat to-chat in-messages>> mailbox-put ;

: unregister-chat ( name -- )
    irc> chats>>
        [ at [ irc-chat-end ] dip to-chat ]
        [ delete-at ]
    2bi ;

: (remove-participant) ( nick chat -- )
    [ participants>> delete-at ]
    [ [ +part+ f <participant-changed> ] dip to-chat ] 2bi ;

: remove-participant ( nick channel -- )
    chat> [ (remove-participant) ] [ drop ] if* ;

: chats-with-participant ( nick -- seq )
    irc> chats>> values
    [ dup irc-channel-chat? [ participants>> key? ] [ 2drop f ] if ]
    with filter ;

: to-chats-with-participant ( message nickname -- )
    chats-with-participant [ to-chat ] with each ;

: remove-participant-from-all ( nick -- )
    dup chats-with-participant [ (remove-participant) ] with each ;

: notify-rename ( newnick oldnick chat -- )
    [ participant-changed new +nick+ >>action
      [ (>>nick) ] [ (>>parameter) ] [ ] tri ] dip to-chat ;

: rename-participant ( newnick oldnick chat -- )
    [ participants>> [ delete-at* drop ] [ swapd set-at ] bi ]
    [ notify-rename ] 3bi ;

: rename-participant-in-all ( oldnick newnick -- )
    swap dup chats-with-participant [ rename-participant ] with with each ;

: add-participant ( mode nick channel -- )
    chat>
    [ participants>> set-at ]
    [ [ +join+ f <participant-changed> ] dip to-chat ] 2bi ;

: change-participant-mode ( channel mode nick -- )
    rot chat>
    [ participants>> set-at ]
    [ [ participant-changed new
        [ (>>nick) ] [ (>>parameter) ] [ +mode+ >>action ] tri ] dip to-chat ]
    3bi ; ! FIXME

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
    irc> connect>> call( host port -- stream local ) drop ;

: /JOIN ( channel password -- )
    "JOIN " irc-write [ " :" swap 3append ] when* irc-print ;

: /PONG ( text -- )
    "PONG " irc-write irc-print ;

! ======================================
! Server message handling
! ======================================

GENERIC: initialize-chat ( chat -- )
M: irc-chat initialize-chat drop ;
M: irc-channel-chat initialize-chat [ name>> ] [ password>> ] bi /JOIN ;

GENERIC: forward-name ( irc-message -- name )
M: join forward-name trailing>> ;
M: part forward-name channel>> ;
M: kick forward-name channel>> ;
M: mode forward-name name>> ;
M: privmsg forward-name dup target>> me? [ sender>> ] [ target>> ] if ;

UNION: single-forward join part kick mode privmsg ;
UNION: multiple-forward nick quit ;
UNION: broadcast-forward irc-end irc-disconnected irc-connected ;
GENERIC: forward-message ( irc-message -- )

M: irc-message forward-message
    +server-chat+ chat> [ to-chat ] [ drop ] if* ;

M: single-forward forward-message dup forward-name to-chat ;

M: multiple-forward forward-message
    dup sender>> to-chats-with-participant ;
  
M: broadcast-forward forward-message
    irc> chats>> values [ to-chat ] with each ;

GENERIC: process-message ( irc-message -- )
M: object      process-message drop ; 
M: rpl-welcome process-message
    nickname>> t irc> [ (>>is-ready) ] [ (>>nick) ] [ chats>> ] tri
    values [ initialize-chat ] each ;
M: ping        process-message trailing>> /PONG ;
M: rpl-nickname-in-use process-message name>> "_" append /NICK ;

M: join process-message
    [ drop +normal+ ] [ sender>> ] [ trailing>> ] tri
    dup chat> [ add-participant ] [ 3drop ] if ;

M: part process-message
    [ sender>> ] [ channel>> ] bi remove-participant ;

M: kick process-message
    [ [ user>> ] [ channel>> ] bi remove-participant ]
    [ dup user>> me? [ unregister-chat ] [ drop ] if ]
    bi ;

M: quit process-message
    sender>> remove-participant-from-all ;

M: nick process-message
    [ sender>> ] [ trailing>> ] bi rename-participant-in-all ;

M: mode process-message ( mode -- )
    dup channel-mode? [
        [ name>> ] [ mode>> ] [ parameter>> ] tri
        [ change-participant-mode ] [ 2drop ] if*
    ] [ drop ] if ;

: >nick/mode ( string -- nick mode )
    dup first "+@" member? [ unclip ] [ 0 ] if participant-mode ;

: names-reply>participants ( names-reply -- participants )
    nicks>> [ blank? ] trim " " split
    [ >nick/mode 2array ] map >hashtable ;

: maybe-clean-participants ( channel-chat -- )
    dup clean-participants>> [
        H{ } clone >>participants f >>clean-participants
    ] when drop ;

M: rpl-names process-message
    [ names-reply>participants ] [ channel>> chat> ] bi [
        [ maybe-clean-participants ] 
        [ participants>> 2array assoc-combine ]
        [ (>>participants) ] tri
    ] [ drop ] if* ;

M: rpl-names-end process-message
    channel>> chat> [
        t >>clean-participants
        [ f f f <participant-changed> ] dip name>> to-chat
    ] when* ;

! ======================================
! Client message handling
! ======================================

GENERIC: handle-outgoing-irc ( irc-message -- ? )
M: irc-end     handle-outgoing-irc drop f ;
M: irc-message handle-outgoing-irc irc-message>string irc-print t ;

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
: handle-disconnect ( error -- ? )
    drop irc> is-running>> [ (handle-disconnect) t ] [ f ] if ;

: (reader-loop) ( -- ? )
    irc> stream>> [
        |dispose stream-readln [
            string>irc-message handle-reader-message t
        ] [
            f handle-disconnect
        ] if*
    ] with-destructors ;

: reader-loop ( -- ? )
    [ (reader-loop) ] [ handle-disconnect ] recover ;

: writer-loop ( -- ? )
    irc> out-messages>> mailbox-get handle-outgoing-irc ;

! ======================================
! Processing loops
! ======================================

: in-multiplexer-loop ( -- ? )
    irc> in-messages>> mailbox-get
    [ forward-message ] [ process-message ] [ irc-end? not ] tri ;

: strings>privmsg ( name string -- privmsg )
    " :" prepend append "PRIVMSG " prepend string>irc-message ;

: maybe-annotate-with-name ( name obj -- obj )
    { { [ dup string? ] [ strings>privmsg ] }
      { [ dup privmsg instance? ] [ swap >>name ] }
      [ nip ]
    } cond ;

GENERIC: annotate-message ( chat object -- object )
M: object  annotate-message nip ;
M: part    annotate-message swap name>> >>channel ;
M: privmsg annotate-message swap name>> >>target ;
M: string  annotate-message [ name>> ] dip strings>privmsg ;

: spawn-irc ( -- )
    [ reader-loop ] "irc-reader-loop" spawn-server
    [ writer-loop ] "irc-writer-loop" spawn-server
    [ in-multiplexer-loop ] "in-multiplexer-loop" spawn-server
    3drop ;

GENERIC: (attach-chat) ( irc-chat -- )

M: irc-chat (attach-chat)
    [ [ irc> >>client ] [ name>> ] bi irc> chats>> set-at ]
    [ [ irc> is-ready>> ] dip and [ initialize-chat ] when* ]
    bi ;

M: irc-server-chat (attach-chat)
    irc> >>client +server-chat+ irc> chats>> set-at ;

GENERIC: (remove-chat) ( irc-chat -- )

M: irc-nick-chat (remove-chat)
    name>> unregister-chat ;

M: irc-channel-chat (remove-chat)
    [ part new annotate-message irc> out-messages>> mailbox-put  ] keep
    name>> unregister-chat ;

M: irc-server-chat (remove-chat)
   drop +server-chat+ unregister-chat ;

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

: attach-chat ( irc-chat irc-client -- ) [ (attach-chat) ] with-irc-client ;

: detach-chat ( irc-chat -- )
    [ client>> ] keep '[ _ (remove-chat) ] with-irc-client ;

: speak ( message irc-chat -- )
    [ swap annotate-message ] [ client>> out-messages>> mailbox-put ] bi ;

: hear ( irc-chat -- message ) in-messages>> mailbox-get ;
