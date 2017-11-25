! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors effects io.pathnames kernel math math.parser
sequences strings vocabs words ;
IN: present

GENERIC: present ( object -- string )

M: real present number>string ;

M: complex present ( c -- str )
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
