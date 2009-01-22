! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cocoa cocoa.types alien.c-types locals math
sequences vectors fry libc destructors
specialized-arrays.direct.alien ;
IN: cocoa.enumeration

: NS-EACH-BUFFER-SIZE 16 ; inline

: with-enumeration-buffers ( quot -- )
    '[
        "NSFastEnumerationState" malloc-object &free
        NS-EACH-BUFFER-SIZE "id" malloc-array &free
        NS-EACH-BUFFER-SIZE
        @
    ] with-destructors ; inline

:: (NSFastEnumeration-each) ( object quot: ( elt -- ) state stackbuf count -- )
    object state stackbuf count -> countByEnumeratingWithState:objects:count:
    dup 0 = [ drop ] [
        state NSFastEnumerationState-itemsPtr [ stackbuf ] unless*
        swap <direct-void*-array> quot each
        object quot state stackbuf count (NSFastEnumeration-each)
    ] if ; inline recursive

: NSFastEnumeration-each ( object quot -- )
    [ (NSFastEnumeration-each) ] with-enumeration-buffers ; inline

: NSFastEnumeration-map ( object quot -- vector )
    NS-EACH-BUFFER-SIZE <vector>
    [ '[ @ _ push ] NSFastEnumeration-each ] keep ; inline

: NSFastEnumeration>vector ( object -- vector )
    [ ] NSFastEnumeration-map ;
