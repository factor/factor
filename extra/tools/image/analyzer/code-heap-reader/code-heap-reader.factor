USING: accessors alien.c-types classes.struct io kernel math
math.bitwise tools.image.analyzer.gc-info tools.image.analyzer.vm ;
IN: tools.image.analyzer.code-heap-reader
QUALIFIED: layouts

: free? ( code-block -- ? )
    header>> 1 mask? ;

: size ( code-block -- n )
    header>> dup 1 mask? [ 7 unmask ] [ 0xfffff8 mask ] if ;

: (read-code-block) ( -- code-block payload )
    code-block [ read-struct ] [ heap-size ] bi over size swap - read ;

: read-code-block ( -- code-block )
    tell-input (read-code-block) 2dup [ free? ] [ byte-array>gc-maps ] bi*
    code-heap-node boa ;
