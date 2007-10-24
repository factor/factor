! Copyright (C) 2007 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays calendar io io.sockets kernel match namespaces
sequences splitting strings continuations threads ;
IN: irc

! "setup" objects
TUPLE: profile server port nickname password default-channels ;
C: <profile> profile

TUPLE: channel-profile name password auto-rejoin ;
C: <channel-profile> channel-profile

! "live" objects
TUPLE: irc-client profile nick stream stream-process controller-process ;
C: <irc-client> irc-client

TUPLE: nick name channels log ;
C: <nick> nick

TUPLE: channel name topic members log attributes ;
C: <channel> channel

! the delegate of all irc messages
TUPLE: irc-message timestamp ;
C: <irc-message> irc-message

! "irc message" objects
TUPLE: logged-in name text ;
C: <logged-in> logged-in

TUPLE: ping name ;
C: <ping> ping

TUPLE: join name channel ;
C: <join> join

TUPLE: part name channel text ;
C: <part> part

TUPLE: quit text ;
C: <quit> quit

TUPLE: privmsg name text ;
C: <privmsg> privmsg

TUPLE: kick channel er ee text ;
C: <kick> kick

TUPLE: roomlist channel names ;
C: <roomlist> roomlist

TUPLE: nick-in-use name ;
C: <nick-in-use> nick-in-use

TUPLE: notice type text ;
C: <notice> notice

TUPLE: mode name channel mode text ;
C: <mode> mode
! TUPLE: members

TUPLE: unhandled text ;
C: <unhandled> unhandled

! "control message" objects
TUPLE: command sender ;
TUPLE: service predicate quot enabled? ;
TUPLE: chat-command from to text ;
TUPLE: join-command channel password ;
TUPLE: part-command channel text ;

SYMBOL: irc-client
: irc-stream> ( -- stream ) irc-client get irc-client-stream ;
: trim-: ( seq -- seq ) [ CHAR: : = ] left-trim ;
: parse-name ( string -- string )
    trim-: "!" split first ;
: irc-split ( string -- seq )
    1 swap [ [ CHAR: : = ] find* ] keep
    swap [ swap cut trim-: ] [ nip f ] if >r [ blank? ] trim trim-:
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
    [ irc-loop ] [ irc-stream> stream-close ] [ ] cleanup ;

: with-infinite-loop ( quot timeout -- quot timeout )
    "looping" print flush
    over catch drop dup sleep with-infinite-loop ;

: start-irc ( irc-client -- )
    ! [ [ do-irc ] curry 3000 with-infinite-loop ] with-scope ;
    [ do-irc ] curry 3000 with-infinite-loop ;


! For testing
: make-factorbot
    "irc.freenode.org" 6667 "factorbot" f
    [
        "#concatenative-flood" f f <channel-profile> ,
    ] { } make <profile>
    f V{ } clone V{ } clone <nick>
    f f f <irc-client> ;

: test-factorbot
    make-factorbot start-irc ;

