USING: accessors alien.c-types classes.struct combinators io kernel
math math.bitwise tools.image-analyzer.gc-info tools.image-analyzer.vm ;
IN: tools.image-analyzer.code-heap-reader
QUALIFIED: layouts

TUPLE: code-block-t free? owner parameters relocation gc-maps payload ;

: free? ( code-block -- ? )
    header>> 1 mask? ;

: size ( code-block -- n )
    header>> dup 1 mask? [ 7 unmask ] [ 0xfffff8 mask ] if ;

: (read-code-block) ( -- code-block payload )
    code-block [ read-struct ] [ heap-size ] bi over size swap - read ;

: >code-block< ( code-block -- free? owner parameters relocation )
    { [ free? ] [ owner>> ] [ parameters>> ] [ relocation>> ] } cleave ;

: read-code-block ( -- code-block )
    (read-code-block)
    [ >code-block< ] [ [ byte-array>gc-maps ] keep ] bi*
    code-block-t boa ;
