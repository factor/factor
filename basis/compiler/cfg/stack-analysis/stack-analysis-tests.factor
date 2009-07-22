USING: prettyprint compiler.cfg.debugger compiler.cfg.linearization
compiler.cfg.predecessors compiler.cfg.stack-analysis
compiler.cfg.instructions sequences kernel tools.test accessors
sequences.private alien math combinators.private compiler.cfg
compiler.cfg.checker compiler.cfg.rpo
compiler.cfg.dce compiler.cfg.registers
sets namespaces arrays cpu.architecture ;
IN: compiler.cfg.stack-analysis.tests

! Fundamental invariant: a basic block should not load or store a value more than once
: test-stack-analysis ( quot -- cfg )
    dup cfg? [ test-cfg first ] unless
    compute-predecessors
    stack-analysis
    dup check-cfg ;

: linearize ( cfg -- mr )
    flatten-cfg instructions>> ;

[ ] [ [ ] test-stack-analysis drop ] unit-test

! Only peek once
[ 1 ] [ [ dup drop dup ] test-stack-analysis linearize [ ##peek? ] count ] unit-test

! Redundant replace is redundant
[ f ] [ [ dup drop ] test-stack-analysis linearize [ ##replace? ] any? ] unit-test
[ f ] [ [ swap swap ] test-stack-analysis linearize [ ##replace? ] any? ] unit-test

! Replace required here
[ t ] [ [ dup ] test-stack-analysis linearize [ ##replace? ] any? ] unit-test
[ t ] [ [ [ drop 1 ] when ] test-stack-analysis linearize [ ##replace? ] any? ] unit-test

! Only one replace, at the end
[ 1 ] [ [ [ 1 ] [ 2 ] if ] test-stack-analysis linearize [ ##replace? ] count ] unit-test

! Do we support the full language?
[ ] [ [ { [ ] [ ] } dispatch ] test-stack-analysis drop ] unit-test
[ ] [ [ { [ ] [ ] } dispatch dup ] test-stack-analysis drop ] unit-test
[ ] [
    [ "int" { "int" "int" } "cdecl" [ + ] alien-callback ]
    test-cfg second test-stack-analysis drop
] unit-test

! Test loops
[ ] [ [ [ t ] loop ] test-stack-analysis drop ] unit-test
[ ] [ [ [ dup ] loop ] test-stack-analysis drop ] unit-test

! Make sure that peeks are inserted in the right place
[ ] [ [ [ drop 1 ] when ] test-stack-analysis drop ] unit-test

! This should be a total no-op
[ f ] [ [ [ ] dip ] test-stack-analysis linearize [ ##replace? ] any? ] unit-test

! Don't insert inc-d/inc-r; that's wrong!
[ 1 ] [ [ dup ] test-stack-analysis linearize [ ##inc-d? ] count ] unit-test

! Bug in height tracking
[ ] [ [ dup [ ] [ reverse ] if ] test-stack-analysis drop ] unit-test
[ ] [ [ dup [ ] [ dup reverse drop ] if ] test-stack-analysis drop ] unit-test
[ ] [ [ [ drop dup 4.0 > ] find-last-integer ] test-stack-analysis drop ] unit-test

! Bugs with code that throws
[ ] [ [ [ "Oops" throw ] unless ] test-stack-analysis drop ] unit-test
[ ] [ [ [ ] (( -- * )) call-effect-unsafe ] test-stack-analysis drop ] unit-test
[ ] [ [ dup [ "Oops" throw ] when dup ] test-stack-analysis drop ] unit-test
[ ] [ [ B{ 1 2 3 4 } over [ "Oops" throw ] when swap ] test-stack-analysis drop ] unit-test

! Make sure the replace stores a value with the right height
[ ] [
    [ [ . ] [ 2drop 1 ] if ] test-stack-analysis eliminate-dead-code linearize
    [ ##replace? ] filter [ length 1 assert= ] [ first loc>> D 0 assert= ] bi
] unit-test

! translate-loc was the wrong way round
[ ] [
    [ 1 2 rot ] test-stack-analysis eliminate-dead-code linearize
    [ [ ##load-immediate? ] count 2 assert= ]
    [ [ ##peek? ] count 1 assert= ]
    [ [ ##replace? ] count 3 assert= ]
    tri
] unit-test

[ ] [
    [ 1 2 ? ] test-stack-analysis eliminate-dead-code linearize
    [ [ ##load-immediate? ] count 2 assert= ]
    [ [ ##peek? ] count 1 assert= ]
    [ [ ##replace? ] count 1 assert= ]
    tri
] unit-test

! Sync before a back-edge, not after
! ##peeks should be inserted before a ##loop-entry
! Don't optimize out the constants
[ t ] [
    [ 1000 [ ] times ] test-stack-analysis eliminate-dead-code linearize
    [ ##load-immediate? ] any?
] unit-test

! Correct height tracking
[ t ] [
    [ pick [ <array> ] [ drop ] if swap ] test-stack-analysis eliminate-dead-code
    reverse-post-order 4 swap nth
    instructions>> [ ##peek? ] filter first2 [ loc>> ] [ loc>> ] bi*
    2array { D 1 D 0 } set=
] unit-test

[ D 1 ] [
    V{ T{ ##branch } } 0 test-bb

    V{ T{ ##peek f V int-regs 0 D 2 } T{ ##branch } } 1 test-bb

    V{
        T{ ##peek f V int-regs 1 D 2 }
        T{ ##inc-d f -1 }
        T{ ##branch }
    } 2 test-bb

    V{ T{ ##call f \ + -1 } T{ ##branch } } 3 test-bb

    V{ T{ ##return } } 4 test-bb

    test-diamond

    cfg new 0 get >>entry
    compute-predecessors
    stack-analysis
    drop

    3 get successors>> first instructions>> first loc>>
] unit-test

! Do inserted ##peeks reference the correct stack location if
! an ##inc-d/r was also inserted?
[ D 0 ] [
    V{ T{ ##branch } } 0 test-bb

    V{ T{ ##branch } } 1 test-bb

    V{
        T{ ##peek f V int-regs 1 D 0 }
        T{ ##branch }
    } 2 test-bb

    V{
        T{ ##call f \ + -1 }
        T{ ##inc-d f 1 }
        T{ ##branch }
    } 3 test-bb

    V{ T{ ##return } } 4 test-bb

    test-diamond

    cfg new 0 get >>entry
    compute-predecessors
    stack-analysis
    drop

    3 get successors>> first instructions>> [ ##peek? ] find nip loc>>
] unit-test

! Missing ##replace
[ t ] [
    [ [ "B" ] 2dip dup [ [ /mod ] dip ] when ] test-stack-analysis
    reverse-post-order last
    instructions>> [ ##replace? ] filter [ loc>> ] map
    { D 0 D 1 D 2 } set=
] unit-test

! Inserted ##peeks reference the wrong stack location
[ t ] [
    [ [ "B" ] 2dip dup [ [ /mod ] dip ] when ] test-stack-analysis
    eliminate-dead-code reverse-post-order 4 swap nth
    instructions>> [ ##peek? ] filter [ loc>> ] map
    { D 0 D 1 } set=
] unit-test

[ D 0 ] [
    V{ T{ ##branch } } 0 test-bb

    V{ T{ ##branch } } 1 test-bb

    V{
        T{ ##peek f V int-regs 1 D 0 }
        T{ ##inc-d f 1 }
        T{ ##branch }
    } 2 test-bb

    V{
        T{ ##inc-d f 1 }
        T{ ##branch }
    } 3 test-bb

    V{ T{ ##return } } 4 test-bb

    test-diamond

    cfg new 0 get >>entry
    compute-predecessors
    stack-analysis
    drop

    3 get successors>> first instructions>> [ ##peek? ] find nip loc>>
] unit-test