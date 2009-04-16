! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry splitting ascii accessors combinators
       arrays classes.tuple math.order words assocs
       irc.messages.base sequences ;
IN: irc.messages.parser

<PRIVATE
: split-at-first ( seq separators -- before after )
    dupd '[ _ member? ] find [ cut 1 tail ] [ swap ] if ;

: split-trailing ( string -- string string/f ) ":" split1 ;
: remove-heading-: ( seq -- seq ) ":" ?head drop ;

: split-prefix ( string -- string/f string )
    dup ":" head? [
        remove-heading-: " " split1
    ] [ f swap ] if ;

: split-message ( string -- prefix command parameters trailing )
    split-prefix split-trailing
    [ [ blank? ] trim " " split unclip swap ] dip ;

: sender ( irc-message -- sender )
    prefix>> [ remove-heading-: "!" split-at-first drop ] [ f ] if* ;
PRIVATE>

: string>irc-message ( string -- irc-message )
    dup split-message
    [ [ irc>type new ] [ >>command ] bi ]
    [ >>parameters ]
    [ >>trailing ]
    tri*
    [ (>>prefix) ] [ fill-irc-message-slots ] [ swap >>line ] tri
    dup sender >>sender ;
