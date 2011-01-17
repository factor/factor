! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs cpu.architecture compiler.cfg.registers
compiler.cfg.instructions deques dlists fry kernel locals namespaces
sequences hashtables ;
IN: compiler.cfg.parallel-copy

! Revisiting Out-of-SSA Translation for Correctness, Code Quality, and Efficiency
! http://hal.archives-ouvertes.fr/docs/00/34/99/25/PDF/OutSSA-RR.pdf,
! Algorithm 1

<PRIVATE

SYMBOLS: locs preds to-do ready ;

: init-to-do ( bs -- )
    to-do get push-all-back ;

: init-ready ( bs -- )
    locs get '[ _ key? not ] filter ready get push-all-front ;

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
    ! Note that we check if b = loc(b), not b = loc(pred(b)) as the
    ! paper suggests. Confirmed by one of the authors at
    ! http://www.reddit.com/comments/93253/some_lecture_notes_on_ssa_form/c0bco4f
    b locs get at b = [
        b temp call :> temp
        temp b quot call
        temp b locs get set-at
        b ready get push-front
    ] when ; inline

PRIVATE>

:: parallel-mapping ( mapping temp: ( src -- dst ) quot: ( dst src -- ) -- )
    ! mapping is a list of { dst src } pairs
    [
        mapping init
        to-do get [
            ready get [
                quot process-ready
            ] slurp-deque
            temp quot process-to-do
        ] slurp-deque
    ] with-scope ; inline

: parallel-copy ( mapping -- )
    ! mapping is a list of { dst src } pairs
    next-vreg '[ drop _ ] [ any-rep ##copy ] parallel-mapping ;

<PRIVATE

SYMBOL: temp-vregs

: temp-vreg ( rep -- vreg )
    temp-vregs get [ next-vreg-rep ] cache ;

PRIVATE>

: parallel-copy-rep ( mapping -- )
    ! mapping is a list of { dst src } pairs
    H{ } clone temp-vregs set
    [ rep-of temp-vreg ] [ dup rep-of ##copy ] parallel-mapping ;
