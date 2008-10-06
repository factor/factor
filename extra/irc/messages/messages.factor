! Copyright (C) 2008 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry splitting ascii calendar accessors combinators qualified
       arrays classes.tuple math.order ;
RENAME: join sequences => sjoin
EXCLUDE: sequences => join ;
EXCLUDE: inverse => _ ;
IN: irc.messages

TUPLE: irc-message line prefix command parameters trailing timestamp ;
TUPLE: logged-in < irc-message name ;
TUPLE: ping < irc-message ;
TUPLE: join < irc-message ;
TUPLE: part < irc-message channel ;
TUPLE: quit < irc-message ;
TUPLE: nick < irc-message ;
TUPLE: privmsg < irc-message name ;
TUPLE: kick < irc-message channel who ;
TUPLE: roomlist < irc-message channel names ;
TUPLE: nick-in-use < irc-message name ;
TUPLE: notice < irc-message type ;
TUPLE: mode < irc-message name mode parameter ;
TUPLE: names-reply < irc-message who channel ;
TUPLE: unhandled < irc-message ;

: <irc-client-message> ( command parameters trailing -- irc-message )
    irc-message new now >>timestamp
    [ [ (>>trailing) ] [ (>>parameters) ] [ (>>command) ] tri ] keep ;

<PRIVATE

GENERIC: command-string>> ( irc-message -- string )

M: irc-message command-string>> command>> ;
M: ping        command-string>> drop "PING" ;
M: join        command-string>> drop "JOIN" ;
M: part        command-string>> drop "PART" ;
M: quit        command-string>> drop "QUIT" ;
M: nick        command-string>> drop "NICK" ;
M: privmsg     command-string>> drop "PRIVMSG" ;
M: notice      command-string>> drop "NOTICE" ;
M: mode        command-string>> drop "MODE" ;
M: kick        command-string>> drop "KICK" ;

GENERIC: command-parameters>> ( irc-message -- seq )

M: irc-message command-parameters>> parameters>> ;
M: ping        command-parameters>> drop { } ;
M: join        command-parameters>> drop { } ;
M: part        command-parameters>> channel>> 1array ;
M: quit        command-parameters>> drop { } ;
M: nick        command-parameters>> drop { } ;
M: privmsg     command-parameters>> name>> 1array ;
M: notice      command-parameters>> type>> 1array ;
M: kick command-parameters>> [ channel>> ] [ who>> ] bi 2array ;
M: mode command-parameters>> [ name>> ] [ channel>> ] [ mode>> ] tri 3array ;

GENERIC: (>>command-parameters) ( params irc-message -- )

M: irc-message (>>command-parameters) 2drop ;
M: logged-in (>>command-parameters) [ first ] dip (>>name) ;
M: privmsg (>>command-parameters) [ first ] dip (>>name) ;
M: notice  (>>command-parameters) [ first ] dip (>>type) ;
M: part    (>>command-parameters) [ first ] dip (>>channel) ;
M: nick-in-use (>>command-parameters) [ second ] dip (>>name) ;
M: kick    (>>command-parameters)
    [ first2 ] dip [ (>>who) ] [ (>>channel) ] bi ;
M: names-reply (>>command-parameters)
    [ [ first ] dip (>>who) ] [ [ third ] dip (>>channel) ] 2bi ;
M: mode    (>>command-parameters)
    { { [ >r 2array r> ] [ [ (>>mode) ] [ (>>name) ] bi ] }
      { [ >r 3array r> ] [ [ (>>parameter) ] [ (>>mode) ] [ (>>name) ] tri ] }
    } switch ;

PRIVATE>

GENERIC: irc-message>client-line ( irc-message -- string )

M: irc-message irc-message>client-line
    [ command-string>> ]
    [ command-parameters>> " " sjoin ]
    [ trailing>> [ CHAR: : prefix ] [ "" ] if* ]
    tri 3array " " sjoin ;

GENERIC: irc-message>server-line ( irc-message -- string )
M: irc-message irc-message>server-line drop "not implemented yet" ;

<PRIVATE
! ======================================
! Message parsing
! ======================================

: split-at-first ( seq separators -- before after )
    dupd '[ _ member? ] find [ cut 1 tail ] [ swap ] if ;

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

: copy-message-in ( origin dest -- )
    { [ [ parameters>> ] dip [ (>>command-parameters) ] [ (>>parameters) ] 2bi ]
      [ [ line>>       ] dip (>>line) ]
      [ [ prefix>>     ] dip (>>prefix) ]
      [ [ command>>    ] dip (>>command) ]
      [ [ trailing>>   ] dip (>>trailing) ]
      [ [ timestamp>>  ] dip (>>timestamp) ]
    } 2cleave ;

PRIVATE>

UNION: sender-in-prefix privmsg join part quit kick mode nick ;
GENERIC: irc-message-sender ( irc-message -- sender )
M: sender-in-prefix irc-message-sender prefix>> parse-name ;

: string>irc-message ( string -- object )
    dup split-prefix split-trailing
    [ [ blank? ] trim " " split unclip swap ] dip
    now irc-message boa ;

: parse-irc-line ( string -- message )
    string>irc-message
    dup command>> {
        { "PING"    [ ping ] }
        { "NOTICE"  [ notice ] }
        { "001"     [ logged-in ] }
        { "433"     [ nick-in-use ] }
        { "353"     [ names-reply ] }
        { "JOIN"    [ join ] }
        { "PART"    [ part ] }
        { "NICK"    [ nick ] }
        { "PRIVMSG" [ privmsg ] }
        { "QUIT"    [ quit ] }
        { "MODE"    [ mode ] }
        { "KICK"    [ kick ] }
        [ drop unhandled ]
    } case new [ copy-message-in ] keep ;
