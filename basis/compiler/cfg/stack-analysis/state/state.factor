! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sets math ;
IN: compiler.cfg.stack-analysis.state

TUPLE: state
locs>vregs actual-locs>vregs changed-locs
ds-height rs-height poisoned? ;

: <state> ( -- state )
    state new
        H{ } clone >>locs>vregs
        H{ } clone >>actual-locs>vregs
        H{ } clone >>changed-locs
        0 >>ds-height
        0 >>rs-height ;

M: state clone
    call-next-method
        [ clone ] change-locs>vregs
        [ clone ] change-actual-locs>vregs
        [ clone ] change-changed-locs ;

: loc>vreg ( loc -- vreg ) state get locs>vregs>> at ;

: record-peek ( dst loc -- )
    state get [ locs>vregs>> set-at ] [ actual-locs>vregs>> set-at ] 3bi ;

: changed-loc ( loc -- )
    state get changed-locs>> conjoin ;

: record-replace ( src loc -- )
    dup changed-loc state get locs>vregs>> set-at ;

: clear-state ( state -- )
    [ locs>vregs>> clear-assoc ]
    [ actual-locs>vregs>> clear-assoc ]
    [ changed-locs>> clear-assoc ]
    tri ;

: adjust-ds ( n -- ) state get [ + ] change-ds-height drop ;

: adjust-rs ( n -- ) state get [ + ] change-rs-height drop ;
