! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors math math.parser strings words vocabs
kernel effects ;
IN: present

GENERIC: present ( object -- string )

M: real present number>string ;

M: string present ;

M: word present name>> ;

M: vocab-spec present name>> ;

M: effect present effect>string ;

M: f present drop "" ;
