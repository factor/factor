! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry splitting ascii accessors combinators
       arrays classes.tuple math.order words assocs
       irc.messages.base sequences ;
IN: irc.messages.parser

<PRIVATE
: split-at-first ( seq separators -- before after )
    dupd '[ _ member? ] find [ cut rest ] [ swap ] if ;

! ":ircuser!n=user@isp.net JOIN :#factortest"
: split-message ( string -- prefix command parameters trailing )
    ":" ?head [ " " split1 ] [ f swap ] if
    ":" split1
    [ " " split harvest unclip swap ] dip ;

: sender ( irc-message -- sender )
    prefix>> [ ":" ?head drop "!" split-at-first drop ] [ f ] if* ;
PRIVATE>

: string>irc-message ( string -- irc-message )
    dup split-message
    [ [ irc>type new ] [ >>command ] bi ]
    [ >>parameters ]
    [ >>trailing ]
    tri*
    [ prefix<< ] [ fill-irc-message-slots ] [ swap >>line ] tri
    dup sender >>sender ;
