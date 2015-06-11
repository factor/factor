USING: io io.pathnames kernel mason.child mason.config
namespaces sequences system tools.test ;
IN: mason.child.tests

[ { "nmake" "/f" "nmakefile" "x86-32" } ] [
    H{
        { target-os windows }
        { target-cpu x86.32 }
    } [ mason-child-make-cmd ] with-variables
] unit-test

[ { "make" "macosx-x86-32" } ] [
    H{
        { target-os macosx }
        { target-cpu x86.32 }
    } [ mason-child-make-cmd ] with-variables
] unit-test

! Must be an absolute path on Windows because launch directory
! is relative to parent directory (instead of current directory).

os windows = [
    { t } [
        H{
            { target-os windows }
            { target-cpu x86.32 }
        } [ mason-child-boot-cmd ] with-variables first absolute-path?
    ] unit-test
] [
    [ { "./factor.com" "-i=boot.windows-x86.32.image" "-no-user-init" } ] [
        H{
            { target-os windows }
            { target-cpu x86.32 }
        } [ mason-child-boot-cmd ] with-variables
    ] unit-test
] if

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
