! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings USING: kernel lists math namespaces strings ;

: fill ( count char -- string )
    #! Push a string that consists of the same character
    #! repeated.
    [ swap [ dup , ] times drop ] make-string ;

: pad ( string count char -- string )
    >r over string-length - dup 0 <= [
        r> 2drop
    ] [
        r> fill swap cat2
    ] ifte ;

: string-map ( str code -- str )
    #! Apply a quotation to each character in the string, and
    #! push a new string constructed from return values.
    #! The quotation must have stack effect ( X -- X ).
    over string-length <sbuf> rot [
        swap >r apply swap r> tuck sbuf-append
    ] string-each nip sbuf>string ; inline

: split-next ( index string split -- next )
    3dup index-of* dup -1 = [
        >r drop string-tail , r> ( end of string )
    ] [
        swap string-length dupd + >r swap substring , r>
    ] ifte ;

: (split) ( index string split -- )
    2dup >r >r split-next dup -1 = [
        drop r> drop r> drop
    ] [
        r> r> (split)
    ] ifte ;

: split ( string split -- list )
    #! Split the string at each occurrence of split, and push a
    #! list of the pieces.
    [ 0 -rot (split) ] make-list ;

: split-n-advance substring , >r tuck + swap r> ;
: split-n-finish nip dup string-length swap substring , ;

: (split-n) ( start n str -- )
    3dup >r dupd + r> 2dup string-length < [
        split-n-advance (split-n)
    ] [
        split-n-finish 3drop
    ] ifte ;

: split-n ( n str -- list )
    #! Split a string into n-character chunks.
    [ 0 -rot (split-n) ] make-list ;

: ch>string ( ch -- str )
    1 <sbuf> [ sbuf-append ] keep sbuf>string ;
