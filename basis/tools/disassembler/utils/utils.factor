USING: accessors arrays binary-search kernel math math.order
math.parser namespaces sequences sorting splitting vectors vocabs words ;
IN: tools.disassembler.utils

SYMBOL: words-xt
SYMBOL: smallest-xt
SYMBOL: greatest-xt

: (words-xt) ( -- assoc )
    vocabs [ words ] map concat [ [ word-xt ] keep 3array ] map
    [ [ first ] bi@ <=> ] sort >vector ;

: complete-address ( n seq -- str )
    [ first - ] [ third name>> ] bi
    over zero? [ nip ] [ swap 16 >base "0x" prepend "+" glue ] if ;

: search-xt ( n -- str/f )
    dup [ smallest-xt get < ] [ greatest-xt get > ] bi or [
        drop f
    ] [
        words-xt get over [ swap first <=> ] curry search nip
        2dup second <= [
            [ complete-address ] [ drop f ] if*
        ] [
            2drop f
        ] if
    ] if ;

: resolve-xt ( str -- str' )
    [ "0x" prepend ] [ 16 base> ] bi
    [ search-xt [ " (" ")" surround append ] when* ] when* ;

: resolve-call ( str -- str' )
    "0x" split1-last [ resolve-xt "0x" glue ] when* ;

: with-words-xt ( quot -- )
    [ (words-xt)
      [ words-xt set ]
      [ first first smallest-xt set ]
      [ last second greatest-xt set ] tri
    ] prepose with-scope ; inline
