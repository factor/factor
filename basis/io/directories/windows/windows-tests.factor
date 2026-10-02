USING: accessors calendar combinators concurrency.promises
continuations destructors io io.directories io.encodings.binary
io.encodings.utf8 io.files io.files.temp io.files.unique
io.files.windows io.pathnames kernel locals math namespaces
sequences threads tools.test windows.errors windows.kernel32 ;
IN: io.directories.windows.tests

{ "replacement" t } [| |
    [
        "source-λ.txt" :> source
        "nested/destination-λ.txt" :> destination
        "original" source utf8 set-file-contents
        source destination copy-file
        "replacement" source utf8 set-file-contents
        source destination copy-file
        destination utf8 file-contents
        destination file-exists?
    ] with-test-directory
] unit-test

! The source must remain intact if the caller accidentally copies it to itself.
{ "keep me" } [
    [| path |
        "keep me" path utf8 set-file-contents
        [ path path copy-file ] [ windows-error? ] must-fail-with
        path utf8 file-contents
    ] with-test-file
] unit-test

{ t } [
    [
        "missing" "destination"
        [ copy-file f ] [ 2nip windows-error? ] recover
    ] with-test-directory
] unit-test

! Even a cached native copy must yield to another runnable Factor thread.
{ t t } [| |
    [
        "source" :> source
        "destination" :> destination
        1048576 90 <repetition> B{ } like :> contents
        contents source binary set-file-contents
        <promise> :> ran
        [ t ran fulfill ] "native copy scheduling test" spawn drop
        source destination copy-file
        ran promise-fulfilled?
        destination binary file-contents contents =
    ] with-test-directory
] unit-test

{ { +read-only+ +archive+ } } [
    "read-only.file" temp-file {
        [ ?delete-file ]
        [ touch-file ]
        [
            FILE_ATTRIBUTE_READONLY FILE_ATTRIBUTE_ARCHIVE bitor
            set-file-attributes
        ]
        [
            parent-directory (directory-entries)
            [ name>> "read-only.file" = ] find nip
            attributes>>
        ]
    } cleave
] unit-test
