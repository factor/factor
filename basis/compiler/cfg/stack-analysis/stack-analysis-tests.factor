USING: compiler.cfg.debugger compiler.cfg.linearization
compiler.cfg.predecessors compiler.cfg.stack-analysis
compiler.cfg.instructions sequences kernel tools.test accessors
sequences.private alien math combinators.private compiler.cfg
compiler.cfg.checker ;
IN: compiler.cfg.stack-analysis.tests

[ f ] [ 1 2 H{ { 2 1 } } maybe-set-at ] unit-test
[ t ] [ 1 3 H{ { 2 1 } } clone maybe-set-at ] unit-test
[ t ] [ 3 2 H{ { 2 1 } } clone maybe-set-at ] unit-test

: linearize ( cfg -- seq )
    build-mr instructions>> ;

: test-stack-analysis ( quot -- mr )
    dup cfg? [ test-cfg first ] unless
    compute-predecessors optimize-stack
    dup check-cfg ;

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
[ 2 ] [ [ dup ] test-stack-analysis linearize [ ##inc-d? ] count ] unit-test

! Bug in height tracking
[ ] [ [ dup [ ] [ reverse ] if ] test-stack-analysis drop ] unit-test
[ ] [ [ dup [ ] [ dup reverse drop ] if ] test-stack-analysis drop ] unit-test
[ ] [ [ [ drop dup 4.0 > ] find-last-integer ] test-stack-analysis drop ] unit-test

! Bugs with code that throws
[ ] [ [ [ "Oops" throw ] unless ] test-stack-analysis drop ] unit-test
[ ] [ [ [ ] (( -- * )) call-effect-unsafe ] test-stack-analysis drop ] unit-test
[ ] [ [ dup [ "Oops" throw ] when dup ] test-stack-analysis drop ] unit-test
[ ] [ [ B{ 1 2 3 4 } over [ "Oops" throw ] when swap ] test-stack-analysis drop ] unit-test