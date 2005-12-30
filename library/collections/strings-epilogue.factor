! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: generic kernel kernel-internals lists math namespaces
sequences strings vectors ;

: padding ( string count char -- string )
    >r swap length - 0 max r> <string> ; flushable

: pad-left ( string count char -- string )
    pick >r padding r> append ; flushable

: pad-right ( string count char -- string )
    pick >r padding r> swap append ; flushable

: ch>string ( ch -- str ) 1 swap <string> ; flushable

: >sbuf dup length <sbuf> [ swap nappend ] keep ; inline

: >string ( seq -- array )
    [ length 0 <string> 0 over ] keep copy-into ; inline

M: string thaw >sbuf ;

M: string like ( seq sbuf -- string )
    drop dup string? [ >string ] unless ;

M: sbuf like ( seq sbuf -- sbuf )
    drop dup sbuf? [ >sbuf ] unless ;

: a/an ( string -- ) first ch>lower "aeiou" member? "an " "a " ? ;
