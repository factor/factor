USING: io.paths kernel tools.test io.files.unique sequences
io.files namespaces sorting ;
IN: io.paths.tests

[ t ] [
    [
        10 [ "io.paths.test" "gogogo" make-unique-file* ] replicate
        current-directory get t [ ] find-all-files
    ] with-unique-directory
    [ natural-sort ] bi@ =
] unit-test
