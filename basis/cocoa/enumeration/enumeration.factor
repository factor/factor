! Copyright (C) 2008 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data assocs classes.struct cocoa
cocoa.runtime cocoa.types destructors hashtables kernel libc
sequences specialized-arrays vectors ;
IN: cocoa.enumeration
SPECIALIZED-ARRAY: id
IN: cocoa.enumeration

CONSTANT: NS-EACH-BUFFER-SIZE 16

: with-enumeration-buffers ( quot -- )
    '[
        NSFastEnumerationState malloc-struct &free
        NS-EACH-BUFFER-SIZE id malloc-array &free
        NS-EACH-BUFFER-SIZE
        @
    ] with-destructors ; inline

:: (NSFastEnumeration-each) ( ... object quot: ( ... elt -- ) state stackbuf count -- ... )
    object state stackbuf count -> countByEnumeratingWithState:objects:count: :> items-count
    items-count 0 = [
        state itemsPtr>> [ items-count id <c-direct-array> ] [ stackbuf ] if* :> items
        items-count <iota> [ items nth quot call ] each
        object quot state stackbuf count (NSFastEnumeration-each)
    ] unless ; inline recursive

: NSFastEnumeration-each ( ... object quot: ( ... elt -- ... ) -- ... )
    [ (NSFastEnumeration-each) ] with-enumeration-buffers ; inline

: NSFastEnumeration-map ( ... object quot: ( ... elt -- ... newelt ) -- ... vector )
    NS-EACH-BUFFER-SIZE <vector>
    [ '[ @ _ push ] NSFastEnumeration-each ] keep ; inline

: NSFastEnumeration>vector ( object -- vector )
    [ ] NSFastEnumeration-map ;

: NSFastEnumeration>hashtable ( ... object quot: ( ... elt -- ... key value ) -- ... vector )
    NS-EACH-BUFFER-SIZE <hashtable>
    [ '[ @ swap _ set-at ] NSFastEnumeration-each ] keep ; inline
