! Copyright (C) 2019 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators folder io io.directories
io.encodings.utf8
io.files io.files.temp io.pathnames kernel libc
locals namespaces sequences string strings accessors
tools.test ;

IN: folder.tests

SYMBOL: testfolder

DEFER: testfolder-init
:: testfolder-delete ( -- )
    testfolder get :> tf
    tf
    [ tf file-exists?
      [ tf delete-tree  tf make-directories ]
      [ tf make-directories ]
      if
    ]
    [ testfolder-init
      tf make-directories 
    ] 
    if
    ;

: testfolder-init ( -- )
    temp-directory "/factor/folder" append
    testfolder set
    testfolder-delete ;

: testfolder-finder ( -- )
    "open " testfolder get append  system drop ;

! tests are relative to temp folder
:: create-test-file ( path filename content -- )
    path "/" prepend  testfolder get prepend :> path!
    path make-directories
    path filename append
    content [ print ] curry
    utf8 swap 
    with-file-writer ;

: create-test-files ( path -- )
    dup file-name
    {
        { "a" [ "/a-file" "aaaa" create-test-file ] }
        { "b" [ "/b-file" "bbbb" create-test-file ] }
        { "c" [ "/c-file" "cccc" create-test-file ] }
        { "d" [ "/d-file" "dddd" create-test-file ] }
        [ 2drop ]
    } case
    ;

: create-abcd-folders ( -- )
    testfolder-delete
    { }
    {
        { "test1" { "/a" "/b" "/c" } }
        { "test2" { "/a" "/b" } }
        { "test3" { "/b" "/c" } }
        { "test4" { "/d" } }
    }
    [
        unclip swap first
        [ over prepend swapd suffix swap ] each
        drop
    ] each
    [ create-test-files ] each
    ;


CONSTANT: f1 "resource:work/folder/test/test1" 
CONSTANT: f2 "resource:work/folder/test/test2" 

[ "trimmed" ] [ " trimmed " trim-whitespace ] unit-test
[ "a/b/c" ] [ { "a" "b" "c" } components-to-path ] unit-test
[ "folder/" ] [ "folder" as-directory ] unit-test
[ "folder/" ] [ "folder/" as-directory ] unit-test
[ "/path/file/" ] [ "/path/file" as-directory ] unit-test
[ "/path/file/" ] [ "/path/file/" as-directory ] unit-test
[ "test/file" t ] [ "resource:test/file" special-path? ] unit-test 
[ "test/file" t ] [ "vocab:test/file" special-path? ] unit-test 
[ "test/file" t ] [ "~test/file" special-path? ] unit-test 
[ "test/file" f ] [ "test/file" special-path? ] unit-test 

! Try the basic first
[ t ] [ testfolder-init testfolder get file-exists? f = not ] unit-test
[ V{
    "test1"
    "test1/a"
    "test1/a/a-file"
    "test1/c"
    "test1/c/c-file"
    "test1/b"
    "test1/b/b-file"
    "test4"
    "test4/d"
    "test4/d/d-file"
    "test3"
    "test3/c"
    "test3/c/c-file"
    "test3/b"
    "test3/b/b-file"
    "test2"
    "test2/a"
    "test2/a/a-file"
    "test2/b"
    "test2/b/b-file"
    } ]
[ create-abcd-folders
  testfolder get set-current-directory
  "./" recursive-directory-files 
] unit-test

[ {
    "a-file"
    "c-file"
    "b-file"
    "d-file"
    "c-file"
    "b-file"
    "a-file"
    "b-file"
    } ]
[ testfolder get >folder-tree
  entries>>  [ name>> ] map
] unit-test



