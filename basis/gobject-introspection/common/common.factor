! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces ;
IN: gobject-introspection.common

CONSTANT: ffi-vocab "ffi"

SYMBOL: current-lib

SYMBOL: type-infos
type-infos [ H{ } ] initialize

SYMBOL: aliases
aliases [ H{ } ] initialize

SYMBOL: implement-structs
implement-structs [ V{ } ] initialize

SYMBOL: replaced-c-types
replaced-c-types [ H{ } ] initialize

