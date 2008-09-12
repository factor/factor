USING: arrays kernel io io.binary sbufs splitting grouping
strings sequences namespaces math math.parser parser
hints math.bitwise assocs ;
IN: crypto.common

: (nth-int) ( string n -- int )
    2 shift dup 4 + rot <slice> ; inline
    
: nth-int ( string n -- int ) (nth-int) le> ; inline
    
: update ( num var -- ) [ w+ ] change ; inline

SYMBOL: big-endian?

: mod-nth ( n seq -- elt )
    #! 5 "abcd" -> b
    [ length mod ] [ nth ] bi ;
