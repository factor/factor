USING: accessors combinators io.directories io.files.temp
io.files.windows io.pathnames kernel math sequences tools.test
windows.kernel32 ;

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
