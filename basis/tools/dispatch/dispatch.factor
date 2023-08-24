! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces prettyprint classes.struct
vm tools.dispatch.private ;
IN: tools.dispatch

<PRIVATE
PRIMITIVE: dispatch-stats ( -- stats )
PRIMITIVE: reset-dispatch-stats ( -- )
PRIVATE>

SYMBOL: last-dispatch-stats

: dispatch-stats. ( -- )
    last-dispatch-stats get {
        { "Megamorphic hits" [ megamorphic-cache-hits>> ] }
        { "Megamorphic misses" [ megamorphic-cache-misses>> ] }
        { "Cold to monomorphic" [ cold-call-to-ic-transitions>> ] }
        { "Mono to polymorphic" [ ic-to-pic-transitions>> ] }
        { "Poly to megamorphic" [ pic-to-mega-transitions>> ] }
        { "Tag check count" [ pic-tag-count>> ] }
        { "Tuple check count" [ pic-tuple-count>> ] }
    } object-table. ;

: collect-dispatch-stats ( quot -- dispatch-statistics )
    reset-dispatch-stats
    call
    dispatch-stats dispatch-statistics memory>struct ; inline
