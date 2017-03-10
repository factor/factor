USING: combinators fry io.directories io.directories.hierarchy
io.directories.search io.files.unique io.pathnames kernel
namespaces sequences sorting splitting strings system
tools.test ;

{ t } [
    [
        10 [ "io.paths.test" "gogogo" unique-file ] replicate
        "." [ ] find-files [ natural-sort ] same?
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

os linux? [
    {
        V{ 1 2 3 2 3 1 2 3 2 3 1 2 3 2 3 }
        V{ 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3 }
    }
] [
    {
        V{
            "/a"
            "/a/a"
            "/a/a/a"
            "/a/b"
            "/a/b/a"
            "/b"
            "/b/a"
            "/b/a/a"
            "/b/b"
            "/b/b/a"
            "/c"
            "/c/a"
            "/c/a/a"
            "/c/b"
            "/c/b/a"
        }
        V{
            "/a"
            "/b"
            "/c"
            "/a/a"
            "/a/b"
            "/b/a"
            "/b/b"
            "/c/a"
            "/c/b"
            "/a/a/a"
            "/a/b/a"
            "/b/a/a"
            "/b/b/a"
            "/c/a/a"
            "/c/b/a"
        }
    }
] if [
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
        ] with-variable

        +breadth-first+ traversal-method [
            "." recursive-directory-files
            current-directory get '[ _ ?head drop ] map
        ] with-variable

        ! Linux doesn't return alphabetic ordering
        os linux? [
            [ [ path-components length ] map ] bi@
        ] when
    ] with-test-directory
] unit-test
