! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces ;
IN: gir.common

CONSTANT: ffi-vocab "ffi"

SYMBOL: current-lib

SYMBOL: lib-aliases
lib-aliases [ H{ } ] initialize

SYMBOL: type-infos
type-infos [ H{ } ] initialize

SYMBOL: aliases
aliases [ H{ } ] initialize

: get-lib-alias ( lib -- alias )
    lib-aliases get-global at ;
