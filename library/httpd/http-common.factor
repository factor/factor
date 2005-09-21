! Copyright (C) 2003, 2005 Slava Pestov
IN: http
USING: errors kernel lists math namespaces parser sequences
io strings ;

: header-line ( alist line -- alist )
    ": " split1 dup [ cons swons ] [ 2drop ] ifte ;

: (read-header) ( alist -- alist )
    readln dup
    empty? [ drop ] [ header-line (read-header) ] ifte ;

: read-header ( -- alist )
    [ ] (read-header) ;

: url-encode ( str -- str )
    [
        [
            dup url-quotable? [
                ,
            ] [
                CHAR: % , >hex 2 CHAR: 0 pad-left %
            ] ifte
        ] each
    ] "" make ;

: catch-hex> ( str -- n )
    #! Push f if string is not a valid hex literal.
    [ hex> ] catch [ drop f ] when ;

: url-decode-hex ( index str -- )
    2dup length 2 - >= [
        2drop
    ] [
        >r 1+ dup 2 + r> subseq  catch-hex> [ , ] when*
    ] ifte ;

: url-decode-% ( index str -- index str )
    2dup url-decode-hex >r 3 + r> ;

: url-decode-+-or-other ( index str ch -- index str )
    dup CHAR: + = [ drop CHAR: \s ] when , >r 1+ r> ;

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
    [ 0 swap url-decode-iter ] "" make ;
