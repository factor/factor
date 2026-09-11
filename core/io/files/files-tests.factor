USING: alien alien.c-types alien.data arrays classes.struct
compiler.units continuations destructors generic.single io
io.backend io.directories io.encodings io.encodings.ascii
io.encodings.binary io.encodings.latin1 io.encodings.string
io.encodings.utf16 io.encodings.utf8 io.files io.files.private
io.pathnames kernel locals make math namespaces sequences sets
specialized-arrays system threads tools.test vocabs ;
FROM: specialized-arrays.private => specialized-array-vocab ;
FROM: namespaces => set ;
IN: io.files.tests

! UTF-16 reads its BOM in <decoder>, after the file has already opened.
! A missing BOM must release the reader, buffer, and native handle.
{ t } [
    [| path |
        "no BOM" path ascii set-file-contents
        disposables get cardinality
        [ path utf16 <file-reader> dispose ] [ missing-bom? ] must-fail-with
        disposables get cardinality =
    ] with-test-file
] unit-test

SINGLETON: failing-file-encoding

M: failing-file-encoding <encoder>
    2drop "file encoder failed" throw ;

:: file-constructor-cleans-up? ( quot -- ? )
    [| path |
        path delete-file
        disposables get cardinality
        [ path failing-file-encoding quot call( path encoding -- stream ) dispose ]
        [ "file encoder failed" = ] must-fail-with
        disposables get cardinality =
    ] with-test-file ;

{ { t t t } } [
    { [ <file-writer> ] [ <file-writer-secure> ] [ <file-appender> ] }
    [ file-constructor-cleans-up? ] map
] unit-test

:: rewrite-file-lines ( text encoding quot -- text' )
    [| path |
        text path encoding set-file-contents
        path encoding quot change-file-lines
        path encoding file-contents
    ] with-test-file ; inline

{ t } [
    {
        "" "a" "a\n" "a\r\n" "a\r" "a\n\n" "\r\n"
        "a\r\nb\nc\rd" "日本語\r\n🍆\r\n" "a\u000085b\u002028c\n"
    } [ dup utf8 [ ] rewrite-file-lines = ] all?
] unit-test

{ "a!\r\nb!\r\n" } [
    "a\r\nb\r\n" utf8 [ [ "!" append ] map ] rewrite-file-lines
] unit-test

{ "a!\r\nb!" } [
    "a\r\nb" utf8 [ [ "!" append ] map ] rewrite-file-lines
] unit-test

{ "a!\r\nb!\nc!\r" } [
    "a\r\nb\nc\r" utf8 [ [ "!" append ] map ] rewrite-file-lines
] unit-test

{ "a\r\nb\r\nc\r\n" } [
    "a\r\nb\r\n" utf8 [ "c" suffix ] rewrite-file-lines
] unit-test

{ "a\nb" } [ "a" utf8 [ "b" suffix ] rewrite-file-lines ] unit-test
{ "a\n" } [ "" utf8 [ "a" suffix ] rewrite-file-lines ] unit-test
{ "" } [ "a\r\nb\r\n" utf8 [ drop { } ] rewrite-file-lines ] unit-test

! The quotation sees the same lines as file-lines, including binary CRs.
{ "a\r\nb\r\n" } [
    "a\r\nb\r\n" utf8 [ dup { "a" "b" } assert= ] rewrite-file-lines
] unit-test

{ B{ 97 13 10 98 13 10 } } [
    B{ 97 13 10 98 13 10 } binary
    [ dup { B{ 97 13 } B{ 98 13 } } assert= ] rewrite-file-lines
] unit-test

:: unchanged-line-bytes? ( encoding -- ? )
    [| path |
        "日本語\r\n🍆\r\n" path encoding set-file-contents
        path binary file-contents
        path encoding [ ] change-file-lines
        path binary file-contents =
    ] with-test-file ;

{ t } [ { utf8 utf16 utf16le utf16be } [ unchanged-line-bytes? ] all? ] unit-test

! A failed transformation must not truncate the source file.
{ "original\r\n" } [
    [| path |
        "original\r\n" path utf8 set-file-contents
        [ path utf8 [ drop "failed" throw ] change-file-lines ] [ drop ] recover
        path utf8 file-contents
    ] with-test-file
] unit-test

! Preserve the combinator's data-stack threading contract.
{ 42 "prefix:a\r\n" } [
    [| path |
        "a\r\n" path utf8 set-file-contents
        42 "prefix:" path utf8 [ swap [ prepend ] curry map ] change-file-lines
        path utf8 file-contents
    ] with-test-file
] unit-test

SPECIALIZED-ARRAY: int

{ } [
    [ ascii <file-appender> dispose ] with-test-file
] unit-test

{
    "This is a line.\rThis is another line.\r"
} [
    "vocab:io/test/mac-os-eol.txt" latin1
    [ 500 read ] with-file-reader
] unit-test

{
    255
} [
    "vocab:io/test/binary.txt" latin1
    [ read1 ] with-file-reader >fixnum
] unit-test

{
    "This" CHAR: \s
} [
    "vocab:io/test/read-until-test.txt" ascii
    [ " " read-until ] with-file-reader
] unit-test

{
    "This" CHAR: \s
} [
    "vocab:io/test/read-until-test.txt" binary
    [ " " read-until [ ascii decode ] dip ] with-file-reader
] unit-test

[| path |
    { } [
        "It seems Jobs has lost his grasp on reality again.\n"
        path latin1 set-file-contents
    ] unit-test

    {
        {
            { "It seems " CHAR: J }
            { "obs has lost h" CHAR: i }
            { "s grasp on reality again.\n" f }
        }
    } [
        [
            path latin1 [
                "J" read-until 2array ,
                "i" read-until 2array ,
                "X" read-until 2array ,
            ] with-file-reader
        ] { } make
    ] unit-test
] with-test-file

{ } [
    image-path binary [
        10 [ 65536 read drop ] times
    ] with-file-reader
] unit-test

! Writing specialized arrays to binary streams should work
[| path |
    { } [
        path binary [
            int-array{ 1 2 3 } write
        ] with-file-writer
    ] unit-test

    { int-array{ 1 2 3 } } [
        path binary [
            3 4 * read
        ] with-file-reader
        int cast-array
    ] unit-test
] with-test-file

[| path |
    { } [
        BV{ 0 1 2 } path binary set-file-contents
    ] unit-test

    { t } [
        path binary file-contents
        B{ 0 1 2 } =
    ] unit-test
] with-test-file

STRUCT: pt { x uint } { y uint } ;
SPECIALIZED-ARRAY: pt

CONSTANT: pt-array-1
    pt-array{ S{ pt f 1 1 } S{ pt f 2 2 } S{ pt f 3 3 } }

[| path |
    { } [
        pt-array-1 path binary set-file-contents
    ] unit-test

    { t } [
        path binary file-contents
        pt-array-1 >c-ptr sequence=
    ] unit-test
] with-test-file

! Slices should support >c-ptr and byte-length
[| path |
    { } [
        pt-array-1 rest-slice
        path binary set-file-contents
    ] unit-test

    { t } [
        path binary file-contents
        pt cast-array
        pt-array-1 rest-slice sequence=
    ] unit-test
] with-test-file

{ } [
    [
        pt specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test

! Writing strings to binary streams should fail
[| path |
    [
        path binary [ "OMGFAIL" write ] with-file-writer
    ] must-fail
] with-test-file

! Test EOF behavior
{ 10 } [
    image-path binary [
        0 read drop
        10 read length
    ] with-file-reader
] unit-test

! Make sure that writing to a closed stream from another thread doesn't crash
[
    { } [ "test.txt" ascii [ [ yield "Hi" write ] "Test-write-file" spawn drop ] with-file-writer ] unit-test

    { } [ "test.txt" delete-file ] unit-test

    { } [ "test.txt" ascii [ [ yield "Hi" write ] "Test-write-file" spawn drop ] with-file-writer ] unit-test

    { } [ "test.txt" "test2.txt" move-file ] unit-test

    { t } [ "test2.txt" file-exists? ] unit-test

    { "test2.txt" } [ "test2.txt" check-file-exists ] unit-test

    { } [ "test2.txt" delete-file ] unit-test

    [ "test2.txt" check-file-exists ] [ no-such-file? ] must-fail-with
] with-test-directory

! File seeking tests
[| path |
    { B{ 3 2 3 4 5 } } [
        path binary [
            B{ 1 2 3 4 5 } write
            tell-output 5 assert=
            0 seek-absolute seek-output
            tell-output 0 assert=
            B{ 3 } write
            tell-output 1 assert=
        ] with-file-writer path binary file-contents
    ] unit-test
] with-test-file

[| path |
    { B{ 1 2 3 4 3 } } [
        path binary [
            B{ 1 2 3 4 5 } write
            tell-output 5 assert=
            -1 seek-relative seek-output
            tell-output 4 assert=
            B{ 3 } write
            tell-output 5 assert=
        ] with-file-writer path binary file-contents
    ] unit-test
] with-test-file

[| path |
    { B{ 1 2 3 4 5 0 3 } } [
        path binary [
            B{ 1 2 3 4 5 } write
            tell-output 5 assert=
            1 seek-relative seek-output
            tell-output 6 assert=
            B{ 3 } write
            tell-output 7 assert=
        ] with-file-writer path binary file-contents
    ] unit-test
] with-test-file

[| path |
    { B{ 3 } } [
        B{ 1 2 3 4 5 } path binary set-file-contents
        path binary [
            tell-input 0 assert=
            -3 seek-end seek-input
            tell-input 2 assert=
            1 read
            tell-input 3 assert=
        ] with-file-reader
    ] unit-test
] with-test-file

[| path |

    { B{ 2 } } [
        B{ 1 2 3 4 5 } path binary set-file-contents
        path binary [
            tell-input 0 assert=
            3 seek-absolute seek-input
            tell-input 3 assert=
            -2 seek-relative seek-input
            tell-input 1 assert=
            1 read
            tell-input 2 assert=
        ] with-file-reader
    ] unit-test
] with-test-file

[
    "does-not-exist" binary [
        -10 seek-absolute seek-input
    ] with-file-reader
] must-fail

{ } [
    "resource:LICENSE.txt" binary [
        44 read drop
        tell-input 44 assert=
        -44 seek-relative seek-input
        tell-input 0 assert=
    ] with-file-reader
] unit-test

[| path |
    [ path ascii [ { 129 } write ] with-file-writer ]
    [ encode-error? ] must-fail-with
] with-test-file

[| path |
    { }
    [ path ascii [ { } write ] with-file-writer ] unit-test
] with-test-file

[| path |
    [ path binary [ "" write ] with-file-writer ]
    [ no-method? ] must-fail-with
] with-test-file

! What happens if we close a file twice?
[
    "closing-twice" ascii <file-writer>
    [ dispose ] [ dispose ] bi
] with-test-directory

{ f t t } [
    [
        "resource:core" normalize-path
        [ cwd = ] [ cd ] [ cwd = ] tri
    ] cwd '[ _ dup cd cwd = ] finally
] unit-test

{ t } [
    [
        [ 0 1 "å" <slice> swap utf8 set-file-contents ]
        [ utf8 file-contents ] bi "å" =
    ] with-test-file
] unit-test

{ t } [
    [
        [ 0 1 "å" <slice> swap utf16 set-file-contents ]
        [ utf16 file-contents ] bi "å" =
    ] with-test-file
] unit-test

{ t } [
    [
        [ 0 1 "a" <slice> swap ascii set-file-contents ]
        [ ascii file-contents ] bi "a" =
    ] with-test-file
] unit-test

{ f } [ f file-exists? ] unit-test

{ } [
    "should-never-exist" [ drop t ] when-file-exists
] unit-test

{ t } [
    [ [ drop t ] when-file-exists ] with-test-file
] unit-test

{ t } [
    "should-never-exist" [ drop t ] unless-file-exists
] unit-test

{ } [
    [ [ drop t ] unless-file-exists ] with-test-file
] unit-test

: ife-bool ( path -- bool )
    [ drop t ] [ drop f ] if-file-exists ;

{ t } [ [ ife-bool ] with-test-file ] unit-test

{ f } [ "should-never-exist" ife-bool ] unit-test

{ 0 t 0 } [
    "resource:LICENSE.txt" binary [
        tell-input input-stream get stream-seekable? tell-input
    ] with-file-reader
] unit-test
