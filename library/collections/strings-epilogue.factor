! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: generic kernel kernel-internals lists math namespaces
sequences strings ;

: sbuf-append ( ch/str sbuf -- )
    over string? [ swap nappend ] [ push ] ifte ;

: fill ( count char -- string ) <repeated> >string ;

: pad ( string count char -- string )
    >r over length - dup 0 <= [
        r> 2drop
    ] [
        r> fill swap append
    ] ifte ;

: ch>string ( ch -- str ) 1 <sbuf> [ push ] keep (sbuf>string) ;

: >sbuf ( seq -- sbuf ) dup length <sbuf> [ swap nappend ] keep ;

M: object >string >sbuf (sbuf>string) ;

M: string thaw >sbuf ;

M: string like ( seq sbuf -- string ) drop >string ;

M: sbuf clone ( sbuf -- sbuf )
    [ length <sbuf> dup ] keep nappend ;

M: sbuf like ( seq sbuf -- sbuf ) drop >sbuf ;
