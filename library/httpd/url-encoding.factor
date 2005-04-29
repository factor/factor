! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: url-encoding
USING: errors kernel math namespaces parser sequences strings
unparser ;

: url-encode ( str -- str )
    [
        [
            dup url-quotable? [
                ,
            ] [
                CHAR: % , >hex 2 CHAR: 0 pad %
            ] ifte
        ] seq-each
    ] make-string ;

: catch-hex> ( str -- n )
    #! Push f if string is not a valid hex literal.
    [ hex> ] [ [ drop f ] when ] catch ;

: url-decode-hex ( index str -- )
    2dup length 2 - >= [
        2drop
    ] [
        >r 1 + dup 2 + r> substring  catch-hex> [ , ] when*
    ] ifte ;

: url-decode-% ( index str -- index str )
    2dup url-decode-hex >r 3 + r> ;

: url-decode-+-or-other ( index str ch -- index str )
    dup CHAR: + = [ drop CHAR: \s ] when , >r 1 + r> ;

: url-decode-iter ( index str -- )
    2dup length >= [
        2drop
    ] [
        2dup nth dup CHAR: % = [
            drop url-decode-%
        ] [
            url-decode-+-or-other
        ] ifte url-decode-iter
    ] ifte ;

: url-decode ( str -- str )
    [ 0 swap url-decode-iter ] make-string ;
