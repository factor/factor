! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: generic kernel kernel-internals lists math sequences ;

! Strings
DEFER: string?
BUILTIN: string 12 string? [ 1 length f ] [ 2 hashcode f ] ;

M: string =
    over string? [
        over hashcode over hashcode number= [
            string-compare 0 eq?
        ] [
            2drop f
        ] ifte
    ] [
        2drop f
    ] ifte ;

M: string nth ( n str -- ch )
    bounds-check char-slot ;

GENERIC: >string ( seq -- string )

M: string >string ;

: string> ( str1 str2 -- ? )
    ! Returns if the first string lexicographically follows str2
    string-compare 0 > ;

! Characters
PREDICATE: integer blank     " \t\n\r" contains? ;
PREDICATE: integer letter    CHAR: a CHAR: z between? ;
PREDICATE: integer LETTER    CHAR: A CHAR: Z between? ;
PREDICATE: integer digit     CHAR: 0 CHAR: 9 between? ;
PREDICATE: integer printable CHAR: \s CHAR: ~ between? ;

: quotable? ( ch -- ? )
    #! In a string literal, can this character be used without
    #! escaping?
    dup printable? swap "\"\\" contains? not and ;

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    dup letter?
    over LETTER? or
    over digit? or
    swap "/_?." contains? or ;
