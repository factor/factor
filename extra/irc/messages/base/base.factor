! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar classes.parser
classes.tuple combinators generic.parser kernel lexer mirrors
namespaces parser sequences splitting words ;
IN: irc.messages.base

TUPLE: irc-message line prefix command parameters trailing timestamp sender ;
TUPLE: unhandled < irc-message ;

SYMBOL: string-irc-type-mapping
string-irc-type-mapping [ H{ } clone ] initialize

: register-irc-message-type ( type string -- )
    string-irc-type-mapping get set-at ;

: irc>type ( string -- irc-message-class )
    string-irc-type-mapping get at unhandled or ;

GENERIC: irc-trailing-slot ( irc-message -- string/f )
M: irc-message irc-trailing-slot
    drop f ;

GENERIC: irc-parameter-slots ( irc-message -- seq )
M: irc-message irc-parameter-slots
    drop f ;

GENERIC: process-irc-trailing ( irc-message -- )
M: irc-message process-irc-trailing
    dup irc-trailing-slot [
        swap [ trailing>> swap ] [ <mirror> ] bi set-at
    ] [ drop ] if* ;

GENERIC: process-irc-prefix ( irc-message -- )
M: irc-message process-irc-prefix
    drop ;

<PRIVATE
: [slot-setter] ( mirror -- quot )
    '[ [ _ set-at ] [ drop ] if* ] ; inline
PRIVATE>

GENERIC: process-irc-parameters ( irc-message -- )
M: irc-message process-irc-parameters
    dup irc-parameter-slots [
        swap [ parameters>> swap ] [ <mirror> [slot-setter] ] bi 2each
    ] [ drop ] if* ;

GENERIC: post-process-irc-message ( irc-message -- )
M: irc-message post-process-irc-message drop ;

GENERIC: fill-irc-message-slots ( irc-message -- )
M: irc-message fill-irc-message-slots
    now-gmt >>timestamp
    {
        [ process-irc-trailing ]
        [ process-irc-prefix ]
        [ process-irc-parameters ]
        [ post-process-irc-message ]
    } cleave ;

GENERIC: irc-command-string ( irc-message -- string )
M: irc-message irc-command-string drop f ;

! FIXME: inverse of post-process is missing
GENERIC: set-irc-parameters ( irc-message -- )
M: irc-message set-irc-parameters
    dup irc-parameter-slots
    [ over <mirror> '[ _ at ] map >>parameters ] when* drop ;

GENERIC: set-irc-trailing ( irc-message -- )
M: irc-message set-irc-trailing
    dup irc-trailing-slot [ over <mirror> at >>trailing ] when* drop ;

GENERIC: set-irc-command ( irc-message -- )
M: irc-message set-irc-command
    [ irc-command-string ] [ command<< ] bi ;

: irc-message>string ( irc-message -- string )
    {
        [ prefix>> ]
        [ command>> ]
        [ parameters>> join-words ]
        [ trailing>> dup [ CHAR: : prefix ] when ]
    } cleave 4array sift join-words ;

<PRIVATE
: ?define-irc-parameters ( class slot-names -- )
    dup empty? not [
        [ \ irc-parameter-slots create-method-in ] dip
        [ [ "_" = not ] 1guard ] map '[ drop _ ] define
    ] [ 2drop ] if ;

: ?define-irc-trailing ( class slot-name -- )
    [
        [ \ irc-trailing-slot create-method-in ] dip
        first '[ drop _ ] define
    ] [ drop ] if* ;

: define-irc-class ( class params -- )
    [ { ":" "_" } member? ] reject
    [ irc-message ] dip define-tuple-class ;

: define-irc-parameter-slots ( class params -- )
    { ":" } split1 overd
    [ ?define-irc-parameters ] [ ?define-irc-trailing ] 2bi* ;
PRIVATE>

! SYNTAX: name string parameters ;
! IRC: type "COMMAND" slot1 ...;
! IRC: type "COMMAND" slot1 ... : trailing-slot;
SYNTAX: IRC:
    scan-new-class
    [ scan-object register-irc-message-type ] keep
    ";" parse-tokens
    [ define-irc-class ] [ define-irc-parameter-slots ] 2bi ;
