! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.utilities
cpu.architecture deques dlists kernel make namespaces sequences ;
IN: compiler.cfg.parallel-copy

<PRIVATE

SYMBOLS: locs preds to-do ready ;

: init-to-do ( bs -- )
    to-do get push-all-back ;

: init-ready ( bs -- )
    locs get '[ _ key? ] reject ready get push-all-front ;

: init ( mapping -- )
    <dlist> to-do set
    <dlist> ready set
    [ preds set ]
    [ [ nip dup ] H{ } assoc-map-as locs set ]
    [ keys [ init-to-do ] [ init-ready ] bi ] tri ;

:: process-ready ( b quot: ( dst src -- ) -- )
    b preds get at :> a
    a locs get at :> c
    b c quot call
    b a locs get set-at
    a c = a preds get at and [ a ready get push-front ] when ; inline

:: process-to-do ( b temp: ( src -- dst ) quot: ( dst src -- ) -- )
    b locs get at b = [
        b temp call :> temp
        temp b quot call
        temp b locs get set-at
        b ready get push-front
    ] when ; inline

PRIVATE>

:: parallel-mapping ( mapping temp: ( src -- dst ) quot: ( dst src -- ) -- )
    [
        mapping init
        to-do get [
            ready get [
                quot process-ready
            ] slurp-deque
            temp quot process-to-do
        ] slurp-deque
    ] with-scope ; inline

: parallel-copy ( mapping -- insns )
    [ next-vreg '[ drop _ ] [ any-rep ##copy, ] parallel-mapping ] { } make ;

<PRIVATE

SYMBOL: temp-vregs

: temp-vreg ( rep -- vreg )
    temp-vregs get [ next-vreg-rep ] cache
    [ leader-map get conjoin ] keep ;

PRIVATE>

: parallel-copy-rep ( mapping -- insns )
    [
        H{ } clone temp-vregs set
        [ rep-of temp-vreg ] [ dup rep-of ##copy, ] parallel-mapping
    ] { } make ;
