! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sets math
compiler.cfg.registers ;
IN: compiler.cfg.stack-analysis.state

TUPLE: state
locs>vregs actual-locs>vregs changed-locs
{ ds-height integer }
{ rs-height integer }
poisoned? ;

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
    0 >>ds-height 0 >>rs-height
    [ locs>vregs>> ] [ actual-locs>vregs>> ] [ changed-locs>> ] tri
    [ clear-assoc ] tri@ ;

GENERIC# translate-loc 1 ( loc state -- loc' )
M: ds-loc translate-loc [ n>> ] [ ds-height>> ] bi* - <ds-loc> ;
M: rs-loc translate-loc [ n>> ] [ rs-height>> ] bi* - <rs-loc> ;

GENERIC# untranslate-loc 1 ( loc state -- loc' )
M: ds-loc untranslate-loc [ n>> ] [ ds-height>> ] bi* + <ds-loc> ;
M: rs-loc untranslate-loc [ n>> ] [ rs-height>> ] bi* + <rs-loc> ;
