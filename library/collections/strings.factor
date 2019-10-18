! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: generic kernel kernel-internals lists math sequences ;

M: string nth ( n str -- ch ) bounds-check char-slot ;

GENERIC: >string ( seq -- string ) flushable

M: string >string ;

! Characters
PREDICATE: integer blank     " \t\n\r" member? ;
PREDICATE: integer letter    CHAR: a CHAR: z between? ;
PREDICATE: integer LETTER    CHAR: A CHAR: Z between? ;
PREDICATE: integer digit     CHAR: 0 CHAR: 9 between? ;
PREDICATE: integer printable CHAR: \s CHAR: ~ between? ;

: quotable? ( ch -- ? )
    #! In a string literal, can this character be used without
    #! escaping?
    dup printable? swap "\"\\" member? not and ; foldable

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    dup letter?
    over LETTER? or
    over digit? or
    swap "/_?." member? or ; foldable
