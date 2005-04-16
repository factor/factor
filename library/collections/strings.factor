! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings USING: generic kernel kernel-internals lists math
sequences ;

BUILTIN: string 12 [ 1 "string-length" f ] [ 2 hashcode f ] ;
M: string = string= ;

BUILTIN: sbuf 13 ;
M: sbuf = sbuf= ;

UNION: text string integer ;

M: string length string-length ;
M: string nth string-nth ;

: f-or-"" ( obj -- ? )
    dup not swap "" = or ;

: string-length< ( str str -- boolean )
    #! Compare string lengths.
    swap string-length swap string-length < ;

: cat ( [ "a" "b" "c" ] -- "abc" )
    ! If f appears in the list, it is not appended to the
    ! string.
    80 <sbuf> swap [ [ over sbuf-append ] when* ] each sbuf>string ;

: cat2 ( "a" "b" -- "ab" )
    swap
    80 <sbuf>
    dup >r sbuf-append r>
    dup >r sbuf-append r>
    sbuf>string ;

: cat3 ( "a" "b" "c" -- "abc" )
    [ ] cons cons cons cat ;

: index-of ( string substring -- index )
    0 -rot index-of* ;

: string> ( str1 str2 -- ? )
    ! Returns if the first string lexicographically follows str2
    string-compare 0 > ;

: string-head ( index str -- str )
    #! Returns a new string, from the beginning of the string
    #! until the given index.
    0 -rot substring ;

: string-contains? ( substr str -- ? )
    swap index-of -1 = not ;

: string-tail ( index str -- str )
    #! Returns a new string, from the given index until the end
    #! of the string.
    [ string-length ] keep substring ;

: string/ ( str index -- str str )
    #! Returns 2 strings, that when concatenated yield the
    #! original string.
    [ swap string-head ] 2keep swap string-tail ;

: string// ( str index -- str str )
    #! Returns 2 strings, that when concatenated yield the
    #! original string, without the character at the given
    #! index.
    [ swap string-head ] 2keep 1 + swap string-tail ;

: string-head? ( str begin -- ? )
    2dup string-length< [
        2drop f
    ] [
        dup string-length rot string-head =
    ] ifte ;

: ?string-head ( str begin -- str ? )
    2dup string-head? [
        string-length swap string-tail t
    ] [
        drop f
    ] ifte ;

: string-tail? ( str end -- ? )
    2dup string-length< [
        2drop f
    ] [
        dup string-length pick string-length swap - rot string-tail =
    ] ifte ;

: ?string-tail ( str end -- ? )
    2dup string-tail? [
        string-length swap [ string-length swap - ] keep string-head t
    ] [
        drop f
    ] ifte ;

: split1 ( string split -- before after )
    2dup index-of dup -1 = [
        2drop f
    ] [
        [ swap string-length + over string-tail ] keep
        rot string-head swap
    ] ifte ;

PREDICATE: integer blank     " \t\n\r" string-contains? ;
PREDICATE: integer letter    CHAR: a CHAR: z between? ;
PREDICATE: integer LETTER    CHAR: A CHAR: Z between? ;
PREDICATE: integer digit     CHAR: 0 CHAR: 9 between? ;
PREDICATE: integer printable CHAR: \s CHAR: ~ between? ;

: quotable? ( ch -- ? )
    #! In a string literal, can this character be used without
    #! escaping?
    dup printable? swap "\"\\" string-contains? not and ;

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    dup letter?
    over LETTER? or
    over digit? or
    swap "/_?." string-contains? or ;
