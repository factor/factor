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
TUPLE: nick < irc-message ;
TUPLE: privmsg < irc-message name ;
TUPLE: kick < irc-message channel who ;
TUPLE: roomlist < irc-message channel names ;
TUPLE: nick-in-use < irc-message name ;
TUPLE: notice < irc-message type ;
TUPLE: mode < irc-message name mode parameter ;
TUPLE: names-reply < irc-message who channel ;
TUPLE: end-of-names < irc-message who channel ;
TUPLE: unhandled < irc-message ;

: <irc-client-message> ( command parameters trailing -- irc-message )
    irc-message new
        now >>timestamp
        swap >>trailing
        swap >>parameters
        swap >>command ;

<PRIVATE

GENERIC: command-string>> ( irc-message -- string )

M: irc-message command-string>> ( irc-message -- string ) command>> ;
M: ping        command-string>> ( ping -- string )    drop "PING" ;
M: join        command-string>> ( join -- string )    drop "JOIN" ;
M: part        command-string>> ( part -- string )    drop "PART" ;
M: quit        command-string>> ( quit -- string )    drop "QUIT" ;
M: nick        command-string>> ( nick -- string )    drop "NICK" ;
M: privmsg     command-string>> ( privmsg -- string ) drop "PRIVMSG" ;
M: notice      command-string>> ( notice -- string )  drop "NOTICE" ;
M: mode        command-string>> ( mode -- string )    drop "MODE" ;
M: kick        command-string>> ( kick -- string )    drop "KICK" ;

GENERIC: command-parameters>> ( irc-message -- seq )

M: irc-message command-parameters>> ( irc-message -- seq ) parameters>> ;
M: ping        command-parameters>> ( ping -- seq )    drop { } ;
M: join        command-parameters>> ( join -- seq )    drop { } ;
M: part        command-parameters>> ( part -- seq )    channel>> 1array ;
M: quit        command-parameters>> ( quit -- seq )    drop { } ;
M: nick        command-parameters>> ( nick -- seq )    drop { } ;
M: privmsg     command-parameters>> ( privmsg -- seq ) name>> 1array ;
M: notice      command-parameters>> ( norice -- seq )  type>> 1array ;
M: kick command-parameters>> ( kick -- seq )
    [ channel>> ] [ who>> ] bi 2array ;
M: mode command-parameters>> ( mode -- seq )
    [ name>> ] [ channel>> ] [ mode>> ] tri 3array ;

GENERIC# >>command-parameters 1 ( irc-message params -- irc-message )

M: irc-message >>command-parameters ( irc-message params -- irc-message )
    drop ;

M: logged-in >>command-parameters ( part params -- part )
    first >>name ;

M: privmsg >>command-parameters ( privmsg params -- privmsg )
    first >>name ;

M: notice >>command-parameters ( notice params -- notice )
    first >>type ;

M: part >>command-parameters ( part params -- part )
    first >>channel ;

M: kick >>command-parameters ( kick params -- kick )
    first2 [ >>channel ] [ >>who ] bi* ;

M: nick-in-use >>command-parameters ( nick-in-use params -- nick-in-use )
    second >>name ;

M: names-reply >>command-parameters ( names-reply params -- names-reply )
    first3 nip [ >>who ] [ >>channel ] bi* ;

M: end-of-names >>command-parameters ( names-reply params -- names-reply )
    first2 [ >>who ] [ >>channel ] bi* ;

M: mode >>command-parameters ( mode params -- mode )
    dup length {
        { 3 [ first3 [ >>name ] [ >>mode ] [ >>parameter ] tri* ] }
        { 2 [ first2 [ >>name ] [ >>mode ] bi* ] }
        [ drop first >>name dup trailing>> >>mode ]
    } case ;

PRIVATE>

GENERIC: irc-message>client-line ( irc-message -- string )

M: irc-message irc-message>client-line ( irc-message -- string )
    [ command-string>> ]
    [ command-parameters>> " " sjoin ]
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
    dupd '[ _ member? ] find [ cut 1 tail ] [ swap ] if ;

: remove-heading-: ( seq -- seq )
    ":" ?head drop ;

: parse-name ( string -- string )
    remove-heading-: "!" split-at-first drop ;

: split-prefix ( string -- string/f string )
    dup ":" head?
    [ remove-heading-: " " split1 ] [ f swap ] if ;

: split-trailing ( string -- string string/f )
    ":" split1 ;

: copy-message-in ( command irc-message -- command )
    {
        [ line>>      >>line ]
        [ prefix>>    >>prefix ]
        [ command>>   >>command ]
        [ trailing>>  >>trailing ]
        [ timestamp>> >>timestamp ]
        [ parameters>> [ >>parameters ] [ >>command-parameters ] bi ]
    } cleave ;

PRIVATE>

UNION: sender-in-prefix privmsg join part quit kick mode nick ;
GENERIC: irc-message-sender ( irc-message -- sender )
M: sender-in-prefix irc-message-sender ( sender-in-prefix -- sender )
    prefix>> parse-name ;

: string>irc-message ( string -- object )
    dup split-prefix split-trailing
    [ [ blank? ] trim " " split unclip swap ] dip
    now irc-message boa ;

: irc-message>command ( irc-message -- command )
    [
        command>> {
            { "PING"    [ ping ] }
            { "NOTICE"  [ notice ] }
            { "001"     [ logged-in ] }
            { "433"     [ nick-in-use ] }
            { "353"     [ names-reply ] }
            { "366"     [ end-of-names ] }
            { "JOIN"    [ join ] }
            { "PART"    [ part ] }
            { "NICK"    [ nick ] }
            { "PRIVMSG" [ privmsg ] }
            { "QUIT"    [ quit ] }
            { "MODE"    [ mode ] }
            { "KICK"    [ kick ] }
            [ drop unhandled ]
        } case new
    ] keep copy-message-in ;

: parse-irc-line ( string -- message )
    string>irc-message irc-message>command ;
