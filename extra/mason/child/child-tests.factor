IN: mason.child.tests
USING: mason.child mason.config tools.test namespaces io kernel
sequences system ;

[ { "nmake" "/f" "nmakefile" "x86-32" } ] [
    H{
        { target-os windows }
        { target-cpu x86.32 }
    } [ make-cmd ] with-variables
] unit-test

[ { "make" "macosx-x86-32" } ] [
    H{
        { target-os macosx }
        { target-cpu x86.32 }
    } [ make-cmd ] with-variables
] unit-test

[ { "./factor.com" "-i=boot.windows-x86.32.image" "-no-user-init" } ] [
    H{
        { target-os windows }
        { target-cpu x86.32 }
    } [ boot-cmd ] with-variables
] unit-test

[ [ "Hi" print ] [ drop 3 ] [ 4 ] recover-else ] must-infer

[ 4 ] [ [ "Hi" print ] [ drop 3 ] [ 4 ] recover-else ] unit-test

[ 3 ] [ [ "Hi" throw ] [ drop 3 ] [ 4 ] recover-else ] unit-test

[ "A" ] [
    {
        { [ 3 throw ] [ { "X" "Y" "Z" "A" } nth ] }
        [ "B" ]
    } recover-cond
] unit-test

[ "B" ] [
    {
        { [ ] [ ] }
        [ "B" ]
    } recover-cond
] unit-test
