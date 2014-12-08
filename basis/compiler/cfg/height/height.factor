! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors math namespaces sequences kernel fry
compiler.cfg compiler.cfg.registers compiler.cfg.instructions
compiler.cfg.rpo ;
IN: compiler.cfg.height

! Combine multiple stack height changes into one at the
! start of the basic block.

SYMBOL: ds-height
SYMBOL: rs-height

: init-height ( -- )
    0 ds-height set
    0 rs-height set ;

GENERIC: visit-insn ( insn -- )

: normalize-inc-d/r ( insn stack -- )
    swap n>> '[ _ + ] change ; inline

M: ##inc-d visit-insn ds-height normalize-inc-d/r ;
M: ##inc-r visit-insn rs-height normalize-inc-d/r ;

GENERIC: loc-stack ( loc -- stack )

M: ds-loc loc-stack drop ds-height ;
M: rs-loc loc-stack drop rs-height ;

GENERIC: <loc> ( n stack -- loc )

M: ds-loc <loc> drop <ds-loc> ;
M: rs-loc <loc> drop <rs-loc> ;

: normalize-peek/replace ( insn -- )
    [ [ [ n>> ] [ loc-stack get ] bi + ] keep <loc> ] change-loc
    drop ; inline

M: ##peek visit-insn normalize-peek/replace ;
M: ##replace visit-insn normalize-peek/replace ;

M: insn visit-insn drop ;

: height-step ( insns -- insns' )
    init-height
    [ <reversed> [ visit-insn ] each ]
    [
        [ [ ##inc-d? ] [ ##inc-r? ] bi or not ] filter!
        ds-height get [ ##inc-d new-insn prefix ] unless-zero
        rs-height get [ ##inc-r new-insn prefix ] unless-zero
    ] bi ;

: normalize-height ( cfg -- )
    [ height-step ] simple-optimization ;
