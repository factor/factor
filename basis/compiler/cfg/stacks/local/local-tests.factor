USING: accessors compiler.cfg compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks.local
compiler.cfg.utilities compiler.test cpu.architecture kernel
kernel.private make math namespaces sequences.private slots.private
tools.test ;
IN: compiler.cfg.stacks.local.tests

! end-local-analysis
{
    HS{ }
    HS{ }
    HS{ }
} [
    V{ } 137 insns>block
    [ [ "eh" , end-local-analysis ] V{ } make drop ]
    [ [ peeks>> ] [ replaces>> ] [ kills>> ] tri ] bi
] cfg-unit-test

{
    HS{ d: 3 }
} [
    V{ } 137 insns>block
    [ [ 3 d: 3 replace-loc "eh" , end-local-analysis ] V{ } make drop ]
    [ replaces>> ] bi
] cfg-unit-test

! local-loc>global
{ d: 6 } [
    d: 3 3 0 0 0 height-state boa
    local-loc>global
] unit-test

{
    d: 4
    r: 5
} [
    3 4 0 0 height-state boa
    [ d: 1 swap local-loc>global ]
    [ r: 1 swap local-loc>global ] bi
] unit-test

! kill-locations
{
    { 10 11 12 13 14 15 }
    { }
    { }
    { -6 -5 -4 -3 }
    { -7 -6 -5 }
} [
    -10 -6 kill-locations
    0 0 kill-locations
    2 4 kill-locations
    6 -4 kill-locations
    7 -3 kill-locations
] unit-test

! loc>vreg
{ 1 } [
    d: 0 loc>vreg
] cfg-unit-test

! replace-loc
{ 80 } [
    80 d: 77 replace-loc
    d: 77 peek-loc
] cfg-unit-test

! stack-changes
{
    {
        T{ ##copy { dst 1 } { src 25 } { rep any-rep } }
        T{ ##copy { dst 2 } { src 26 } { rep any-rep } }
    }
} [
    { { d: 0 25 } { r: 0 26 } } replaces>copy-insns
] cfg-unit-test

! remove-redundant-replaces
{
    H{ { T{ ds-loc { n 3 } } 7 } }
} [
    d: 0 loc>vreg d: 2 loc>vreg 2drop
    2 d: 2 replace-loc 7 d: 3 replace-loc
    replaces get remove-redundant-replaces
] cfg-unit-test

! emit-insns
{
    V{
        T{ ##copy { dst 1 } { src 3 } { rep any-rep } }
        "eh"
    }
} [
    3 d: 0 replace-loc [
        "eh" ,
        replaces get height-state get emit-insns
    ] V{ } make
] cfg-unit-test

! compute-local-kill-set
{ HS{ } } [
    0 0 0 0 height-state boa compute-local-kill-set
] unit-test

{ HS{ r: -4 } } [
    0 4 0 -1 height-state boa compute-local-kill-set
] unit-test

{ HS{ d: -1 d: -2 } } [
    2 0 -2 0 height-state boa compute-local-kill-set
] unit-test

! global-loc>local
{ d: 2 } [
    d: 3 1 0 0 0 height-state boa global-loc>local
] unit-test

! height-state
{
    T{ height-state f 0 0 3 0 }
} [
    d: 3 inc-stack height-state get
] cfg-unit-test

{
    T{ height-state f 2 0 3 0 }
} [
    2 0 0 0 height-state boa height-state set
    d: 3 inc-stack height-state get
] cfg-unit-test

{
    { T{ ##inc { loc d: 4 } } T{ ##inc { loc r: -2 } } }
} [
    0 0 4 -2 height-state boa height-state>insns
] unit-test

{ H{ { d: -1 40 } } } [
    d: 1 inc-stack 40 d: 0 replace-loc replaces get
] cfg-unit-test

! Compiling these words used to make the compiler hang due to a bug in
! end-local-analysis. So the test is just to compile them and if it
! doesn't hang, the bug is fixed! See #1507
: my-new-key4 ( a i j -- i/j )
    2over
    slot
    tuck
    ! a i el j el
    [
        ! a i el j
        swap
        ! a i j el
        77 eq?
        [
            rot drop and
        ]
        [
            ! a i j
            over or my-new-key4
        ] if
    ]
    [
        ! a i el j
        2drop t
        ! a i t
        my-new-key4
    ] if ; inline recursive

: badword ( y -- )
    0 swap dup
    { integer object } declare
    [
        { array-capacity object } declare nip
        1234 1234 pick
        f
        my-new-key4
        set-slot
    ]
    curry (each-integer) ;
