! Simple IRC bot written in Factor.

REQUIRES: libs/httpd ;

USING: errors generic hashtables help html http io kernel math
memory namespaces parser prettyprint sequences strings threads
words ;
IN: factorbot

SYMBOL: irc-stream
SYMBOL: nickname
SYMBOL: speaker
SYMBOL: receiver

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

: disconnect ( -- ) irc-stream get stream-close ;

: join ( chan -- )
    "JOIN " irc-write irc-print ;

GENERIC: handle-irc ( line -- )
PREDICATE: string privmsg " " split1 nip "PRIVMSG" head? ;
PREDICATE: string ping "PING" head? ;

M: object handle-irc ( line -- )
    drop ;

: parse-privmsg ( line -- text )
    " " split1 nip
    "PRIVMSG " ?head drop
    " " split1 swap receiver set
    ":" ?head drop ;

M: privmsg handle-irc ( line -- )
    parse-privmsg
    " " split1 swap
    "factorbot-commands" lookup dup
    [ execute ] [ 2drop ] if ;

M: ping handle-irc ( line -- )
    "PING " ?head drop "PONG " swap append irc-print ;

: parse-irc ( line -- )
    ":" ?head [ "!" split1 swap speaker set ] when handle-irc ;

: say ( line nick -- )
    "PRIVMSG " irc-write irc-write " :" irc-write irc-print ;

: respond ( line -- )
    receiver get nickname get = speaker receiver ? get say ;

: irc-loop ( -- )
    irc-stream get stream-readln
    [ dup print flush parse-irc irc-loop ] when* ;

: factorbot
    "irc.freenode.net" connect
    "factorbot" login
    "#concatenative" join
    [ irc-loop ] [ irc-stream get stream-close ] cleanup ;

: factorbot-loop [ factorbot ] try 30000 sleep factorbot-loop ;

: multiline-respond ( string -- )
    string-lines [ respond ] each ;

: object-href
    "http://factorcode.org" swap browser-link-href append ;

: not-found ( str -- )
    "Sorry, I couldn't find anything for " swap append respond ;

IN: factorbot-commands

: see ( text -- )
    dup words-named dup empty? [
        drop
        not-found
    ] [
        nip [
            dup summary " -- " 
            rot object-href 3append respond
        ] each
    ] if ;

: memory ( text -- )
    drop [ room. ] string-out multiline-respond ;

: quit ( text -- )
    drop speaker get "slava" = [ disconnect ] when ;

PROVIDE: apps/factorbot ;

MAIN: apps/factorbot factorbot ;
