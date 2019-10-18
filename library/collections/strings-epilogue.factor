! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: generic kernel kernel-internals lists math namespaces
sequences strings ;

: empty-sbuf ( len -- sbuf )
    dup <sbuf> [ set-length ] keep ; inline

: fill ( count char -- string )
    <repeated> >string ; inline

: padding ( string count char -- string )
    >r swap length - dup 0 <= [ r> 2drop "" ] [ r> fill ] if ;
    flushable

: pad-left ( string count char -- string )
    pick >r padding r> append ; flushable

: pad-right ( string count char -- string )
    pick >r padding r> swap append ; flushable

: ch>string ( ch -- str )
    1 <sbuf> [ push ] keep (sbuf>string) ; flushable

: >sbuf ( seq -- sbuf )
    dup length <sbuf> [ swap nappend ] keep ; inline

M: object >string >sbuf (sbuf>string) ;

M: string thaw >sbuf ;

M: string like ( seq sbuf -- string ) drop >string ;

M: sbuf like ( seq sbuf -- sbuf )
    drop dup sbuf? [ >sbuf ] unless ;
