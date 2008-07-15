! Copyright (C) 2008 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry splitting ascii calendar accessors combinators qualified
       arrays classes.tuple math.order ;
RENAME: join sequences => sjoin
EXCLUDE: sequences => join ;
IN: irc.messages

TUPLE: irc-message line prefix command parameters trailing timestamp ;
TUPLE: logged-in < irc-message name ;
TUPLE: ping < irc-message ;
TUPLE: join < irc-message ;
TUPLE: part < irc-message channel ;
TUPLE: quit < irc-message ;
TUPLE: privmsg < irc-message name ;
TUPLE: kick < irc-message channel who ;
TUPLE: roomlist < irc-message channel names ;
TUPLE: nick-in-use < irc-message asterisk name ;
TUPLE: notice < irc-message type ;
TUPLE: mode < irc-message name channel mode ;
TUPLE: names-reply < irc-message who = channel ;
TUPLE: unhandled < irc-message ;

: make-client-message ( command parameters trailing -- irc-message )
    irc-message new now >>timestamp
    [ [ (>>trailing) ] [ (>>parameters) ] [ (>>command) ] tri ] keep ;

GENERIC: irc-message>client-line ( irc-message -- string )

M: irc-message irc-message>client-line ( irc-message -- string )
    [ command>> ]
    [ parameters>> " " sjoin ]
    [ trailing>> dup [ CHAR: : prefix ] when ]
    tri 3array " " sjoin ;

GENERIC: irc-message>server-line ( irc-message -- string )
M: irc-message irc-message>server-line ( irc-message -- string )
   drop "not implemented yet" ;

<PRIVATE
! ======================================
! Message parsing
! ======================================

: split-at-first ( seq separators -- before after )
    dupd '[ , member? ] find
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

PRIVATE>

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
        { "353" [ \ names-reply ] }
        { "JOIN" [ \ join ] }
        { "PART" [ \ part ] }
        { "PRIVMSG" [ \ privmsg ] }
        { "QUIT" [ \ quit ] }
        { "MODE" [ \ mode ] }
        { "KICK" [ \ kick ] }
        [ drop \ unhandled ]
    } case
    [ [ tuple-slots ] [ parameters>> ] bi append ] dip
    [ all-slots over [ length ] bi@ min head ] keep slots>tuple ;

