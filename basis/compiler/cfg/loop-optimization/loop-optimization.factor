! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.dominance compiler.cfg.instructions compiler.cfg.loop-detection
compiler.cfg.predecessors compiler.cfg.registers compiler.cfg.rpo
compiler.cfg.utilities grouping hashtables.identity kernel locals math namespaces
sequences sets sorting vectors ;
IN: compiler.cfg.loop-optimization

! This pass runs on SSA, before representation selection and GC insertion.
! Only these cell operations are safe to execute even on a zero-trip path.
! In particular, foldable-insn is NOT a speculation/effect contract.
UNION: loop-speculatable-insn
    ##add ##add-imm ##sub ##sub-imm ##mul ##mul-imm ##mneg
    ##and ##and-imm ##or ##or-imm ##xor ##xor-imm
    ##shl ##shl-imm ##shr ##shr-imm ##sar ##sar-imm
    ##min ##max ##neg ##not
    ##compare-integer ##compare-integer-imm ##test ##test-imm ;

UNION: loop-call-barrier-insn
    alien-call-insn ##call ##callback-inputs ##callback-outputs
    ##unbox ##unbox-long-long ;

SYMBOL: loop-optimization?
SYMBOL: loop-optimization-statistics

: count-loop-event ( key -- ) loop-optimization-statistics get inc-at ;

: loop-motion-barrier? ( insn -- ? )
    dup gc-map-insn? [ drop t ] [
        dup loop-call-barrier-insn? [ drop t ] [
            dup allocation-insn? [ drop t ] [ ##call? ] if
        ] if
    ] if ;

:: supported-loop? ( loop -- ? )
    loop blocks>> members [| bb |
        bb kill-block?>> not
        loop header>> bb dominates? and
        bb instructions>> [ loop-motion-barrier? ] any? not and
    ] all? ;

:: loop-entering-blocks ( loop -- blocks )
    loop header>> predecessors>>
    [ loop blocks>> in? not ] filter ;

:: invariant-loop-use? ( vreg loop selected -- ? )
    vreg selected in? [ t ] [
        vreg def-of :> defining
        defining [
            defining loop blocks>> in? not
            defining loop header>> dominates? and
        ] [ f ] if
    ] if ;

:: loop-hoist-candidates ( cfg loop -- insns )
    HS{ } clone :> selected
    V{ } clone :> result
    ! SSA definitions dominate their uses. RPO and instruction order therefore
    ! visit every movable dependency first; phis never enter this set.
    cfg reverse-post-order [| bb |
        bb loop blocks>> in? [
            bb instructions>> [| insn |
                insn loop-speculatable-insn? [
                    insn uses-vregs [ loop selected invariant-loop-use? ] all? [
                        insn result push
                        insn defs-vregs [ selected adjoin ] each
                    ] when
                ] when
            ] each
        ] when
    ] each result ;

:: merge-entry-phi ( phi entering preheader -- )
    phi inputs>> [ entering member-eq? ] filter-keys :> incoming
    incoming values all-equal? [ incoming values first ] [
        next-vreg :> fresh
        fresh incoming ##phi new-insn preheader instructions>> push
        fresh
    ] if :> value
    phi inputs>> [ entering member-eq? not ] filter-keys H{ } assoc-clone-like :> remaining
    value preheader remaining set-at
    remaining phi inputs<< ;

:: create-loop-preheader ( loop entering -- preheader )
    <basic-block> :> preheader
    loop header>> :> header
    header [ entering preheader merge-entry-phi ] each-phi
    ##branch new-insn preheader instructions>> push
    V{ header } preheader successors<<
    entering V{ } like preheader predecessors<<
    entering [| pred | pred header preheader update-successors ] each
    header predecessors>> [ entering member-eq? not ] filter
    preheader suffix! header predecessors<<
    "preheaders" count-loop-event
    preheader ;

:: loop-preheader ( loop entering -- preheader )
    entering length 1 = [
        entering first :> pred
        pred successors>> length 1 = pred kill-block?>> not and [
            pred
        ] [ loop entering create-loop-preheader ] if
    ] [ loop entering create-loop-preheader ] if ;

:: move-loop-instructions ( cfg loop chosen preheader -- )
    IH{ } clone :> moved
    chosen [ t swap moved set-at ] each
    loop blocks>> members [| bb |
        bb instructions>> [ moved key? not ] filter bb instructions<<
    ] each
    preheader instructions>> :> destination
    destination pop :> terminator
    chosen destination push-all
    terminator destination push
    chosen length "hoisted" loop-optimization-statistics get at 0 or +
    "hoisted" loop-optimization-statistics get set-at
    cfg cfg-changed cfg predecessors-changed ;

:: optimize-one-loop ( cfg header -- )
    cfg needs-loops cfg needs-dominance cfg compute-defs
    header loops get at :> loop
    loop [
        loop supported-loop? [
            loop loop-entering-blocks :> entering
            entering empty? [ ] [
                cfg loop loop-hoist-candidates :> chosen
                chosen empty? [ ] [
                    loop entering loop-preheader :> preheader
                    cfg loop chosen preheader move-loop-instructions
                    "productive-loops" count-loop-event
                ] if
            ] if
        ] when
    ] when ;

: perform-loop-optimization ( cfg -- )
    H{ } clone loop-optimization-statistics namespaces:set
    dup needs-loops
    loops get values [ blocks>> cardinality ] sort-by [ header>> ] map
    [ optimize-one-loop ] with each ;

: optimize-loops ( cfg -- )
    loop-optimization? get [ perform-loop-optimization ] [ drop ] if ;
