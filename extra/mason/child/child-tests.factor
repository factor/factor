USING: io io.pathnames kernel mason.child mason.config
namespaces sequences system tools.test ;

{ t } [
    H{
        { target-os windows }
        { target-cpu x86.32 }
    } [ mason-child-boot-cmd ] with-variables first absolute-path?
] unit-test

[ [ "Hi" print ] [ drop 3 ] [ 4 ] recover-else ] must-infer

{ 4 } [ [ "Hi" print ] [ drop 3 ] [ 4 ] recover-else ] unit-test

{ 3 } [ [ "Hi" throw ] [ drop 3 ] [ 4 ] recover-else ] unit-test

{ "A" } [
    {
        { [ 3 throw ] [ { "X" "Y" "Z" "A" } nth ] }
        [ "B" ]
    } recover-cond
] unit-test

{ "B" } [
    {
        { [ ] [ ] }
        [ "B" ]
    } recover-cond
] unit-test
