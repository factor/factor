USING: vocabs.loader ;
"compiler.cfg.value-numbering" reload
"compiler.cfg.value-numbering.global" reload
"compiler.cfg.copy-prop" reload
"compiler.cfg.liveness" reload
"compiler.cfg.ssa.interference.live-ranges" reload
"compiler.cfg.ssa.destruction" reload
"compiler.cfg.linear-scan.live-intervals" reload
"compiler.cfg.linear-scan.assignment" reload
"compiler.cfg.linear-scan.resolve" reload
USING: accessors arrays assocs combinators system compiler.cfg compiler.cfg.build-stack-frame
compiler.cfg.checker compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.numbering
compiler.cfg.register-allocation compiler.cfg.registers compiler.cfg.utilities
compiler.cfg.value-numbering compiler.cfg.value-numbering.global
compiler.cfg.copy-prop compiler.codegen compiler.units continuations
cpu.architecture hashtables kernel layouts locals make math math.bitwise
namespaces prettyprint sequences words ;
IN: gvn-moving-review

: init-reps ( -- )
    H{ } clone representations set
    12 <iota> [ int-rep swap set-rep-of ] each
    tagged-rep 0 set-rep-of 12 vreg-counter set ;

:: install-graph ( graph -- word )
    graph cfg set
    linear-scan-allocator register-allocator set
    t check-allocation? set
    graph allocate-registers graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;

: <address-word> ( -- word )
    init-reps
    [
        ##prologue,
        0 D: 0 ##peek,
        1 0 ##tagged>integer,
        2 1 tag-bits get ##shl-imm,
        2 D: 0 ##replace,
        ##epilogue, ##return,
    ] V{ } make insns>cfg install-graph ;

:: <moving-graph> ( single? -- graph )
    init-reps
    [
        ##prologue,
        0 D: 0 ##peek,
        1 0 ##tagged>integer,
        2 1 7 ##xor-imm,
        3 2 tag-bits get ##shl-imm,
    ] V{ } make :> before
    [
        4 5 ##save-context,
        V{ } clone H{ } clone gc-map boa ##call-gc,
    ] V{ } make :> collect
    [
        6 1 7 ##xor-imm,
        7 6 tag-bits get ##shl-imm,
        D: 1 ##inc,
        3 D: 1 ##replace,
        7 D: 0 ##replace,
        ##epilogue, ##return,
    ] V{ } make :> after
    single? [ before collect append after append insns>cfg ] [
        before T{ ##branch } clone suffix 0 insns>block :> entry
        collect T{ ##branch } clone suffix 1 insns>block :> middle
        after 2 insns>block :> tail
        entry middle connect-bbs middle tail connect-bbs
        entry block>cfg
    ] if ;

:: compile-probe ( single? mode -- word )
    single? <moving-graph> :> graph
    graph check-ssa
    mode {
        { 0 [ ] }
        { 1 [ graph local-value-numbering ] }
        { 2 [ t global-value-numbering? [ graph value-numbering ] with-variable ] }
    } case
    graph copy-propagation
    graph check-ssa
    "optimized" . graph [ instructions>> . ] each-basic-block
    graph install-graph ;

:: probe-once ( word address seed -- row )
    ! The object remains independently rooted in this caller while the native
    ! callee sees another copy; neither expected identity nor address comes
    ! back through the possibly miscompiled callee.
    seed 1array :> object
    object address execute( obj -- address ) :> before
    object word execute( obj -- before after ) :> ( observed-before observed-after )
    object address execute( obj -- address ) :> after
    before after observed-before observed-after 4array
    before after = not
    observed-before before 7 bitxor =
    observed-after after 7 bitxor =
    observed-before observed-after = 4array 2array ;

[let
<address-word> :> address
{ f t } [| single? |
    { 0 1 2 } [| mode |
        [
            single? mode 2array .
            single? mode compile-probe :> word
            8 <iota> [ word address rot probe-once ] map .
        ] [ . ] recover
    ] each
] each
]
0 exit
