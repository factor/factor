! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences ;
IN: gobject-introspection.common

SYMBOL: current-namespace-name

INITIALIZED-SYMBOL: implement-structs [ V{ } ]

: implement-struct? ( c-type -- ? )
    implement-structs get-global member? ;
