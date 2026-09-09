! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.linear-scan
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.numbering
compiler.cfg.register-allocation compiler.cfg.register-allocation.verifier
compiler.cfg.registers compiler.cfg.ssa.destruction compiler.cfg.utilities
compiler.codegen compiler.units cpu.architecture hashtables kernel layouts
locals make math math.libm math.order math.vectors namespaces sequences sets words ;
IN: compiler.cfg.register-allocation.validation

! The wrapper still enters the public dispatcher and its independent checker.
! The kernel is supplied explicitly so this vocabulary does not select or load
! another allocator and cannot conceal a fallback in a convenience function.
TUPLE: constrained-allocator delegate registers kernel ;
ERROR: invalid-validation-register-bank registers ;
ERROR: invalid-allocation-evidence key value ;
ERROR: outside-validation-register-bank location rep ;

:: check-validation-register-bank ( graph registers -- )
    graph admissible-registers :> available
    registers keys available keys set= [ ] [
        registers invalid-validation-register-bank
    ] if
    registers [| class bank |
        bank empty? not bank all-unique? and
        bank class available at subset? and
    ] assoc-all? [ ] [ registers invalid-validation-register-bank ] if ;

:: check-validation-location ( location rep registers -- )
    location spill-slot? [ ] [
        location rep reg-class-of registers at member? [ ] [
            location rep outside-validation-register-bank
        ] if
    ] if ;

:: check-validation-insn-bank ( insn expected registers -- )
    insn uses-vregs expected inputs>>
    [ rep>> registers check-validation-location ] 2each
    insn defs-vregs expected outputs>>
    [ rep>> registers check-validation-location ] 2each
    insn temp-vregs expected temps>> [| location operand |
        location spill-slot? [ insn invalid-allocation-temporary ] when
        location operand rep>> registers check-validation-location
    ] 2each ;

:: check-validation-allocated-bank ( graph registers snapshot -- )
    graph cfg>insns [| insn |
        insn snapshot instructions>> at [
            insn swap registers check-validation-insn-bank
        ] [
            insn {
                { [ dup ##copy? ] [
                    [ src>> ] [ dst>> ] [ rep>> ] tri :> ( source destination rep )
                    source rep registers check-validation-location
                    destination rep registers check-validation-location
                ] }
                { [ dup ##spill? ] [
                    [ src>> ] [ rep>> ] bi registers check-validation-location
                ] }
                { [ dup ##reload? ] [
                    [ dst>> ] [ rep>> ] bi registers check-validation-location
                ] }
                { [ dup ##load-reference? ] [
                    dst>> tagged-rep registers check-validation-location
                ] }
                [ drop ]
            } cond
        ] if*
    ] each ;

M:: constrained-allocator allocate-cfg ( graph allocator -- )
    allocator registers>> :> registers
    graph registers check-validation-register-bank
    active-value-flow-snapshot get :> snapshot
    snapshot [ ] [ "active-value-flow-snapshot" f invalid-allocation-evidence ] if
    graph registers allocator kernel>> call( cfg registers -- )
    graph registers snapshot check-validation-allocated-bank ;

M: constrained-allocator allocator-statistics
    delegate>> allocator-statistics ;

:: validation-register-bank ( graph integer-count float-count -- registers )
    graph admissible-registers [| class bank |
        class bank class int-regs eq? integer-count float-count ?
        bank length min head
    ] assoc-map ;

: linear-scan-allocation-with-registers ( graph registers -- )
    [ dup destruct-ssa ] dip linear-scan-with-registers ;

! A feature's evidence is collected over a corpus, not required from every
! graph. Counters do not prove an algorithm: the independent flow and native
! oracles establish behavior, and implementation review establishes policy.
:: check-allocation-evidence ( statistics algorithm features -- )
    "algorithm" statistics at algorithm = [ ] [
        "algorithm" "algorithm" statistics at invalid-allocation-evidence
    ] if
    "fallback-count" statistics at 0 = [ ] [
        "fallback-count" "fallback-count" statistics at invalid-allocation-evidence
    ] if
    features [| feature |
        feature statistics at :> value
        value number? [ value 0 > ] [ f ] if [ ] [
            feature value invalid-allocation-evidence
        ] if
    ] each ;

: init-validation-representations ( -- )
    H{ } clone representations namespaces:set
    256 <iota> [ int-rep swap set-rep-of ] each
    tagged-rep 0 set-rep-of
    256 vreg-counter namespaces:set ;

:: emit-validation-sum ( values -- result )
    values first :> result!
    values rest [| value i |
        150 i + dup result value ##add, result!
    ] each-index
    result ;

! Definitions depend on an unknown runtime input, so enabling integer
! rematerialization cannot erase this register-pressure obligation.
:: <validation-diamond> ( width seed -- graph )
    init-validation-representations
    [
        ##prologue,
        0 D: 0 ##peek, 1 0 ##tagged>integer,
        width <iota> [| i |
            10 i + 1 seed 1 + i 1 + * tag-fixnum ##add-imm,
        ] each
        1 0 cc> ##compare-integer-imm-branch,
    ] { } make 0 insns>block :> entry
    [
        width <iota> [| i |
            40 i + 10 i + seed 3 + i 1 + * tag-fixnum ##add-imm,
        ] each
        ##branch,
    ] { } make 1 insns>block :> left
    [
        width <iota> [| i |
            70 i + 10 i + seed 2 + i 1 + * tag-fixnum ##sub-imm,
        ] each
        ##branch,
    ] { } make 2 insns>block :> right
    [
        width <iota> [| i |
            100 i + left 40 i + 2array right 70 i + 2array 2array ##phi,
        ] each
        width <iota> [ 100 + ] map emit-validation-sum D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make 3 insns>block :> join
    entry left connect-bbs entry right connect-bbs
    left join connect-bbs right join connect-bbs
    entry block>cfg ;

:: validation-diamond-result ( input width seed -- result )
    width input *
    width width 1 + * 2 /i
    input 0 > [ seed 2 * 4 + ] [ -1 ] if * + ;

! The three loop phis rotate simultaneously. Sequential edge assignments
! produce a different weighted answer after one and two iterations.
:: <validation-cycle> ( seed collect? -- graph )
    init-validation-representations
    [
        ##prologue,
        0 D: 0 ##peek, 1 0 ##tagged>integer,
        2 seed 1 + tag-fixnum ##load-integer,
        3 seed 3 + tag-fixnum ##load-integer,
        4 seed 7 + tag-fixnum ##load-integer,
        ##branch,
    ] { } make 0 insns>block :> entry
    <basic-block> :> header
    [
        collect? [
            200 201 ##save-context,
            V{ } clone H{ } clone gc-map boa ##call-gc,
        ] when
        21 20 1 tag-fixnum ##sub-imm,
        ##branch,
    ] { } make 2 insns>block :> body
    [
        30 11 2 ##mul-imm,
        31 12 4 ##mul-imm,
        32 10 30 ##add,
        33 32 31 ##add,
        33 D: 0 ##replace, ##epilogue, ##return,
    ] { } make 3 insns>block :> done
    [
        10 H{ { entry 2 } { body 11 } } ##phi,
        11 H{ { entry 3 } { body 12 } } ##phi,
        12 H{ { entry 4 } { body 10 } } ##phi,
        20 H{ { entry 1 } { body 21 } } ##phi,
        20 0 cc> ##compare-integer-imm-branch,
    ] V{ } make header instructions<<
    entry header connect-bbs
    header body connect-bbs header done connect-bbs
    body header connect-bbs
    entry block>cfg ;

:: validation-cycle-result ( iterations seed -- result )
    seed 1 + :> a!
    seed 3 + :> b!
    seed 7 + :> c!
    iterations [ b c a c! b! a! ] times
    a b 2 * + c 4 * + ;

:: compile-validation-cfg ( graph allocator -- word )
    graph cfg namespaces:set
    allocator register-allocator namespaces:set
    t check-allocation? namespaces:set
    t check-numbering? namespaces:set
    value-flow-verifier-enabled? [ ] [
        "value-flow-verifier" f invalid-allocation-evidence
    ] if
    graph allocate-registers
    graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;

! Five independent vectors remain live across a native ABI call. Their bank
! aliases the scalar result's bank; preserving only scalar spill width loses
! lanes. Keep this program inline so a typed test quotation allocates it as
! one CFG, and compare with the separate scalar lane formula below.
:: validation-vector-program ( a b x -- result )
    a b v+ :> sum
    a b v- :> difference
    a b v* :> product
    a a v* :> square-a
    b b v* :> square-b
    x fsin :> scalar
    sum difference v+ product v+ square-a v+
    square-b scalar v*n v+ ; inline

:: validation-vector-lane ( a b x -- result )
    a 2 * a b * + a a * + b b * x fsin * + ;
