! Copyright (C) 2003, 2005 Slava Pestov
IN: http
USING: errors kernel lists math namespaces parser sequences
io strings ;

: header-line ( line -- )
    ": " split1 dup [ swap set ] [ 2drop ] if ;

: (read-header) ( hash -- hash )
    readln dup
    empty? [ drop ] [ header-line (read-header) ] if ;

: read-header ( -- hash )
    [ (read-header) ] make-hash ;

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    dup letter?
    over LETTER? or
    over digit? or
    swap "/_?." member? or ; foldable

: url-encode ( str -- str )
    [
        [
            dup url-quotable? [
                ,
            ] [
                CHAR: % , >hex 2 CHAR: 0 pad-left %
            ] if
        ] each
    ] "" make ;

: catch-hex> ( str -- n/f )
    #! Push f if string is not a valid hex literal.
    [ hex> ] catch [ drop f ] when ;

: url-decode-hex ( index str -- )
    2dup length 2 - >= [
        2drop
    ] [
        >r 1+ dup 2 + r> subseq  catch-hex> [ , ] when*
    ] if ;

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
        ] if url-decode-iter
    ] if ;

: url-decode ( str -- str )
    [ 0 swap url-decode-iter ] "" make ;
