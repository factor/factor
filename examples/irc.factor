! A simple IRC client written in Factor.

IN: irc
USING: kernel lists math namespaces io strings threads words ;

SYMBOL: irc-stream
SYMBOL: channels
SYMBOL: channel
SYMBOL: nickname

: irc-write ( s -- ) irc-stream get stream-write ;
: irc-print ( s -- )
    irc-stream get stream-print
    irc-stream get stream-flush ;

: nick ( nick -- )
    dup nickname set  "NICK " irc-write irc-print ;

: login ( nick -- )
    dup nick
    "USER " irc-write irc-write
    " hostname servername :irc.factor" irc-print ;

: connect ( server -- ) 6667 <client> irc-stream set ;

: write-highlighted ( line -- )
    dup nickname get index-of -1 =
    f [ [[ "ansi-fg" "3" ]] ] ? write-attr ;

: extract-nick ( line -- nick )
    "!" split1 drop ;

: write-nick ( line -- )
    "!" split1 drop [ [[ "bold" t ]] ] write-attr ;

GENERIC: irc-display
PREDICATE: string privmsg "PRIVMSG" index-of -1 > ;
PREDICATE: string action  "ACTION" index-of -1 > ;

M: string irc-display ( line -- )
    print ;

M: privmsg irc-display ( line -- )
    "PRIVMSG" split1 >r write-nick r>
    write-highlighted terpri flush ;

! Doesn't look good
! M: action irc-display ( line -- )
!     " * " write
!     "ACTION" split1 >r write-nick r>
!     write-highlighted terpri flush ;

: in-loop ( -- )
    irc-stream get stream-readln [ irc-display in-loop ] when* ;

: input-thread ( -- ) [ in-loop ] in-thread ;
: disconnect ( -- ) irc-stream get stream-close ;

: command ( line -- )
    #! IRC /commands are just words.
    " " split1 swap [
        "irc" "listener" "parser" "scratchpad"
    ] search execute ;

: (msg) ( line nick -- )
    "PRIVMSG " irc-write irc-write " :" irc-write irc-print ;

: say ( line -- )
    channel get [ (msg) ] [ "No channel." print ] ifte* ;

: talk ( input -- ) "/" ?string-head [ command ] [ say ] ifte ;
: talk-loop ( -- ) read-line [ talk talk-loop ] when* ;

: irc ( nick server -- )
    [
        channels off
        channel off
        connect
        login
        input-thread
        talk-loop
        disconnect
    ] with-scope ;

! /commands
: join ( chan -- )
    dup channels [ cons ] change
    dup channel set
    "JOIN " irc-write irc-print ;

: leave ( chan -- )
    dup channels [ remove ] change
    channels get dup [ car ] when channel set
    "PART " irc-write irc-print ;

: msg ( line -- ) " " split1 swap (msg) ;
: me ( line -- ) "\u0001ACTION " swap "\u0001" cat3 say ;
: quit ( line -- ) drop disconnect ;
