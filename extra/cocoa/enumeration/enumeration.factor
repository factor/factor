USING: kernel cocoa cocoa.types alien.c-types locals math sequences
vectors fry ;
IN: cocoa.enumeration

: NS-EACH-BUFFER-SIZE 16 ; inline

: (allocate-enumeration-buffers) ( -- state stackbuf count )
    "NSFastEnumerationState" <c-object>
    NS-EACH-BUFFER-SIZE "id" <c-array>
    NS-EACH-BUFFER-SIZE ;

:: (NSFastEnumeration-each) ( object quot state stackbuf count -- )
    object state stackbuf count -> countByEnumeratingWithState:objects:count:
    dup zero? [ drop ] [
        [
            state NSFastEnumerationState-itemsPtr dup stackbuf ?
            void*-nth quot call
        ] each object quot state stackbuf count (NSFastEnumeration-each)
    ] if ; inline

: NSFastEnumeration-each ( object quot -- )
    (allocate-enumeration-buffers) (NSFastEnumeration-each) ; inline

: NSFastEnumeration-map ( object quot -- vector )
    NS-EACH-BUFFER-SIZE <vector> [ '[ @ , push ] NSFastEnumeration-each ] keep ; inline

: NSFastEnumeration>vector ( object -- vector )
    [ ] NSFastEnumeration-map ;
