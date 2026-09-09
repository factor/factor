USING: accessors arrays assocs compiler.cfg compiler.cfg.checker
compiler.cfg.comparisons compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.loop-optimization compiler.cfg.linearization compiler.cfg.registers compiler.cfg.rpo
compiler.cfg.utilities compiler.cfg.register-allocation
compiler.cfg.register-allocation.validation compiler.test cpu.architecture
kernel layouts locals make math math.order math.bitwise namespaces sequences sets
sorting tools.test vectors ;
IN: compiler.cfg.loop-optimization.tests

! Runtime stack: ( x y n -- x y sum ). XOR preserves fixnum tag bits;
! each body adds the invariant xor to the accumulator.
:: <licm-loop> ( multiple? -- graph )
    init-validation-representations
    [
        ##prologue,
        0 D: 2 ##peek, 1 D: 1 ##peek, 2 D: 0 ##peek,
        3 2 int-rep ##copy,
        4 0 ##load-integer,
        multiple? [ 3 0 cc< ##compare-integer-imm-branch, ] [ ##branch, ] if
    ] { } make 0 insns>block :> entry
    [ 5 1 tag-fixnum ##load-integer, ##branch, ] { } make 1 insns>block :> left
    [ 6 2 tag-fixnum ##load-integer, ##branch, ] { } make 2 insns>block :> right
    <basic-block> :> header
    [
        20 0 1 ##xor,
        21 20 3 ##mul-imm,
        12 11 21 ##add,
        13 10 1 tag-fixnum ##sub-imm,
        ##branch,
    ] { } make 4 insns>block :> body
    [ 11 D: 0 ##replace, ##epilogue, ##return, ] { } make 5 insns>block :> done
    multiple? [ H{ { left 3 } { right 3 } { body 13 } }
                H{ { left 5 } { right 6 } { body 12 } } ]
              [ H{ { entry 3 } { body 13 } }
                H{ { entry 4 } { body 12 } } ] if :> ( trips sums )
    [
        10 trips ##phi, 11 sums ##phi,
        10 0 cc> ##compare-integer-imm-branch,
    ] V{ } make header instructions<<
    multiple? [
        entry left connect-bbs entry right connect-bbs
        left header connect-bbs right header connect-bbs
    ] [ entry header connect-bbs ] if
    header body connect-bbs header done connect-bbs body header connect-bbs
    entry block>cfg ;

: checked-licm ( graph -- graph )
    dup check-ssa dup perform-loop-optimization dup check-ssa ;

{ 2 0 } [
    f <licm-loop> checked-licm drop
    "hoisted" loop-optimization-statistics get at
    "preheaders" loop-optimization-statistics get at 0 or
] unit-test

! Distinct incoming accumulator values require a new preheader phi; equal
! incoming trip counts do not. Header inputs retain every original backedge.
{ 2 1 3 } [
    t <licm-loop> checked-licm
    cfg>insns [ ##phi? ] count
    "hoisted" loop-optimization-statistics get at
    "preheaders" loop-optimization-statistics get at rot
] unit-test

! The flag defaults to a true no-op, including no preheader creation.
{ t } [
    f <licm-loop> dup cfg>insns clone
    [ dup f loop-optimization? [ optimize-loops ] with-variable ] dip
    swap cfg>insns =
] unit-test

! A dependency on the changing induction phi cannot move.
{ 0 } [
    f <licm-loop> dup cfg>insns [ ##xor? ] find nip
    10 >>src1 drop
    checked-licm drop
    "hoisted" loop-optimization-statistics get at 0 or
] unit-test

! GC/call/allocation barriers disqualify the entire loop, not merely nearby
! operations; this avoids extending derived pointers across a safepoint.
{ 0 } [
    f <licm-loop> dup reverse-post-order [ instructions>> [ ##xor? ] any? ] find nip
    instructions>> <gc-map> ##call-gc new-insn swap push
    checked-licm drop
    "hoisted" loop-optimization-statistics get at 0 or
] unit-test

{ t } [
    {
        T{ ##add-float } T{ ##div-float } T{ ##slot } T{ ##slot-imm }
        T{ ##tagged>integer } T{ ##unbox-alien } T{ ##fixnum-add }
        T{ ##load-reference } T{ ##alien-invoke } T{ ##call-gc }
    } [ loop-speculatable-insn? not ] all?
] unit-test

! Independent native arithmetic oracle: zero, one and multiple iterations,
! positive/negative operands, both external entries, and both preheader forms.
:: execute-licm-case ( multiple? enabled? -- ? )
    multiple? <licm-loop> :> graph
    enabled? [ graph checked-licm drop ] when
    ! Production runs this pass before representation selection. These already
    ! represented synthetic graphs need representations for newly merged phis.
    graph cfg>insns [ defs-vregs [
        dup representations get key? [ drop ] [ int-rep swap set-rep-of ] if
    ] each ] each
    graph linear-scan-allocator compile-validation-cfg :> word
    { -7 -1 0 1 4 19 } [| n |
        { -11 0 7 } [| x |
            { -3 2 13 } [| y |
                x y n word execute( x y n -- x y result ) :> ( x' y' result )
                x x' = y y' = and
                x y bitxor 3 * n 0 max *
                multiple? [ n 0 < 1 2 ? + ] when result = and
            ] all?
        ] all?
    ] all? ;

{ t } [
    { f t } [| multiple? |
        { f t } [ multiple? swap execute-licm-case ] all?
    ] all?
] unit-test

! An entry edge into the latch creates an irreducible cycle. Its latch uses
! only entry values, so the input SSA is valid; header dominance must reject
! the apparent natural-loop candidate instead of creating a preheader.
:: test-irreducible-loop ( -- hoisted )
    f <licm-loop> :> graph
    graph reverse-post-order [ instructions>> [ ##xor? ] any? ] find nip :> body
    body instructions>> [| insn |
        insn ##add? [ 4 insn src1<< ] when
        insn ##sub-imm? [ 3 insn src1<< ] when
    ] each
    graph entry>> body connect-bbs
    graph cfg-changed graph predecessors-changed
    graph checked-licm drop
    "hoisted" loop-optimization-statistics get at 0 or
;

{ 0 } [ test-irreducible-loop ] unit-test


! No explicit collection is necessary to trigger the guard: later
! representation selection may add boxing/GC. Preserve the raw-pointer xor
! and multiply chain in its original loop even when the seed is outside it.
:: pointer-seed-loop-unchanged? ( seed-class -- ? )
    f <licm-loop> :> graph
    seed-class new 254 >>dst 0 >>src :> seed
    graph entry>> instructions>> :> entry-insns
    entry-insns pop :> terminator
    seed entry-insns push terminator entry-insns push
    graph cfg>insns [ ##xor? ] find nip 254 >>src1 drop
    graph cfg>insns clone :> original
    graph checked-licm drop
    original graph cfg>insns =
    "hoisted" loop-optimization-statistics get at 0 or zero? and
    "pointer-seed-cfgs" loop-optimization-statistics get at 1 = and ;

{ t } [
    { ##tagged>integer ##unbox-any-c-ptr }
    [ pointer-seed-loop-unchanged? ] all?
] unit-test
