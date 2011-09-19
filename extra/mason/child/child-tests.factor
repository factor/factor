IN: mason.child.tests
USING: mason.child mason.config tools.test namespaces io kernel
sequences system ;

[ { "nmake" "/f" "nmakefile" "x86-32" } ] [
    [
        windows target-os set
        x86.32 target-cpu set
        make-cmd
    ] with-scope
] unit-test

[ { "make" "macosx-x86-32" } ] [
    [
        macosx target-os set
        x86.32 target-cpu set
        make-cmd
    ] with-scope
] unit-test

[ { "./factor.com" "-i=boot.windows-x86.32.image" "-no-user-init" } ] [
    [
        windows target-os set
        x86.32 target-cpu set
        boot-cmd
    ] with-scope
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
