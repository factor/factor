USING: arrays combinators destructors grouping io io.directories
io.encodings.ascii io.encodings.binary io.encodings.utf8
io.files io.files.info io.files.unique io.launcher io.pathnames
kernel math namespaces sequences sorting splitting
splitting.monotonic strings system tools.test ;

{ { "kernel" } } [
    "core" resource-path [
        "." directory-files [ "kernel" = ] filter
    ] with-directory
] unit-test

{ { "kernel" } } [
    "resource:core" [
        "." directory-files [ "kernel" = ] filter
    ] with-directory
] unit-test

{ { "kernel" } } [
    "resource:core" [
        [ "kernel" = ] filter
    ] with-directory-files
] unit-test

[
    { t t f } [
        "blahblah" make-directory
        "blahblah" file-exists?
        "blahblah" file-info directory?
        "blahblah" delete-directory
        "blahblah" file-exists?
    ] unit-test

    { "file1 contents" } [
        "file1 contents" "file1" utf8 set-file-contents
        "file1" "file2" copy-file
        "file2" utf8 file-contents
        "file1" delete-file
        "file2" delete-file
    ] unit-test

    { "file3 contents" } [
        "file3 contents" "file3" utf8 set-file-contents
        "file3" "file4" move-file
        "file4" utf8 file-contents
        "file4" delete-file
    ] unit-test

    { } [
        "file5" touch-file
        "file5" delete-file
    ] unit-test

    { } [
        "file6" touch-file
        "file6" link-info drop
    ] unit-test

    { "file7 contents" } [
        "file8" touch-file
        "file7 contents" "file7" utf8 set-file-contents
        "file7" "file8" move-file
        "file8" utf8 file-contents
        "file8" delete-file
    ] unit-test

    { } [
        { "Hello world." }
        "test-foo.txt" ascii set-file-lines
    ] unit-test

    { } [
        "test-foo.txt" ascii [
            "Hello appender." print
        ] with-file-appender
    ] unit-test

    { } [
        "test-bar.txt" ascii [
            "Hello appender." print
        ] with-file-appender
    ] unit-test

    { "Hello world.\nHello appender.\n" } [
        "test-foo.txt" ascii file-contents
    ] unit-test

    { "Hello appender.\n" } [
        "test-bar.txt" ascii file-contents
    ] unit-test

    { } [ "test-foo.txt" delete-file ] unit-test
    { } [ "test-bar.txt" delete-file ] unit-test

    { f } [ "test-foo.txt" file-exists? ] unit-test
    { f } [ "test-bar.txt" file-exists? ] unit-test

    { } [ "test-blah" make-directory ] unit-test

    { } [
        "test-blah/fooz" ascii <file-writer> dispose
    ] unit-test

    { t } [
        "test-blah/fooz" file-exists?
    ] unit-test

    { } [ "test-blah/fooz" delete-file ] unit-test
    { } [ "test-blah" delete-directory ] unit-test

    { f } [ "test-blah" file-exists? ] unit-test

    { } [ "delete-tree-test/a/b/c" make-directories ] unit-test

    { } [
        { "Hi" } "delete-tree-test/a/b/c/d" ascii set-file-lines
    ] unit-test

    { } [ "delete-tree-test" delete-tree ] unit-test

    { } [
        "copy-tree-test/a/b/c" make-directories
    ] unit-test

    { } [
        "Foobar"
        "copy-tree-test/a/b/c/d"
        ascii set-file-contents
    ] unit-test

    { } [
        "copy-tree-test" "copy-destination" copy-tree
    ] unit-test

    { "Foobar" } [
        "copy-destination/a/b/c/d" ascii file-contents
    ] unit-test

    { } [
        "copy-destination" delete-tree
    ] unit-test

    { } [
        "copy-tree-test" "copy-destination" copy-tree-into
    ] unit-test

    { "Foobar" } [
        "copy-destination/copy-tree-test/a/b/c/d" ascii file-contents
    ] unit-test

    ! copy-file
    { } [
        "resource:LICENSE.txt" "test" copy-file
    ] unit-test

    ! copy-file-into
    { } [
        "copy-destination/copy-tree-test/a/b/c/d" "." copy-file-into
    ] unit-test

    { "Foobar" } [
        "d" ascii file-contents
    ] unit-test

    { } [ "d" delete-file ] unit-test

    { } [ "copy-destination" delete-tree ] unit-test

    { } [ "copy-tree-test" delete-tree ] unit-test

    ! Issue #890
    { f t } [
        "foo" [ make-directories ] keep
        [
            "bar" file-exists?
            vm-path "-e=USE: io.directories \"bar\" touch-file" 2array try-output-process
            "bar" file-exists?
        ] with-directory
    ] unit-test

    { t } [
        "one/two/three" make-parent-directories parent-directory file-exists?
    ] unit-test

] with-test-directory

{ t } [
    [
        10 [ "io.paths.test" "gogogo" unique-file ] replicate
        "." [ ] find-files [ absolute-path ] map [ sort ] same?
    ] with-test-directory
] unit-test

{ f } [
    { "omg you shoudnt have a directory called this" "or this" }
    [ "asdfasdfasdfasdfasdf" tail? ] find-file-in-directories
] unit-test

{ f } [
    { } [ "asdfasdfasdfasdfasdf" tail? ] find-file-in-directories
] unit-test

{ t } [
    [
        "the-head" "" unique-file drop
        "." [ file-name "the-head" head? ] find-file string?
    ] with-test-directory
] unit-test

{ t } [
    [
        { "foo" "bar" } {
            [ [ make-directory ] each ]
            [ [ "abcd" append-path touch-file ] each ]
            [ [ file-name "abcd" = ] find-files-in-directories length 2 = ]
            [ [ delete-tree ] each ]
        } cleave
    ] with-test-directory
] unit-test

{ t } [
    "resource:core/math/integers/integers.factor"
    [ "math.factor" tail? ] find-up-to-root >boolean
] unit-test

{ f } [
    "resource:core/math/integers/integers.factor"
    [ drop f ] find-up-to-root
] unit-test

[
    {
        "a"
        "a/a"
        "a/a/a"
        "a/b"
        "a/b/a"
        "b"
        "b/a"
        "b/a/a"
        "b/b"
        "b/b/a"
        "c"
        "c/a"
        "c/a/a"
        "c/b"
        "c/b/a"
    }
    {
        "a"
        "b"
        "c"
        "a/a"
        "a/b"
        "b/a"
        "b/b"
        "c/a"
        "c/b"
        "a/a/a"
        "a/b/a"
        "b/a/a"
        "b/b/a"
        "c/a/a"
        "c/b/a"
    }
] [
    [
        "a" make-directory
        "a/a" make-directory
        "a/a/a" touch-file
        "a/b" make-directory
        "a/b/a" touch-file
        "b" make-directory
        "b/a" make-directory
        "b/a/a" touch-file
        "b/b" make-directory
        "b/b/a" touch-file
        "c" make-directory
        "c/a" make-directory
        "c/a/a" touch-file
        "c/b" make-directory
        "c/b/a" touch-file

        +depth-first+ traversal-method [
            "." recursive-directory-files
            current-directory get '[ _ ?head drop ] map

            ! preserve file traversal order, but sort
            ! alphabetically for cross-platform testing
            dup length 3 / group sort
            [ sort ] map concat
        ] with-variable

        +breadth-first+ traversal-method [
            "." recursive-directory-files
            current-directory get '[ _ ?head drop ] map

            ! preserve file traversal order, but sort
            ! alphabetically for cross-platform testing
            [ 2length = ] monotonic-split
            [ sort ] map concat
        ] with-variable
    ] with-test-directory
] unit-test

! test P"" pathnames
[ "resource:extra/math" recursive-directory-files drop ] must-not-fail

{ "/foo/bar" } [ P"/foo" P"./bar" append-path ] unit-test
{ "/bar/foo" } [ P"./foo" P"/bar" prepend-path ] unit-test

[ "resource:asdljkfasldkjfasdljfk" 0 truncate-file ] must-fail

{ f 16 8 } [
    [
        {
            [ touch-file ]
            [ binary [ input-stream get stream-length ] with-file-reader ]
            [ 16 truncate-file ]
            [ binary [ input-stream get stream-length ] with-file-reader ]
            [ 8 truncate-file ]
            [ binary [ input-stream get stream-length ] with-file-reader ]
        } cleave
    ] with-test-file
] unit-test
