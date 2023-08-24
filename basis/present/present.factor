! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types effects io.pathnames kernel math
math.parser quotations sequences splitting strings vocabs words ;
IN: present

GENERIC: present ( object -- string )

M: real present number>string ;

M: complex present
    [ real>> number>string ]
    [
        imaginary>>
        [ number>string ]
        [ 0 >= [ "+" prepend ] when ] bi
    ] bi "j" 3append ;

M: string present ;

M: word present name>> ;

M: vocab-spec present name>> ;

M: effect present effect>string ;

M: f present drop "" ;

M: pathname present string>> ;

M: callable present
    [ "[ ]" ] [
        [ drop "[ " ]
        [ [ present ] map join-words ]
        [ drop " ]" ] tri 3append
    ] if-empty ;

M: pointer present
    to>> name>> "*" append ;
