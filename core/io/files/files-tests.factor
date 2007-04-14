IN: io.files.tests
USING: tools.test io.files io threads kernel continuations
io.encodings.ascii io.files.unique sequences strings accessors
io.encodings.utf8 ;

[ ] [ "blahblah" temp-file dup exists? [ delete-directory ] [ drop ] if ] unit-test
[ ] [ "blahblah" temp-file make-directory ] unit-test
[ t ] [ "blahblah" temp-file directory? ] unit-test

[ t ] [
    [ temp-directory "loldir" append-path delete-directory ] ignore-errors
    temp-directory [
        "loldir" make-directory
    ] with-directory
    temp-directory "loldir" append-path exists?
] unit-test

[ ] [
    [ temp-directory "loldir" append-path delete-directory ] ignore-errors
    temp-directory [
        "loldir" make-directory
        "loldir" delete-directory
    ] with-directory
] unit-test

[ "file1 contents" ] [
    [ temp-directory "loldir" append-path delete-directory ] ignore-errors
    temp-directory [
        "file1 contents" "file1" utf8 set-file-contents
        "file1" "file2" copy-file
        "file2" utf8 file-contents
    ] with-directory
    "file1" temp-file delete-file
    "file2" temp-file delete-file
] unit-test

[ "file3 contents" ] [
    temp-directory [
        "file3 contents" "file3" utf8 set-file-contents
        "file3" "file4" move-file
        "file4" utf8 file-contents
    ] with-directory
    "file4" temp-file delete-file
] unit-test

[ ] [
    temp-directory [
        "file5" touch-file
        "file5" delete-file
    ] with-directory
] unit-test

[ ] [
    temp-directory [
        "file6" touch-file
        "file6" link-info drop
    ] with-directory
] unit-test

[ "passwd" ] [ "/etc/passwd" file-name ] unit-test
[ "awk" ] [ "/usr/libexec/awk/" file-name ] unit-test
[ "awk" ] [ "/usr/libexec/awk///" file-name ] unit-test
[ "" ] [ "" file-name ] unit-test

[ ] [
    { "Hello world." }
    "test-foo.txt" temp-file ascii set-file-lines
] unit-test

[ ] [
    "test-foo.txt" temp-file ascii [
        "Hello appender." print
    ] with-file-appender
] unit-test

[ ] [
    "test-bar.txt" temp-file ascii [
        "Hello appender." print
    ] with-file-appender
] unit-test

[ "Hello world.\nHello appender.\n" ] [
    "test-foo.txt" temp-file ascii file-contents
] unit-test

[ "Hello appender.\n" ] [
    "test-bar.txt" temp-file ascii file-contents
] unit-test

[ ] [ "test-foo.txt" temp-file delete-file ] unit-test

[ ] [ "test-bar.txt" temp-file delete-file ] unit-test

[ f ] [ "test-foo.txt" temp-file exists? ] unit-test

[ f ] [ "test-bar.txt" temp-file exists? ] unit-test

[ ] [ "test-blah" temp-file make-directory ] unit-test

[ ] [
    "test-blah/fooz" temp-file ascii <file-writer> dispose
] unit-test

[ t ] [
    "test-blah/fooz" temp-file exists?
] unit-test

[ ] [ "test-blah/fooz" temp-file delete-file ] unit-test

[ ] [ "test-blah" temp-file delete-directory ] unit-test

[ f ] [ "test-blah" temp-file exists? ] unit-test

[ ] [ "test-quux.txt" temp-file ascii [ [ yield "Hi" write ] "Test" spawn drop ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" temp-file delete-file ] unit-test

[ ] [ "test-quux.txt" temp-file ascii [ [ yield "Hi" write ] "Test" spawn drop ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" "quux-test.txt" [ temp-file ] 2apply move-file ] unit-test
[ t ] [ "quux-test.txt" temp-file exists? ] unit-test

[ ] [ "quux-test.txt" temp-file delete-file ] unit-test

[ ] [ "delete-tree-test/a/b/c" temp-file make-directories ] unit-test

[ ] [
    { "Hi" }
    "delete-tree-test/a/b/c/d" temp-file ascii set-file-lines
] unit-test

[ ] [
    "delete-tree-test" temp-file delete-tree
] unit-test

[ { { "kernel" t } } ] [
    "core" resource-path [
        "." directory [ first "kernel" = ] subset
    ] with-directory
] unit-test

[ { { "kernel" t } } ] [
    "resource:core" [
        "." directory [ first "kernel" = ] subset
    ] with-directory
] unit-test

[ ] [
    "copy-tree-test/a/b/c" temp-file make-directories
] unit-test

[ ] [
    "Foobar"
    "copy-tree-test/a/b/c/d" temp-file
    ascii set-file-contents
] unit-test

[ ] [
    "copy-tree-test" temp-file
    "copy-destination" temp-file copy-tree
] unit-test

[ "Foobar" ] [
    "copy-destination/a/b/c/d" temp-file ascii file-contents
] unit-test

[ ] [
    "copy-destination" temp-file delete-tree
] unit-test

[ ] [
    "copy-tree-test" temp-file
    "copy-destination" temp-file copy-tree-into
] unit-test

[ "Foobar" ] [
    "copy-destination/copy-tree-test/a/b/c/d" temp-file ascii file-contents
] unit-test

[ ] [
    "copy-destination/copy-tree-test/a/b/c/d" temp-file "" temp-file copy-file-into
] unit-test

[ "Foobar" ] [
    "d" temp-file ascii file-contents
] unit-test

[ ] [ "d" temp-file delete-file ] unit-test

[ ] [ "copy-destination" temp-file delete-tree ] unit-test

[ ] [ "copy-tree-test" temp-file delete-tree ] unit-test

[ t ] [ cwd "misc" resource-path [ ] with-directory cwd = ] unit-test

[ t ] [
    temp-directory [ "hi41" "test41" utf8 set-file-contents ] with-directory
    temp-directory "test41" append-path utf8 file-contents "hi41" =
] unit-test

[ t ] [
    temp-directory [ "test41" file-info size>> ] with-directory 4 =
] unit-test

[ ] [ "append-test" temp-file dup exists? [ delete-file ] [ drop ] if ] unit-test

[ ] [ "append-test" temp-file ascii <file-appender> dispose ] unit-test



[ 123 ] [
    "core" ".test" [
        [
            ascii [
                123 CHAR: a <repetition> >string write
            ] with-file-writer
        ] keep file-info size>>
    ] with-unique-file
] unit-test

[ "/usr/lib" ] [ "/usr" "lib" append-path ] unit-test
[ "/usr/lib" ] [ "/usr/" "lib" append-path ] unit-test
[ "/lib" ] [ "/usr/" "/lib" append-path ] unit-test
[ "/lib/" ] [ "/usr/" "/lib/" append-path ] unit-test
[ "/usr/lib" ] [ "/usr" "./lib" append-path ] unit-test
[ "/usr/lib/" ] [ "/usr" "./lib/" append-path ] unit-test
[ "/lib" ] [ "/usr" "../lib" append-path ] unit-test
[ "/lib/" ] [ "/usr" "../lib/" append-path ] unit-test

[ "" ] [ "" "." append-path ] unit-test
[ "" ".." append-path ] must-fail

[ "/" ] [ "/" "./." append-path ] unit-test
[ "/" ] [ "/" "././" append-path ] unit-test
[ "/a/b/lib" ] [ "/a/b/c/d/e/f/" "../../../../lib" append-path ] unit-test
[ "/a/b/lib/" ] [ "/a/b/c/d/e/f/" "../../../../lib/" append-path ] unit-test

[ "" "../lib/" append-path ] must-fail
[ "lib" ] [ "" "lib" append-path ] unit-test
[ "lib" ] [ "" "./lib" append-path ] unit-test

[ "/lib/bux" ] [ "/usr" "/lib/bux" append-path ] unit-test
[ "/lib/bux/" ] [ "/usr" "/lib/bux/" append-path ] unit-test

[ "foo/bar/." parent-directory ] must-fail
[ "foo/bar/./" parent-directory ] must-fail
[ "foo/bar/baz/.." parent-directory ] must-fail
[ "foo/bar/baz/../" parent-directory ] must-fail

[ "." parent-directory ] must-fail
[ "./" parent-directory ] must-fail
[ ".." parent-directory ] must-fail
[ "../" parent-directory ] must-fail
[ "../../" parent-directory ] must-fail
[ "foo/.." parent-directory ] must-fail
[ "foo/../" parent-directory ] must-fail
[ "" parent-directory ] must-fail
[ "." ] [ "boot.x86.64.image" parent-directory ] unit-test

[ "bar/foo" ] [ "bar/baz" "..///foo" append-path ] unit-test
[ "bar/baz/foo" ] [ "bar/baz" ".///foo" append-path ] unit-test
[ "bar/foo" ] [ "bar/baz" "./..//foo" append-path ] unit-test
[ "bar/foo" ] [ "bar/baz" "./../././././././///foo" append-path ] unit-test

[ t ] [ "resource:core" absolute-path? ] unit-test
[ t ] [ "/foo" absolute-path? ] unit-test
[ f ] [ "" absolute-path? ] unit-test
