! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs continuations debugger io io.styles kernel
namespaces sequences vocabs vocabs.loader ;
IN: vocabs.errors

<PRIVATE

: vocab-heading. ( vocab -- )
    nl
    "==== " write
    [ vocab-name ] [ vocab write-object ] bi ":" print
    nl ;

: load-error. ( triple -- )
    [ first vocab-heading. ] [ second print-error ] bi ;

SYMBOL: failures

PRIVATE>

: load-failures. ( failures -- )
    [ load-error. nl ] each ;

: require-all ( vocabs -- failures )
    [
        V{ } clone blacklist set
        V{ } clone failures set
        [
            [ require ]
            [ swap vocab-name failures get set-at ]
            recover
        ] each
        failures get
    ] with-scope ;