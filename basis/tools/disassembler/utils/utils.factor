USING: accessors kernel math math.parser prettyprint sequences
splitting tools.memory ;
IN: tools.disassembler.utils

: 0x- ( str -- str' ) "0x" prepend ;

: complete-address ( n seq -- str )
    [ nip owner>> unparse-short ] [ entry-point>> - ] 2bi
    [ >hex 0x- " + " glue ] unless-zero ;

: search-xt ( addr -- str/f )
    dup lookup-return-address
    dup [ complete-address ] [ 2drop f ] if ;

: resolve-xt ( str -- str' )
    [ 0x- ] [ hex> ] bi
    [ search-xt [ " (" ")" surround append ] when* ] when* ;

: resolve-call ( str -- str' )
    "0x" split1-last [ resolve-xt "0x" glue ] when* ;
