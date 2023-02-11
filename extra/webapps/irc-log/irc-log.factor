! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar kernel http.server.dispatchers prettyprint
sequences formatting furnace.actions html.forms accessors
furnace.redirection ;
IN: webapps.irc-log

TUPLE: irclog-app < dispatcher ;

: irc-link ( channel -- string )
    now -7 hours convert-timezone >date<
    [ unparse 2 tail ] 2dip
    "https://bespin.org/~nef/logs/%s/%02s.%02d.%02d"
    sprintf ;

: <display-irclog-action> ( -- action )
    <action>
        [ "concatenative" irc-link <redirect> ] >>display ;

: <irclog-app> ( -- dispatcher )
    irclog-app new-dispatcher
        <display-irclog-action> "" add-responder ;
