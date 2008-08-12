! Copyright (C) 2008 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry splitting ascii calendar accessors combinators qualified
       arrays classes.tuple math.order quotations ;
RENAME: join sequences => sjoin
EXCLUDE: sequences => join ;
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
TUPLE: nick-in-use < irc-message asterisk name ;
TUPLE: notice < irc-message type ;
TUPLE: mode < irc-message channel mode ;
TUPLE: names-reply < irc-message who = channel ;
TUPLE: unhandled < irc-message ;

: <irc-client-message> ( command parameters trailing -- irc-message )
    irc-message new now >>timestamp
    [ [ (>>trailing) ] [ (>>parameters) ] [ (>>command) ] tri ] keep ;

<PRIVATE

GENERIC: irc-command-string ( irc-message -- string )

M: irc-message irc-command-string ( irc-message -- string ) command>> ;
M: ping        irc-command-string ( ping -- string )    drop "PING" ;
M: join        irc-command-string ( join -- string )    drop "JOIN" ;
M: part        irc-command-string ( part -- string )    drop "PART" ;
M: quit        irc-command-string ( quit -- string )    drop "QUIT" ;
M: nick        irc-command-string ( nick -- string )    drop "NICK" ;
M: privmsg     irc-command-string ( privmsg -- string ) drop "PRIVMSG" ;
M: notice      irc-command-string ( notice -- string )  drop "NOTICE" ;
M: mode        irc-command-string ( mode -- string )    drop "MODE" ;
M: kick        irc-command-string ( kick -- string )    drop "KICK" ;

GENERIC: irc-command-parameters ( irc-message -- seq )

M: irc-message irc-command-parameters ( irc-message -- seq ) parameters>> ;
M: ping        irc-command-parameters ( ping -- seq )    drop { } ;
M: join        irc-command-parameters ( join -- seq )    drop { } ;
M: part        irc-command-parameters ( part -- seq )    name>> 1array ;
M: quit        irc-command-parameters ( quit -- seq )    drop { } ;
M: nick        irc-command-parameters ( nick -- seq )    drop { } ;
M: privmsg     irc-command-parameters ( privmsg -- seq ) name>> 1array ;
M: notice      irc-command-parameters ( norice -- seq )  type>> 1array ;
M: kick irc-command-parameters ( kick -- seq )
    [ channel>> ] [ who>> ] bi 2array ;
M: mode irc-command-parameters ( mode -- seq )
    [ name>> ] [ channel>> ] [ mode>> ] tri 3array ;

PRIVATE>

GENERIC: irc-message>client-line ( irc-message -- string )

M: irc-message irc-message>client-line ( irc-message -- string )
    [ irc-command-string ]
    [ irc-command-parameters " " sjoin ]
    [ trailing>> [ CHAR: : prefix ] [ "" ] if* ]
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

UNION: sender-in-prefix privmsg join part quit kick mode nick ;
GENERIC: irc-message-sender ( irc-message -- sender )
M: sender-in-prefix irc-message-sender ( sender-in-prefix -- sender )
    prefix>> parse-name ;

: string>irc-message ( string -- object )
    dup split-prefix split-trailing
    [ [ blank? ] trim " " split unclip swap ] dip
    now irc-message boa ;

: parse-irc-line ( string -- message )
    string>irc-message
    dup command>> {
        { "PING" [ ping ] }
        { "NOTICE" [ notice ] }
        { "001" [ logged-in ] }
        { "433" [ nick-in-use ] }
        { "353" [ names-reply ] }
        { "JOIN" [ join ] }
        { "PART" [ part ] }
        { "NICK" [ nick ] }
        { "PRIVMSG" [ privmsg ] }
        { "QUIT" [ quit ] }
        { "MODE" [ mode ] }
        { "KICK" [ kick ] }
        [ drop unhandled ]
    } case
    [ [ tuple-slots ] [ parameters>> ] bi append ] dip
    [ all-slots over [ length ] bi@ min head >quotation ] keep
    '[ @ , boa nip ] call ;
