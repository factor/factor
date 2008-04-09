! Copyright (C) 2007 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays calendar combinators channels concurrency.messaging fry io
       io.encodings.8-bit io.sockets kernel math namespaces sequences
       sequences.lib singleton splitting strings threads
       continuations classes.tuple ascii accessors ;
IN: irc

! utils
: split-at-first ( seq separators -- before after )
    dupd '[ , member? ] find
        [ cut 1 tail ]
        [ swap ]
    if ;

: spawn-server-linked ( quot name -- thread )
    >r '[ , [ ] [ ] while ] r>
    spawn-linked ;
! ---

! Default irc port
: irc-port 6667 ;

! Message used when the client isn't running anymore
SINGLETON: irc-end

! "setup" objects
TUPLE: irc-profile server port nickname password default-channels  ;
C: <irc-profile> irc-profile

TUPLE: irc-channel-profile name password auto-rejoin ;
C: <irc-channel-profile> irc-channel-profile

! "live" objects
TUPLE: nick name channels log ;
C: <nick> nick

TUPLE: irc-client profile nick stream stream-channel controller-channel
       listeners is-running ;
: <irc-client> ( profile -- irc-client )
    f V{ } clone V{ } clone <nick>
    f <channel> <channel> V{ } clone f irc-client construct-boa ;

USE: prettyprint
TUPLE: irc-listener channel ;
! FIXME: spawn-server-linked con manejo de excepciones, mandar un mensaje final (ya se maneja esto al recibir mensajes del channel? )
! tener la opción de dejar de correr un client??
: <irc-listener> ( quot -- irc-listener )
    <channel> irc-listener construct-boa swap
    [
        [ channel>> '[ , from ] ]
        [ '[ , curry f spawn drop ] ]
        bi* compose "irc-listener" spawn-server-linked drop
    ] [ drop ] 2bi ;

! TUPLE: irc-channel name topic members log attributes ;
! C: <irc-channel> irc-channel

! the delegate of all irc messages
TUPLE: irc-message line prefix command parameters trailing timestamp ;
C: <irc-message> irc-message

! "irc message" objects
TUPLE: logged-in < irc-message name ;
C: <logged-in> logged-in

TUPLE: ping < irc-message ;
C: <ping> ping

TUPLE: join_ < irc-message ;
C: <join> join_

TUPLE: part < irc-message name channel ;
C: <part> part

TUPLE: quit ;
C: <quit> quit

TUPLE: privmsg < irc-message name ;
C: <privmsg> privmsg

TUPLE: kick < irc-message channel who ;
C: <kick> kick

TUPLE: roomlist < irc-message channel names ;
C: <roomlist> roomlist

TUPLE: nick-in-use < irc-message name ;
C: <nick-in-use> nick-in-use

TUPLE: notice < irc-message type ;
C: <notice> notice

TUPLE: mode < irc-message name channel mode ;
C: <mode> mode

TUPLE: unhandled < irc-message ;
C: <unhandled> unhandled

SYMBOL: irc-client
: irc-client> ( -- irc-client ) irc-client get ;
: irc-stream> ( -- stream ) irc-client> stream>> ;

: remove-heading-: ( seq -- seq ) dup ":" head? [ 1 tail ] when ;

: parse-name ( string -- string )
    remove-heading-: "!" split-at-first drop ;

: sender>> ( obj -- string )
    prefix>> parse-name ;

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
    now <irc-message> ;

: me? ( name -- ? )
    irc-client> nick>> name>> = ;

: irc-write ( s -- )
    irc-stream> stream-write ;

: irc-print ( s -- )
    irc-stream> [ stream-print ] keep stream-flush ;

! Irc commands    

: NICK ( nick -- )
    "NICK " irc-write irc-print ;

: LOGIN ( nick -- )
    dup NICK
    "USER " irc-write irc-write
    " hostname servername :irc.factor" irc-print ;

: CONNECT ( server port -- stream )
    <inet> latin1 <client> ;

: JOIN ( channel password -- )
    "JOIN " irc-write
    [ " :" swap 3append ] when* irc-print ;

: PART ( channel text -- )
    [ "PART " irc-write irc-write ] dip
    " :" irc-write irc-print ;

: KICK ( channel who -- )
    [ "KICK " irc-write irc-write ] dip
    " " irc-write irc-print ;
    
: PRIVMSG ( nick line -- )
    [ "PRIVMSG " irc-write irc-write ] dip
    " :" irc-write irc-print ;

: SAY ( nick line -- )
    PRIVMSG ;

: ACTION ( nick line -- )
    [ 1 , "ACTION " % % 1 , ] "" make PRIVMSG ;

: QUIT ( text -- )
    "QUIT :" irc-write irc-print ;

: join-channel ( channel-profile -- )
    [ name>> ] keep password>> JOIN ;

: irc-connect ( irc-client -- )
    [ profile>> [ server>> ] keep port>> CONNECT ] keep
    swap >>stream t >>is-running drop ;
    
GENERIC: handle-irc ( obj -- )

M: object handle-irc ( obj -- )
    drop ;

M: logged-in handle-irc ( obj -- )
    name>>
    irc-client> [ nick>> swap >>name drop ] keep 
    profile>> default-channels>> [ join-channel ] each ;

M: ping handle-irc ( obj -- )
    "PONG " irc-write
    trailing>> irc-print ;

M: nick-in-use handle-irc ( obj -- )
    name>> "_" append NICK ;

: parse-irc-line ( string -- message )
    string>irc-message
    dup command>> {
        { "PING" [ \ ping ] }
        { "NOTICE" [ \ notice ] }
        { "001" [ \ logged-in ] }
        { "433" [ \ nick-in-use ] }
        { "JOIN" [ \ join_ ] }
        { "PART" [ \ part ] }
        { "PRIVMSG" [ \ privmsg ] }
        { "QUIT" [ \ quit ] }
        { "MODE" [ \ mode ] }
        { "KICK" [ \ kick ] }
        [ drop \ unhandled ]
    } case
    [ [ tuple-slots ] [ parameters>> ] bi append ] dip add* >tuple ;

! Reader
: handle-reader-message ( irc-client irc-message -- )
    dup handle-irc swap stream-channel>> to ;

: reader-loop ( irc-client -- )
    dup stream>> stream-readln [
        dup print parse-irc-line handle-reader-message
    ] [
        f >>is-running
        dup stream>> dispose
        irc-end over controller-channel>> to
        stream-channel>> irc-end swap to
    ] if* ;

! Controller commands
GENERIC: handle-command ( obj -- )

M: object handle-command ( obj -- )
    . ;

TUPLE: send-message to text ;
C: <send-message> send-message
M: send-message handle-command ( obj -- )
    dup to>> swap text>> SAY ;

TUPLE: send-action to text ;
C: <send-action> send-action
M: send-action handle-command ( obj -- )
    dup to>> swap text>> ACTION ;

TUPLE: send-quit text ;
C: <send-quit> send-quit
M: send-quit handle-command ( obj -- )
    text>> QUIT ;

: irc-listen ( irc-client quot -- )
    [ listeners>> ] [ <irc-listener> ] bi* swap push ;

! Controller loop
: controller-loop ( irc-client -- )
    controller-channel>> from handle-command ;

! Multiplexer
: multiplex-message ( irc-client message -- )
    swap listeners>> [ channel>> ] map
    [ '[ , , to ] "message" spawn drop ] each-with ;

: multiplexer-loop ( irc-client -- )
    dup stream-channel>> from multiplex-message ;

! process looping and starting
: (spawn-irc-loop) ( irc-client quot name -- )
    [ over >r curry r> '[ @ , is-running>> ] ] dip
    spawn-server-linked drop ;

: spawn-irc-loop ( irc-client quot name -- )
    '[ , , , [ (spawn-irc-loop) receive ] [ print ] recover ]
    f spawn drop ;

: spawn-irc ( irc-client -- )
    [ [ reader-loop ] "reader-loop" spawn-irc-loop ]
    [ [ controller-loop ] "controller-loop" spawn-irc-loop ]
    [ [ multiplexer-loop ] "multiplexer-loop" spawn-irc-loop ]
    tri ;
    
: do-irc ( irc-client -- )
    irc-client [
        irc-client>
        [ irc-connect ]
        [ profile>> nickname>> LOGIN ]
        [ spawn-irc ]
        tri
    ] with-variable ;