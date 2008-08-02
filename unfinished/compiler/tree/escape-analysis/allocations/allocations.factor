! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel math
stack-checker.state compiler.tree.copy-equiv ;
IN: compiler.tree.escape-analysis.allocations

SYMBOL: escaping

! A map from values to sequences of values or 'escaping'
SYMBOL: allocations

: allocation ( value -- allocation )
    resolve-copy allocations get at ;

: record-allocation ( allocation value -- )
    allocations get set-at ;

: record-allocations ( allocations values -- )
    [ record-allocation ] 2each ;

: record-slot-access ( out slot# in -- )
    over zero? [ 3drop ] [ allocation ?nth swap is-copy-of ] if ;

! A map from values to sequences of values
SYMBOL: slot-merging

: merge-slots ( values -- value )
    <value> [ introduce-value ] [ slot-merging get set-at ] [ ] tri ;
