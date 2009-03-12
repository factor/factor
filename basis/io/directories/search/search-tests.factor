USING: io.directories.search io.files io.files.unique
io.pathnames kernel namespaces sequences sorting tools.test ;
IN: io.directories.search.tests

[ t ] [
    [
        10 [ "io.paths.test" "gogogo" make-unique-file ] replicate
        current-temporary-directory get [ ] find-all-files
    ] with-unique-directory drop [ natural-sort ] bi@ =
] unit-test
