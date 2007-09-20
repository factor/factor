USING: arrays calendar concurrency errors generic hashtables
help html http io kernel match math memory namespaces
parser prettyprint quotations sequences sequences-contrib
splay-trees strings threads words network ;
IN: irc

! "setup" objects
TUPLE: profile server port nickname password default-channels ;
TUPLE: channel-profile name password auto-rejoin ;

! "live" objects
TUPLE: irc-client profile nick stream stream-process controller-process ;
TUPLE: nick name channels log ;
TUPLE: channel name topic members log attributes ;

! "irc message" objects
  ! the delegate of all irc messages
TUPLE: irc-message timestamp ;
TUPLE: logged-in name text ;
TUPLE: ping name ;
TUPLE: join name channel ;
TUPLE: part name channel text ;
TUPLE: quit text ;

TUPLE: privmsg name text ;
TUPLE: kick channel er ee text ;
TUPLE: roomlist channel names ;
TUPLE: nick-in-use name ;
TUPLE: notice type text ;
TUPLE: mode name channel mode text ;
! TUPLE: members

TUPLE: unhandled text ;

! "control message" objects
TUPLE: command sender ;
TUPLE: service predicate quot enabled? ;
TUPLE: chat-command from to text ;
TUPLE: join-command channel password ;
TUPLE: part-command channel text ;

SYMBOL: irc-client
: irc-stream> ( -- stream ) irc-client get irc-client-stream ;
: trim-: ( seq -- seq ) [ CHAR: : = ] ltrim* ;
: parse-name ( string -- string )
    trim-: "!" split first ;
: irc-split ( string -- seq )
    1 swap [ [ CHAR: : = ] find* ] keep
    swap [ cut trim-: ] [ nip f ] if >r trim trim-:
    " " split r> [ 1array append ] when* ;
: me? ( name -- ? )
    irc-client get irc-client-nick nick-name = ;

: irc-write ( s -- )
    irc-stream> stream-write ;

: irc-print ( s -- )
    irc-stream> [ stream-print ] keep stream-flush ;

: nick ( nick -- )
    "NICK " irc-write irc-print ;

: login ( nick -- )
    dup nick
    "USER " irc-write irc-write
    " hostname servername :irc.factor" irc-print ;

: connect* ( server port -- )
    <inet> <client> irc-client get set-irc-client-stream ;

: connect ( server -- ) 6667 connect* ;

: join ( channel password -- )
    "JOIN " irc-write
    [ >r " :" r> 3append ] when* irc-print ;

: part ( channel text -- )
    >r "PART " irc-write irc-write r>
    " :" irc-write irc-print ;

: say ( line nick -- )
    "PRIVMSG " irc-write irc-write " :" irc-write irc-print ;

: quit ( text -- )
    "QUIT :" irc-write irc-print ;


GENERIC: handle-irc ( obj -- )

M: object handle-irc ( obj -- )
    "Unhandled irc object" print drop ;

M: logged-in handle-irc ( obj -- )
    logged-in-name irc-client get [ irc-client-nick set-nick-name ] keep
    
    irc-client-profile profile-default-channels
    [
        [ channel-profile-name ] keep
        channel-profile-password join
    ] each ;

M: ping handle-irc ( obj -- )
    "PONG " irc-write
    ping-name irc-print ;

M: nick-in-use handle-irc ( obj -- )
    nick-in-use-name "_" append nick ;

: delegate-timestamp ( obj -- obj )
    now <irc-message> over set-delegate ;

MATCH-VARS: ?name ?name2 ?channel ?text ?mode ;
SYMBOL: line
: match-irc ( string -- )
    dup line set
    dup print flush
    irc-split
    {
        { { "PING" ?name }
          [ ?name <ping> ] }
        { { ?name "001" ?name2 ?text }
          [ ?name2 ?text <logged-in> ] }
        { { ?name "433" _ ?name2 "Nickname is already in use." }
          [ ?name2 <nick-in-use> ] }

        { { ?name "JOIN" ?channel }
          [ ?name ?channel <join> ] }
        { { ?name "PART" ?channel ?text }
          [ ?name ?channel ?text <part> ] }
        { { ?name "PRIVMSG" ?channel ?text }
          [ ?name ?channel ?text <privmsg> ] }
        { { ?name "QUIT" ?text }
          [ ?name ?text <quit> ] }

        { { "NOTICE" ?name ?text }
          [ ?name ?text <notice> ] }
        { { ?name "MODE" ?channel ?mode ?text }
          [ ?name ?channel ?mode ?text <mode> ] }
        { { ?name "KICK" ?channel ?name2 ?text }
          [  ?channel ?name ?name2 ?text <kick> ] }

        ! { { ?name "353" ?name2 _ ?channel ?text }
         ! [ ?text ?channel ?name2 make-member-list ] }
        { _ [ line get <unhandled> ] }
    } match-cond
    delegate-timestamp handle-irc flush ;

: irc-loop ( -- )
    irc-stream> stream-readln
    [ match-irc irc-loop ] when* ;

: do-irc ( irc-client -- )
    dup irc-client set
    dup irc-client-profile profile-server
    over irc-client-profile profile-port connect*
    dup irc-client-profile profile-nickname login
    [ irc-loop ] [ irc-stream> stream-close ] cleanup ;

: with-infinite-loop ( quot timeout -- quot timeout )
    "looping" print flush
    over catch drop dup sleep with-infinite-loop ;

: start-irc ( irc-client -- )
    ! [ [ do-irc ] curry 3000 with-infinite-loop ] with-scope ;
    [ do-irc ] curry 3000 with-infinite-loop ;


GENERIC: handle-command ( obj -- )
: prepare-message ( from text -- string )
    >r dup [ >r "from " r> ": " 3append ] when r>
    append >string ;

M: chat-command handle-command ( obj -- )
    [ chat-command-from ] keep
    [ chat-command-text prepare-message ] keep
    chat-command-to say ;

M: join-command handle-command ( obj -- )
    [ join-command-channel ] keep
    join-command-password join ;

M: part-command handle-command ( obj -- )
    [ part-command-channel ] keep part-command-text part ;

M: service handle-command ( service -- )    
    drop ;

: command-handler ( -- )
    receive [ handle-command ] catch [
        "error caught: " . flush
    ] when* command-handler ;

: send-command ( obj irc-client -- )
    >r self <command> over set-delegate r>
    irc-client-controller-process send ;

: subscribe-logger ( irc-client -- )
    >r "#concatenative-flood" "log" <service> r>
    send-command ;

! : start-private ( irc-client -- )
    ! dup irc-client set [ start-irc ] spawn ;

: maybe-start-node ( port -- )
    \ localnode get [
        drop
    ] [
        >r "localhost" r> start-node
    ] if ;

: start-public ( irc-client id -- )
    [
        >r
            dup irc-client set
            4030 maybe-start-node
            [ command-handler ] spawn
        r> over register-process
        swap [ set-irc-client-controller-process ] keep
        [ [ start-irc ] spawn ] keep set-irc-client-stream-process
    ] with-scope ;

! "trifocus.net" 4030 <node> "public-irc" <remote-process> "guest" "#concatenative" "hi" <chat-command> over send

: make-test-client
    "irc.freenode.org"
        6667
        "factorbot2"
        f
        [
            "#concatenative-flood" f f <channel-profile> ,
            ! "#concatenative-test1" f f <channel-profile> ,
            ! "#concatenative-test2" f f <channel-profile> ,
            ! "#concatenative" f f <channel-profile> ,
        ] { } make <profile>
    f V{ } clone V{ } clone <nick>
    f
    f
    f
    <irc-client> ;

: test3 make-test-client "test3" start-public ;
: test4 make-test-client "test4" start-public ;
: test5 make-test-client "test5" start-public ;
: test6 make-test-client "test6" start-public ;

: 3test { test3 test4 test5 } [ execute ] each ;

: make-furnacebot
    "irc.freenode.org"
        6667
        "furnacebot"
        f
        [
            "#concatenative" f f <channel-profile> ,
        ] { } make <profile>
    f V{ } clone V{ } clone <nick>
    f
    f
    f
    <irc-client> ;

: furnacebot
    make-furnacebot "public-irc" start-public ;

