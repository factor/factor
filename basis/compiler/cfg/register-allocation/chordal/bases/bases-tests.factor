USING: accessors arrays assocs compiler.cfg compiler.cfg.build-stack-frame
compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.liveness compiler.cfg.register-allocation.chordal.bases
compiler.cfg.register-allocation.chordal
compiler.cfg.linear-scan.allocation.state
compiler.cfg.registers compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities compiler.codegen compiler.units cpu.architecture
kernel locals namespaces sequences sorting tools.test words ;
IN: compiler.cfg.register-allocation.chordal.bases.tests

:: derived-diamond ( mixed? -- cfg join call )
    H{ { 0 tagged-rep } { 1 tagged-rep } { 2 int-rep } { 3 int-rep } { 4 int-rep } }
    representations set
    5 vreg-counter set
    f leader-map set
    {
        T{ ##load-reference { dst 0 } { obj "left" } }
        T{ ##load-reference { dst 1 } { obj "right" } }
        T{ ##tagged>integer { dst 2 } { src 0 } }
        T{ ##tagged>integer { dst 3 } { src 1 } }
        T{ ##branch }
    } [ clone ] map 0 insns>block :> entry
    mixed? [
        T{ ##load-integer { dst 3 } { val 42 } } 3 entry instructions>> set-nth
    ] when
    { T{ ##branch } } [ clone ] map 1 insns>block :> left
    { T{ ##branch } } [ clone ] map 2 insns>block :> right
    ##phi new 4 >>dst H{ { left 2 } { right 3 } } >>inputs :> phi
    ##call-gc new <gc-map> >>gc-map :> call
    { phi call } { T{ ##replace { src 4 } { loc D: 0 } } T{ ##branch } }
    [ clone ] map append
    3 insns>block :> join
    entry left connect-bbs
    entry right connect-bbs
    left join connect-bbs
    right join connect-bbs
    entry block>cfg join call ;

! A phi selecting between derived pointers with distinct tagged bases gets
! a companion phi selecting those bases on the identical incoming edges.
{ t t { 0 1 } } [
    [ [let
        f derived-diamond :> ( cfg join call )
        cfg construct-ssa-bases
        cfg compute-ssa-live-sets
        4 phi-bases get at :> base
        call gc-map>> gc-roots>> base swap member?
        call gc-map>> derived-roots>> { 4 base } swap member?
        join instructions>> first inputs>> values natural-sort
    ] ] with-scope
] unit-test

:: executable-derived-cfg ( -- cfg )
    f derived-diamond :> ( cfg join call )
    tagged-rep 6 set-rep-of
    7 vreg-counter set
    {
        T{ ##prologue }
        T{ ##peek { dst 0 } { loc D: 2 } }
        T{ ##peek { dst 1 } { loc D: 1 } }
        T{ ##peek { dst 6 } { loc D: 0 } }
        T{ ##inc { loc D: -2 } }
        T{ ##tagged>integer { dst 2 } { src 0 } }
        T{ ##tagged>integer { dst 3 } { src 1 } }
        T{ ##compare-imm-branch { src1 6 } { src2 f } { cc cc/= } }
    } [ clone ] V{ } map-as cfg entry>> instructions<<
    join [ but-last { T{ ##epilogue } T{ ##return } } [ clone ] map append V{ } like ] change-instructions drop
    cfg ;

: compile-derived-cfg ( cfg -- word )
    dup cfg set
    gensym [
        [ chordal-allocation ] [ build-stack-frame ] [ generate ] tri
    ] dip [ associate >alist t t modify-code-heap ] keep ;

:: execute-derived-gc ( word flag -- ? )
    10 1array :> left
    20 1array :> right
    left right flag word execute( left right flag -- selected ) :> selected
    selected flag left right ? eq? ;

! Both inputs are newly allocated nursery objects. The native CFG carries
! a raw tagged address through an int phi and explicitly collects before
! returning it. Pointer identity checks detect a missing relocation even
! when the old nursery bytes still happen to contain the original data.
{ t t } [
    [
        t check-allocation? set
        executable-derived-cfg compile-derived-cfg
        [ t execute-derived-gc ] [ f execute-derived-gc ] bi
    ] with-scope
] unit-test

! A non-pointer edge gets an immutable false base. Relocating it changes
! neither the integer nor the base, while the pointer edge remains rooted.
{ t t } [
    [ [let
        t derived-diamond :> ( cfg join call )
        cfg construct-ssa-bases
        cfg compute-ssa-live-sets
        join instructions>> first inputs>> values [ 0 = not ] find nip :> non-pointer-base
        non-pointer-base rep-of tagged-rep =
        call gc-map>> derived-roots>> 4 phi-bases get at 4 swap 2array swap member?
    ] ] with-scope
] unit-test
