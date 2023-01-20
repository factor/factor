! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors irc.messages.base kernel sequences splitting ;
IN: irc.messages.parser

<PRIVATE
: split-at-first ( seq separators -- before after )
    dupd '[ _ member? ] find [ cut rest ] [ swap ] if ;

! ":ircuser!n=user@isp.net JOIN :#factortest"
: split-message ( string -- prefix command parameters trailing )
    ":" ?head [ " " split1 ] [ f swap ] if
    ":" split1
    [ split-words harvest unclip swap ] dip ;

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
