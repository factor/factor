USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.resolve compiler.cfg.linearization
compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities
compiler.codegen compiler.test compiler.units cpu.architecture hashtables
kernel layouts locals make math
math.private memory namespaces sequences tools.test words ;
IN: compiler.cfg.register-allocation.rematerialization.tests

{ { f t t t t f f f } } [
    { -32769 -32768 -1 0 32767 32768 1.0 f } [ cheap-integer? ] map
] unit-test

: init-remat-test ( -- )
    H{ { 1 int-rep } { 2 int-rep } { 3 tagged-rep }
        { 4 double-rep } { 5 int-rep } } clone representations set
    H{ { 1 1 } { 2 2 } { 3 3 } { 4 4 } { 5 5 } } clone leader-map set
    t rematerialize-constants? set
    H{ { "loads" 0 } } clone rematerialization-statistics set ;

: recipe-keys ( insns -- keys )
    insns>cfg prepare-rematerialization rematerialization-recipes get keys ;

! Only inexpensive integer bits qualify. Tagged references, floats, and
! multi-instruction wide integers keep their normal relocation semantics.
{ { 1 } } [ [
    init-remat-test
    {
        T{ ##load-integer { dst 1 } { val 17 } }
        T{ ##load-integer { dst 2 } { val 0x123456789ABCDEF } }
        T{ ##load-reference { dst 3 } { obj "root" } }
        T{ ##load-double { dst 4 } { val -0.0 } }
        T{ ##load-double { dst 4 } { val 0/0. } }
        T{ ##load-tagged { dst 3 } { val 17 } }
        T{ ##branch }
    } recipe-keys
] with-scope ] unit-test

! Two original SSA definitions merged to one leader are deliberately not
! a value proof, even when the two constants happen to have equal bits.
{ { } } [ [
    init-remat-test 1 2 leader-map get set-at
    {
        T{ ##load-integer { dst 1 } { val 17 } }
        T{ ##load-integer { dst 2 } { val 17 } }
        T{ ##branch }
    } recipe-keys
] with-scope ] unit-test

! ABI-required stack operands and derived/root metadata must retain slots.
{ { } } [ [
    init-remat-test
    {
        T{ ##load-integer { dst 1 } { val 17 } }
        T{ ##load-integer { dst 2 } { val 18 } }
        T{ ##box { dst 3 } { src 1 } { rep int-rep }
            { gc-map T{ gc-map { gc-roots V{ } } { derived-roots H{ } } } } }
        T{ ##call-gc { gc-map T{ gc-map
            { gc-roots V{ } } { derived-roots H{ { 5 2 } } } } } }
        T{ ##branch }
    } recipe-keys
] with-scope ] unit-test

! A numerically cheap integer explicitly listed as a GC root is not a
! storage-free recipe. Its address-like interpretation belongs to the map.
{ { } } [ [
    init-remat-test
    {
        T{ ##load-integer { dst 1 } { val 17 } }
        T{ ##call-gc { gc-map T{ gc-map
            { gc-roots V{ 1 } } { derived-roots H{ } } } } }
        T{ ##branch }
    } recipe-keys
] with-scope ] unit-test

! Per-CFG preparation must discard recipes and statistics when disabled;
! toggling an image-global option must not reuse a previous CFG's value.
{ t f f f } [ [
    init-remat-test
    { T{ ##load-integer { dst 1 } { val 17 } } T{ ##branch } }
    insns>cfg dup prepare-rematerialization
    1 rematerialization-of constant-recipe? swap
    f rematerialize-constants? set prepare-rematerialization
    rematerialization-recipes get rematerialization-statistics get
    1 rematerialization-of
] with-scope ] unit-test

{ { } } [ [
    init-remat-test
    {
        T{ ##load-integer { dst 1 } { val 17 } }
        T{ ##phi { dst 2 } { inputs H{ { f 1 } } } }
        T{ ##branch }
    } recipe-keys
] with-scope ] unit-test

: test-recipe ( -- recipe )
    1 17 T{ ##load-integer { dst 1 } { val 17 } } constant-recipe boa ;

{ f t 0 } [ [
    init-remat-test
    H{ } clone [ test-recipe 1 rot set-at ] keep rematerialization-recipes set
    H{ } clone spill-slots set
    1 <live-interval>
        V{ T{ vreg-use { n 0 } { def-rep int-rep } }
            T{ vreg-use { n 4 } { use-rep int-rep } } } >>uses
        V{ { 0 4 } } >>ranges
    2 split-for-spill
    [ spill-to>> ] [ reload-from>> constant-recipe? ] bi*
    spill-slots get assoc-size
] with-scope ] unit-test

! Edge mappings can load a recipe while shuffling unrelated registers.
{ t t } [ [
    init-remat-test
    [ test-recipe 0 int-rep add-mapping 0 1 int-rep add-mapping ] { } make
    mapping-instructions
    [ [ ##load-integer? ] count 1 = ] [ [ ##copy? ] count 1 = ] bi
] with-scope ] unit-test

{ { } } [
    [ 0 test-recipe int-rep add-mapping ] { } make
] unit-test

! Forty simultaneously live constants exceed the native integer register
! file. This runs the real SSA allocator, spill insertion and edge resolver.
: init-pressure-representations ( -- )
    H{ } clone representations set
    200 <iota> [ int-rep swap set-rep-of ] each
    200 vreg-counter set ;

: emit-pressure-constants ( -- )
    40 <iota> [ dup 1 + tag-fixnum ##load-integer, ] each ;

:: emit-pressure-sum ( base -- result )
    base 0 1 ##add,
    38 <iota> [| i | i base + 1 + i base + i 2 + ##add, ] each
    base 38 + ;

:: <constant-pressure-cfg> ( -- cfg )
    init-pressure-representations
    [
        ##prologue,
        emit-pressure-constants
        40 emit-pressure-sum D: 0 ##replace,
        ##epilogue,
        ##return,
    ] { } make insns>cfg ;

! Include MOVN/sign-extension cases under actual pressure. Values are
! tagged fixnum bits so the machine result remains an ordinary Factor
! integer: ten repetitions of (-2048 -1 0 2047) sum to -20.
: <signed-constant-pressure-cfg> ( -- cfg )
    <constant-pressure-cfg> dup cfg>insns
    [ ##load-integer? ] filter
    [ dup dst>> 4 mod { -32768 -16 0 32752 } nth >>val drop ] each ;

:: pressure-metrics ( allocator enabled? -- metrics )
    [
        enabled? rematerialize-constants? set
        allocator register-allocator set
        t check-allocation? set
        <constant-pressure-cfg> :> graph
        graph cfg set
        graph allocate-registers
        graph build-stack-frame
        graph cfg-metrics :> metrics
        graph generate 4 swap nth length "code-bytes" metrics set-at
        rematerialization-count "rematerializations" metrics set-at
        metrics
    ] with-scope ;

{ t } [
    { linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
    [| allocator |
        allocator f pressure-metrics :> before
        allocator t pressure-metrics :> after
        { "spills" "reloads" "spill-bytes" "code-bytes" }
        [| key | key before at key after at > ] all?
        "rematerializations" after at 0 > and
    ] all?
] unit-test

:: compile-pressure ( graph allocator enabled? -- word )
    graph cfg set
    enabled? rematerialize-constants? set
    allocator register-allocator set
    t check-allocation? set
    t check-numbering? set
    graph allocate-registers
    graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;

{ t } [
    value-flow-verifier-enabled? t assert=
    { linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
    [| allocator |
        { f t } [| enabled? |
            [
                <signed-constant-pressure-cfg> allocator enabled? compile-pressure
                0 swap execute( x -- sum ) -20 =
            ] with-scope
        ] all?
    ] all?
] unit-test

:: <pressure-diamond> ( -- cfg )
    init-pressure-representations
    [
        ##prologue,
        90 D: 0 ##peek,
        emit-pressure-constants
        90 0 cc> ##compare-integer-imm-branch,
    ] { } make 0 insns>block :> entry
    [
        40 emit-pressure-sum D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make 1 insns>block :> left
    [
        100 emit-pressure-sum 139 swap 1 tag-fixnum ##add-imm,
        139 D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make 2 insns>block :> right
    entry left connect-bbs entry right connect-bbs
    entry block>cfg ;

:: <pressure-loop> ( -- cfg )
    init-pressure-representations
    [
        ##prologue,
        emit-pressure-constants
        90 D: 0 ##peek,
        94 0 ##load-integer,
        ##branch,
    ] { } make 0 insns>block :> entry
    <basic-block> :> header
    [
        40 emit-pressure-sum drop
        92 91 1 tag-fixnum ##sub-imm,
        ##branch,
    ] { } make 2 insns>block :> body
    [
        95 D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make 3 insns>block :> done
    [
        91 H{ { entry 90 } { body 92 } } ##phi,
        95 H{ { entry 94 } { body 78 } } ##phi,
        91 0 cc> ##compare-integer-imm-branch,
    ] V{ } make header instructions<<
    entry header connect-bbs
    header body connect-bbs header done connect-bbs
    body header connect-bbs
    entry block>cfg ;

:: <pressure-gc> ( -- cfg )
    <constant-pressure-cfg> :> graph
    graph entry>> [
        41 cut [
            98 99 ##save-context,
            V{ } clone H{ } clone gc-map boa ##call-gc,
        ] V{ } make swap append append
    ] change-instructions drop
    graph ;

! Keep final value-flow verification active for these executed fixtures.
! In particular, the diamond forces chordal to resolve constants at edges
! without resident fragments; reserving a slot there instead of using the
! recipe reads uninitialized memory on the second branch.
{ t } [
    value-flow-verifier-enabled? t assert=
    { linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
    [| allocator |
        { f t } [| enabled? |
            [
                <pressure-diamond> allocator enabled? compile-pressure :> diamond
                1 diamond execute( x -- sum ) 820 =
                -1 diamond execute( x -- sum ) 821 = and
                <pressure-loop> allocator enabled? compile-pressure :> loop
                0 loop execute( x -- sum ) 0 = and
                3 loop execute( x -- sum ) 820 = and
                <pressure-gc> allocator enabled? compile-pressure
                0 swap execute( x -- sum ) 820 = and
            ] with-scope
        ] all?
    ] all?
] unit-test


{ t } [
    { linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
    [| allocator |
        { f t } [| enabled? |
            [
                <constant-pressure-cfg> allocator enabled? compile-pressure
                0 swap execute( x -- sum ) 820 =
            ] with-scope
        ] all?
    ] all?
] unit-test

! Execute normal optimized code with the option enabled across branches,
! loops, allocation/collection and calls as well as the default path.
{ t } [
    { linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
    [| allocator |
        allocator register-allocator [
            { f t } [| enabled? |
                enabled? rematerialize-constants? [
                    10 [ dup 5 > [ 17 fixnum+fast ] [ 19 fixnum+fast ] if
                        3 [ 7 fixnum+fast ] times gc ] compile-call
                ] with-variable
            ] map { 48 48 } =
        ] with-variable
    ] all?
] unit-test
