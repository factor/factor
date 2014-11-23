! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs combinators combinators.short-circuit formatting
grouping hashtables io kernel make math math.parser sequences
splitting strings unicode.categories ;

IN: txon

<PRIVATE

: decode-value ( string -- string' )
    "\\`" "`" replace ;

: `? ( ch1 ch2 -- ? )
    [ CHAR: \ = not ] [ CHAR: ` = ] bi* and ;

: (find-`) ( string -- n/f )
    2 clump [ first2 `? ] find drop [ 1 + ] [ f ] if* ;

: find-` ( string -- n/f )
    dup ?first CHAR: ` = [ drop 0 ] [ (find-`) ] if ;

: parse-name ( string -- remain name )
    ":`" split1 swap decode-value ;

DEFER: name/values

: (parse-value) ( string -- values )
    decode-value string-lines dup length 1 = [ first ] when ;

: parse-value ( string -- remain value )
    dup find-` [
        dup 1 - pick ?nth CHAR: : =
        [ drop name/values ] [ cut swap (parse-value) ] if
        [ rest [ blank? ] trim-head ] dip
    ] [ f swap ] if* ;

: (name=value) ( string -- remain term )
    parse-name [ parse-value ] dip associate ;

: name=value ( string -- remain term )
    [ blank? ] trim
    ":`" over subseq? [ (name=value) ] [ f swap ] if ;

: name/values ( string -- remain terms )
    [ dup { [ empty? not ] [ first CHAR: ` = not ] } 1&& ]
    [ name=value ] produce assoc-combine ;

: parse-txon ( string -- objects )
    [ dup empty? not ] [ name=value ] produce nip ;

PRIVATE>

: txon> ( string -- object )
    parse-txon dup length 1 = [ first ] when ;

<PRIVATE

: encode-value ( string -- string' )
    "`" "\\`" replace ;

PRIVATE>

GENERIC: >txon ( object -- string )

M: sequence >txon
    [ >txon ] map "\n" join ;

M: assoc >txon
    >alist [
        first2 [ encode-value ] [ >txon ] bi* "%s:`%s`" sprintf
    ] map "\n" join ;

M: string >txon
    encode-value ;

M: number >txon
    number>string >txon ;
