! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators compiler.cfg
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.intrinsics.simd.backend compiler.cfg.registers
compiler.cfg.rpo cpu.architecture kernel locals math namespaces
sequences sets vectors ;
IN: compiler.cfg.slp

! Automatic straight-line superword-level parallelism, not loop widening.
! No memory instruction, call, allocation, branch, or reduction is moved.
SYMBOLS: automatic-slp? slp-statistics ;
TUPLE: slp-tree pair opcode children ;

: slp-vector-op ( insn -- class/f )
    class-of {
        { ##add-float [ ##add-vector ] }
        { ##sub-float [ ##sub-vector ] }
        { ##mul-float [ ##mul-vector ] }
        [ drop f ]
    } case ;

: slp-arithmetic? ( insn -- ? ) slp-vector-op >boolean ;

: slp-region-insn? ( insn -- ? )
    dup slp-arithmetic? [ drop t ] [ ##load-reference? ] if ;

: slp-supported? ( -- ? )
    double-2-rep %gather-vector-2-reps member?
    double-2-rep %shuffle-vector-imm-reps member? and
    { ##add-vector ##sub-vector ##mul-vector }
    [ new double-2-rep >>rep insn-available? ] all? and ;

:: slp-expandable? ( pair definitions uses root? -- ? )
    pair [ definitions at ] map :> insns
    insns [ >boolean ] all? [
        insns [ slp-vector-op ] map first2 =
        root? pair [ uses at 1 = ] all? or and
        pair first2 = not and
    ] [ f ] if ;

:: make-slp-tree ( pair definitions uses root? -- tree )
    pair definitions uses root? slp-expandable? [
        pair [ definitions at ] map :> insns
        insns first slp-vector-op :> opcode
        insns [ src1>> ] map definitions uses f make-slp-tree
        insns [ src2>> ] map definitions uses f make-slp-tree 2array
        pair opcode rot slp-tree boa
    ] [ pair f { } slp-tree boa ] if ;

:: slp-tree-nodes ( tree -- nodes )
    tree children>> [ slp-tree-nodes ] map concat tree prefix ;

:: slp-profitable? ( tree -- ? )
    tree slp-tree-nodes :> nodes
    nodes [ opcode>> >boolean ] filter :> operations
    nodes [ opcode>> not ] filter [ pair>> ] map members :> leaves
    operations [ pair>> ] map concat :> removed
    ! Each gather costs up to two target instructions. Budget five for the
    ! two extracts and lane shuffle; count every arithmetic op, never FMA.
    operations length leaves length 2 * 5 + >
    leaves concat removed intersects? not and ;

:: emit-slp-tree ( tree emitted output -- vreg )
    tree pair>> emitted [| pair |
        next-vreg :> dst
        tree opcode>> [| opcode |
            tree children>> first emitted output emit-slp-tree
            tree children>> second emitted output emit-slp-tree :> ( a b )
            opcode new dst >>dst a >>src1 b >>src2 double-2-rep >>rep output push
        ] [
            dst pair first2 double-2-rep ##gather-vector-2 new-insn output push
        ] if*
        dst
    ] cache ;

:: emit-slp ( tree -- insns )
    V{ } clone :> output
    tree H{ } clone output emit-slp-tree :> packed
    tree pair>> first packed double-2-rep ##vector>scalar new-insn output push
    next-vreg :> high
    high packed { 1 1 } double-2-rep ##shuffle-vector-imm new-insn output push
    tree pair>> second high double-2-rep ##vector>scalar new-insn output push
    output ;

:: slp-root-pair? ( a b insns -- ? )
    a slp-arithmetic? b slp-arithmetic? and [
        a slp-vector-op b slp-vector-op =
        insns a swap index 1 + insns b swap index insns subseq
        [ uses-vregs a dst>> swap member? ] any? not and
    ] [ f ] if ;

:: find-slp-tree ( insns uses -- tree/f )
    H{ } clone :> definitions
    insns [ dup slp-arithmetic? [ dup dst>> definitions set-at ] [ drop ] if ] each
    ! Bound compile work and recursion for unusually large straight-line IR.
    definitions assoc-size 256 <= [
        insns reverse [| b |
            b insns index insns swap head reverse [| a |
                a b insns slp-root-pair? [
                    a dst>> b dst>> 2array definitions uses t make-slp-tree
                    dup slp-profitable? [ ] [ drop f ] if
                ] [ f ] if
            ] map-find drop
        ] map-find drop
    ] [ f ] if ;

:: vectorize-slp-region ( insns uses -- insns' )
    insns uses find-slp-tree [| tree |
        tree slp-tree-nodes [ opcode>> >boolean ] filter :> operations
        operations [ pair>> ] map concat :> removed
        tree pair>> second :> last-root
        tree emit-slp :> replacement
        "packs" slp-statistics get inc-at
        operations length "vector-operations" slp-statistics get [ 0 or + ] change-at
        insns [| insn |
            insn defs-vregs removed intersects? [
                insn defs-vregs last-root swap member? [ replacement ] [ { } ] if
            ] [ insn 1array ] if
        ] map concat
    ] [ insns ] if* ;

:: vectorize-slp-block ( insns uses -- insns' )
    V{ } clone :> result
    V{ } clone :> region
    insns [| insn |
        insn slp-region-insn? [ insn region push ] [
            region uses vectorize-slp-region result push-all
            region delete-all
            insn result push
        ] if
    ] each
    region uses vectorize-slp-region result push-all
    result ;

:: auto-vectorize ( cfg -- )
    automatic-slp? get [
        H{ { "packs" 0 } { "vector-operations" 0 } } clone slp-statistics namespaces:set
        slp-supported? [
            H{ } clone :> uses
            cfg post-order [ instructions>> [| insn |
                insn uses-vregs [ uses inc-at ] each
                insn gc-map-insn? [
                    insn gc-map>> [
                        [ gc-roots>> ]
                        [ derived-roots>> [ keys ] [ values ] bi append ] bi append
                        [ uses inc-at ] each
                    ] when*
                ] when
            ] each ] each
            cfg [ uses vectorize-slp-block ] simple-optimization
            cfg cfg-changed
        ] when
    ] when ;
