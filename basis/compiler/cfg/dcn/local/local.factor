! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel make namespaces sequences math
compiler.cfg.rpo compiler.cfg.registers compiler.cfg.instructions
compiler.cfg.dcn.height ;
IN: compiler.cfg.dcn.local

<PRIVATE

SYMBOL: copies

: record-copy ( dst src -- ) swap copies get set-at ;

: resolve-copy ( vreg -- vreg' ) copies get ?at drop ;

SYMBOLS: reads-locations writes-locations ;

: loc>vreg ( loc -- vreg )
    dup writes-locations get at
    [ ] [ reads-locations get at ] ?if ;

SYMBOL: ds-height

SYMBOL: rs-height

GENERIC: translate-loc ( loc -- loc' )

M: ds-loc translate-loc n>> ds-height get - <ds-loc> ;

M: rs-loc translate-loc n>> rs-height get - <rs-loc> ;

GENERIC: visit ( insn -- )

M: insn visit , ;

M: ##inc-d visit n>> ds-height [ + ] change ;

M: ##inc-r visit n>> rs-height [ + ] change ;

M: ##peek visit
    ! If location is in a register already, copy existing
    ! register to destination. Otherwise, associate the
    ! location with the register.
    [ dst>> ] [ loc>> translate-loc ] bi dup loc>vreg
    [ [ record-copy ] [ ##copy ] 2bi ]
    [ reads-locations get set-at ]
    ?if ;

M: ##replace visit
    ! If location already contains the same value, do nothing.
    ! Otherwise, associate the location with the register.
    [ src>> resolve-copy ] [ loc>> translate-loc ] bi 2dup loc>vreg =
    [ 2drop ] [ writes-locations get set-at ] if ;

M: ##copy visit
    ! Not needed at this point because IR doesn't have ##copy
    ! on input to dcn pass, but in the future it might.
    [ dst>> ] [ src>> resolve-copy ] bi record-copy ;

: insert-height-changes ( -- )
    ds-height get dup 0 = [ drop ] [ ##inc-d ] if
    rs-height get dup 0 = [ drop ] [ ##inc-r ] if ;

: local-analysis ( bb -- )
    ! Removes all ##peek and ##replace from the basic block.
    ! Conceptually, moves all ##peeks to the start
    ! (reads-locations assoc) and all ##replaces to the end
    ! (writes-locations assoc).
    0 ds-height set
    0 rs-height set
    H{ } clone copies set
    H{ } clone reads-locations set
    H{ } clone writes-locations set
    [
        [
            [ visit ] each
            insert-height-changes
        ] V{ } make
    ] change-instructions drop ;

SYMBOLS: peeks replaces ;

: visit-block ( bb -- )
    [ local-analysis ]
    [ [ reads-locations get ] dip [ translate-in-set ] keep peeks get set-at ]
    [ [ writes-locations get ] dip [ translate-in-set ] keep replaces get set-at ]
    tri ;

PRIVATE>

: peek ( bb -- assoc ) peeks get at ;
: replace ( bb -- assoc ) replaces get at ;

: compute-local-sets ( cfg -- )
    H{ } clone peeks set
    H{ } clone replaces set
    [ visit-block ] each-basic-block ;