USING: tools.test vocabs ;

{ f } [ "kernel" vocab-main ] unit-test

{ t } [ "" "" child-vocab? ] unit-test
{ t } [ "" "io.files" child-vocab? ] unit-test
{ t } [ "io" "io.files" child-vocab? ] unit-test
{ f } [ "io.files" "io" child-vocab? ] unit-test
{ f } [ "io.files" "io.filesfoo" child-vocab? ] unit-test
{ t } [ "io.files" "io.files" child-vocab? ] unit-test

[ "foo/bar" create-vocab ] [ bad-vocab-name? ] must-fail-with
[ "foo\\bar" create-vocab ] [ bad-vocab-name? ] must-fail-with
[ "foo:bar" create-vocab ] [ bad-vocab-name? ] must-fail-with
[ 3 create-vocab ] [ bad-vocab-name? ] must-fail-with
[ f create-vocab ] [ bad-vocab-name? ] must-fail-with
[ "a b" create-vocab ] [ bad-vocab-name? ] must-fail-with

[ "foo/bar" lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ "foo\\bar" lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ "foo:bar" lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ 3 lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ f lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ "a b" lookup-vocab ] [ bad-vocab-name? ] must-fail-with

[ "foo/bar" >vocab-link lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ "foo\\bar" >vocab-link lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ "foo:bar" >vocab-link lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ 3 >vocab-link lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ f >vocab-link lookup-vocab ] [ bad-vocab-name? ] must-fail-with
[ "a b" >vocab-link lookup-vocab ] [ bad-vocab-name? ] must-fail-with

[ "sojoijsaoifjsthisdoesntexistomgomgomgplznodontexist" require ]
[ no-vocab? ] must-fail-with

[ "letstrythisagainnooooooyoucantexistnoooooo" load-vocab ]
[ no-vocab? ] must-fail-with
