! Copyright (C) 2012 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators folder.compare folder.tests io
io.directories io.encodings.utf8 io.files io.pathnames kernel
namespaces regexp sequences tools.test ;
FROM: folder => pathname ;
IN: folder.compare.tests

: mdtestfilter ( -- )
    f1 f2 new-shallow-compare
    "\\..*" <regexp>  >>filter
    folder-diff
    [ print ] each
    ;

CONSTANT: f3 "/Volumes/data/Users/davec/Dropbox/FactorWork"
CONSTANT: f4 "/Volumes/data/Users/davec/Dropbox/FactorWork.1"
FROM: folder => pathname ;
: mdtest ( -- )
    f3 f4 compare-these
    folder-diff drop
    ;

: abcd-folders ( -- folder.compare )
    create-abcd-folders
    f1 f2 compare-these
    ;
[ { "a" "a/a-file" "b" "b/b-file" } ] [ abcd-folders folder-diff ] unit-test
[ { "a" "a/a-file" "b" "b/b-file" "c" "c/c-file" "d" "d/d-file" } ] [ abcd-folders folder-union ] unit-test
[ { "c" "c/c-file" } ] [ abcd-folders folder-intersect ] unit-test

 
