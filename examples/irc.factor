! A simple IRC client written in Factor.

USE: stack
USE: stdio
USE: namespaces
USE: streams
USE: combinators
USE: threads

SYMBOL: irc-stream
SYMBOL: channel

: irc-write ( str -- )
    irc-stream get fwrite ;

: irc-print ( str -- )
    irc-stream get fprint  irc-stream get fflush ;

: join ( chan -- )
    dup channel set  "JOIN " irc-write irc-print ;

: login ( nick -- )
    "NICK " irc-write dup irc-print
    "USER " irc-write irc-write
    " hostname servername :irc.factor" irc-print ;

: connect ( channel nick server -- )
    6667 <client> irc-stream set  login join ;

: in-loop ( -- )
    irc-stream get freadln [ print in-loop ] when* ;

: say ( input -- )
    "PRIVMSG " irc-write
    channel get irc-write
    " :" irc-write irc-print ;

: say-loop ( -- )
    read [ say say-loop ] when* ;

: disconnect ( -- )
    irc-stream get fclose ;

: input-thread ( -- )
    [ in-loop ] in-thread ;

: irc ( channel nick server -- )
    [ connect  input-thread  say-loop  disconnect ] with-scope ;

"#concatenative" "conc" "irc.freenode.net" irc
