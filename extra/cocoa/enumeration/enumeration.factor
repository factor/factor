USING: kernel cocoa cocoa.types alien.c-types locals math sequences
vectors fry libc ;
IN: cocoa.enumeration

: NS-EACH-BUFFER-SIZE 16 ; inline

: (with-enumeration-buffers) ( quot -- )
    "NSFastEnumerationState" heap-size swap '[
        NS-EACH-BUFFER-SIZE "id" heap-size * [
            NS-EACH-BUFFER-SIZE @
        ] with-malloc
    ] with-malloc ; inline

:: (NSFastEnumeration-each) ( object quot state stackbuf count -- )
    object state stackbuf count -> countByEnumeratingWithState:objects:count:
    dup zero? [ drop ] [
        state NSFastEnumerationState-itemsPtr [ stackbuf ] unless*
        '[ , void*-nth quot call ] each
        object quot state stackbuf count (NSFastEnumeration-each)
    ] if ; inline

: NSFastEnumeration-each ( object quot -- )
    [ (NSFastEnumeration-each) ] (with-enumeration-buffers) ; inline

: NSFastEnumeration-map ( object quot -- vector )
    NS-EACH-BUFFER-SIZE <vector>
    [ '[ @ , push ] NSFastEnumeration-each ] keep ; inline

: NSFastEnumeration>vector ( object -- vector )
    [ ] NSFastEnumeration-map ;
