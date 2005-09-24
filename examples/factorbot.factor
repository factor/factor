! Simple IRC bot written in Factor.

USING: errors generic hashtables http io kernel math namespaces
parser prettyprint sequences strings unparser words ;
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

GENERIC: handle-irc
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
    [ "factorbot-commands" ] search dup
    [ execute ] [ 2drop ] if ;

M: ping handle-irc ( line -- )
    "PING " ?head drop "PONG " swap append irc-print ;

: parse-irc ( line -- )
    ":" ?head [ "!" split1 swap speaker set ] when handle-irc ;

: say ( line nick -- )
    "PRIVMSG " irc-write irc-write " :" irc-write irc-print ;

: respond ( line -- )
    receiver get nickname get = speaker receiver ? get say ;

: word-string ( word -- string )
    [
        "IN: " % dup word-vocabulary %
        " " % dup definer word-name %
        " " % dup word-name %
        "stack-effect" word-prop [ " (" % % ")" % ] when*
    ] make-string ;

: word-url ( word -- url )
    [
        "http://factor.modalwebserver.co.nz/responder/browser/?vocab=" %
        dup word-vocabulary url-encode %
        "&word=" %
        word-name url-encode %
    ] make-string ;

: irc-loop ( -- )
    irc-stream get stream-readln
    [ dup print flush parse-irc irc-loop ] when* ;

: factorbot
    "irc.freenode.net" connect
    "factorbot" login
    "#concatenative" join
    irc-loop ;

IN: factorbot-commands

: see ( text -- )
    dup vocabs [ vocab ?hash ] map-with [ ] subset
    dup empty? [
        drop
        "Sorry, I couldn't find anything for " swap append respond
    ] [
        nip [
            dup word-string " -- " rot word-url append3 respond
        ] each
    ] if ;

: quit ( text -- )
    drop speaker get "slava" = [ disconnect ] when ;
