! Copyright (C) 2007 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators concurrency.mailboxes concurrency.futures io
       io.encodings.8-bit io.sockets kernel namespaces sequences
       sequences.lib splitting threads calendar classes.tuple
       ascii assocs accessors destructors ;
IN: irc.client

! ======================================
! Setup and running objects
! ======================================

SYMBOL: current-irc-client

: irc-port 6667 ; ! Default irc port

! "setup" objects
TUPLE: irc-profile server port nickname password ;
C: <irc-profile> irc-profile

TUPLE: irc-channel-profile name password ;
: <irc-channel-profile> ( -- irc-channel-profile ) irc-channel-profile new ;

! "live" objects
TUPLE: nick name channels log ;
C: <nick> nick

TUPLE: irc-client profile nick stream in-messages out-messages join-messages
       listeners is-running ;
: <irc-client> ( profile -- irc-client )
    f V{ } clone V{ } clone <nick>
    f <mailbox> <mailbox> <mailbox> H{ } clone f irc-client boa ;

TUPLE: irc-listener in-messages out-messages ;
: <irc-listener> ( -- irc-listener )
    <mailbox> <mailbox> irc-listener boa ;

! ======================================
! Message objects
! ======================================

SINGLETON: irc-end ! Message used when the client isn't running anymore

TUPLE: irc-message line prefix command parameters trailing timestamp ;
TUPLE: logged-in < irc-message name ;
TUPLE: ping < irc-message ;
TUPLE: join < irc-message ;
TUPLE: part < irc-message name channel ;
TUPLE: quit < irc-message ;
TUPLE: privmsg < irc-message name ;
TUPLE: kick < irc-message channel who ;
TUPLE: roomlist < irc-message channel names ;
TUPLE: nick-in-use < irc-message asterisk name ;
TUPLE: notice < irc-message type ;
TUPLE: mode < irc-message name channel mode ;
TUPLE: unhandled < irc-message ;

<PRIVATE

! ======================================
! Shortcuts
! ======================================

: irc-client> ( -- irc-client ) current-irc-client get ;
: irc-stream> ( -- stream ) irc-client> stream>> ;
: irc-write ( s -- ) irc-stream> stream-write ;
: irc-print ( s -- ) irc-stream> [ stream-print ] keep stream-flush ;

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
    <inet> latin1 <client> drop ;

: /JOIN ( channel password -- )
    "JOIN " irc-write
    [ " :" swap 3append ] when* irc-print ;

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

USE: prettyprint

GENERIC: handle-incoming-irc ( irc-message -- )

M: irc-message handle-incoming-irc ( irc-message -- )
    . ;

M: logged-in handle-incoming-irc ( logged-in -- )
    name>> irc-client> nick>> (>>name) ;

M: ping handle-incoming-irc ( ping -- )
    trailing>> /PONG ;

M: nick-in-use handle-incoming-irc ( nick-in-use -- )
    name>> "_" append /NICK ;

M: privmsg handle-incoming-irc ( privmsg -- )
    dup name>> irc-client> listeners>> at
    [ in-messages>> mailbox-put ] [ drop ] if* ;

M: join handle-incoming-irc ( join -- )
    irc-client> join-messages>> mailbox-put ;

! ======================================
! Client message handling
! ======================================

GENERIC: handle-outgoing-irc ( obj -- )

M: privmsg handle-outgoing-irc ( privmsg -- )
   [ name>> ] [ trailing>> ] bi /PRIVMSG ;

! ======================================
! Message parsing
! ======================================

: split-at-first ( seq separators -- before after )
    dupd [ member? ] curry find
        [ cut 1 tail ]
        [ swap ]
    if ;

: remove-heading-: ( seq -- seq ) dup ":" head? [ 1 tail ] when ;

: parse-name ( string -- string )
    remove-heading-: "!" split-at-first drop ;

: split-prefix ( string -- string/f string )
    dup ":" head?
        [ remove-heading-: " " split1 ]
        [ f swap ]
    if ;

: split-trailing ( string -- string string/f )
    ":" split1 ;

: string>irc-message ( string -- object )
    dup split-prefix split-trailing
    [ [ blank? ] trim " " split unclip swap ] dip
    now irc-message boa ;

: parse-irc-line ( string -- message )
    string>irc-message
    dup command>> {
        { "PING" [ \ ping ] }
        { "NOTICE" [ \ notice ] }
        { "001" [ \ logged-in ] }
        { "433" [ \ nick-in-use ] }
        { "JOIN" [ \ join ] }
        { "PART" [ \ part ] }
        { "PRIVMSG" [ \ privmsg ] }
        { "QUIT" [ \ quit ] }
        { "MODE" [ \ mode ] }
        { "KICK" [ \ kick ] }
        [ drop \ unhandled ]
    } case
    [ [ tuple-slots ] [ parameters>> ] bi append ] dip prefix >tuple ;

! ======================================
! Reader/Writer
! ======================================

: stream-readln-or-close ( stream -- str/f )
    dup stream-readln [ nip ] [ dispose f ] if* ;

: handle-reader-message ( irc-message -- )
    irc-client> in-messages>> mailbox-put ;

: handle-stream-close ( -- )
    irc-client> f >>is-running in-messages>> irc-end swap mailbox-put ;

: reader-loop ( -- )
    irc-client> stream>> stream-readln-or-close [
        parse-irc-line handle-reader-message
    ] [
        handle-stream-close
    ] if* ;

: writer-loop ( -- )
    irc-client> out-messages>> mailbox-get handle-outgoing-irc ;

! ======================================
! Processing loops
! ======================================

: in-multiplexer-loop ( -- )
    irc-client> in-messages>> mailbox-get handle-incoming-irc ;

! FIXME: Hack, this should be handled better
GENERIC: add-name ( name obj -- obj )
M: object add-name nip ;
M: privmsg add-name swap >>name ;
    
: listener-loop ( name -- ) ! FIXME: take different values from the stack?
    dup irc-client> listeners>> at [
        out-messages>> mailbox-get add-name
        irc-client> out-messages>>
        mailbox-put
    ] [ drop ] if* ;

: spawn-irc-loop ( quot name -- )
    [ [ irc-client> is-running>> ] compose ] dip
    spawn-server drop ;

: spawn-irc ( -- )
    [ reader-loop ] "irc-reader-loop" spawn-irc-loop
    [ writer-loop ] "irc-writer-loop" spawn-irc-loop
    [ in-multiplexer-loop ] "in-multiplexer-loop" spawn-irc-loop ;

! ======================================
! Listener join request handling
! ======================================

: make-registered-listener ( join -- listener )
    <irc-listener> swap trailing>>
    dup [ listener-loop ] curry "listener" spawn-irc-loop
    [ irc-client> listeners>> set-at ] curry keep ;

: make-join-future ( name -- future )
    [ [ swap trailing>> = ] curry ! compare name with channel name
      irc-client> join-messages>> 60 seconds rot mailbox-get-timeout?
      make-registered-listener ]
    curry future ;

PRIVATE>

: (connect-irc) ( irc-client -- )
    [ profile>> [ server>> ] keep port>> /CONNECT ] keep
    swap >>stream
    t >>is-running drop ;

: connect-irc ( irc-client -- )
    dup current-irc-client [
        [ (connect-irc) ] [ profile>> nickname>> /LOGIN ] bi
        spawn-irc
    ] with-variable ;

: listen-to ( irc-client name -- future )
    swap current-irc-client [ [ f /JOIN ] keep make-join-future ] with-variable ;

! shorcut for privmsgs, etc
: sender>> ( obj -- string )
    prefix>> parse-name ;
