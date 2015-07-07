USING: accessors alien alien.c-types byte-arrays classes.struct
combinators io kernel math math.bitwise
specialized-arrays.instances.alien.c-types.uchar
tools.image-analyzer.gc-info tools.image-analyzer.vm vm words ;
IN: tools.image-analyzer.code-heap-reader
QUALIFIED: layouts

TUPLE: code-block-t free? owner parameters relocation gc-maps payload ;

: word>byte-array ( word -- array )
    word-code swap code-block heap-size -
    over <alien> -rot - <direct-uchar-array> >byte-array ;

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
