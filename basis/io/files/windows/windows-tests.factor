! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data calendar combinators
concurrency.promises continuations destructors io io.backend io.buffers
io.directories io.encodings.binary io.files io.files.temp io.files.unique
io.files.windows io.pathnames io.pipes io.ports kernel kernel.private
libc literals locals math memory namespaces sequences splitting threads
tools.annotations tools.test vectors windows.errors windows.kernel32
windows.types windows.user32 ;
IN: io.files.windows.tests

! A failed dequeue leaves output storage undefined. Ignore it on timeout.
:: empty-completion ( port entries capacity count timeout alertable -- result )
    123 count 0 ULONG set-alien-value
    WAIT_TIMEOUT SetLastError
    0 ;

{ f } [
    [
        \ GetQueuedCompletionStatusEx [ drop [ empty-completion ] ] annotate
        0 handle-overlapped
    ] [ \ GetQueuedCompletionStatusEx reset ] finally
] unit-test

! Native destinations bypass the staging buffer. Cover partial reads, an
! already buffered prefix, seeking, several direct requests, and EOF.
{ t 65535 131072 t 600000 0 } [| |
    [| path |
        600000 [ 256 mod ] B{ } map-integers-as :> contents
        contents path binary set-file-contents
        [
            path binary <file-reader> &dispose :> input
            700000 malloc &free :> dst
            input stream-read1 0 =
            131072 dst input stream-read-partial-unsafe
            0 seek-absolute input stream-seek
            131072 dst input stream-read-partial-unsafe
            0 seek-absolute input stream-seek
            700000 dst input stream-read-unsafe 600000 assert=
            dst 600000 memory>byte-array contents =
            input stream-tell
            65536 dst input stream-read-unsafe
        ] with-destructors
    ] with-test-file
] unit-test

! Closing an input port with a pending ReadFile must leave its native buffer
! alive until the cancellation packet has been consumed.
{ 1 t 0 } [| |
    [
        (pipe) &dispose :> pipe
        pipe in>> <input-port> &dispose :> input
        pipe out>> <output-port> &dispose drop
        <promise> :> started
        <promise> :> finished
        [
            t started fulfill
            [ input stream-read1 drop f ] [ drop t ] recover finished fulfill
        ] "Windows pending read close" spawn drop
        started 5 seconds ?promise-timeout drop
        10 [ input buffer>> users>> zero? [ yield ] when ] times
        input buffer>> users>>
        input dispose
        finished 5 seconds ?promise-timeout
        input buffer>> users>>
    ] with-destructors
] unit-test

! A burst is handled in bounded batches, including notifications whose owner
! was disposed before the queued packet was consumed.
{ 64 128 130 } [| |
    master-completion-port get-global :> original
    <master-completion-port> :> port
    V{ } clone :> received
    130 [| i | [ i received push ] add-completion-action ] map-integers :> keys
    [
        port master-completion-port set-global
        keys [| key | port 0 key f PostQueuedCompletionStatus win32-error=0/f ] each
        0 handle-overlapped drop received length
        0 handle-overlapped drop received length
        0 handle-overlapped drop received length
        [ ] add-completion-action :> stale
        stale remove-completion-action
        port 0 stale f PostQueuedCompletionStatus win32-error=0/f
        0 handle-overlapped t assert=
        [ "completion action failed" throw ] add-completion-action :> failed
        [ 130 received push ] add-completion-action :> following
        [
            port 0 failed f PostQueuedCompletionStatus win32-error=0/f
            port 0 following f PostQueuedCompletionStatus win32-error=0/f
            [ 0 handle-overlapped drop ]
            [ "completion action failed" = ] must-fail-with
            received length 131 assert=
        ] [ failed remove-completion-action following remove-completion-action ] finally
    ] [
        original master-completion-port set-global
        keys [ remove-completion-action ] each
        port CloseHandle win32-error=0/f
    ] finally
] unit-test

{ f } [ "\\foo" absolute-path? ] unit-test
{ t } [ "\\\\?\\c:\\foo" absolute-path? ] unit-test
{ t } [ "\\\\?\\c:\\" absolute-path? ] unit-test
{ t } [ "\\\\?\\c:" absolute-path? ] unit-test
{ t } [ "c:\\foo" absolute-path? ] unit-test
{ t } [ "c:" absolute-path? ] unit-test
{ t } [ "c:\\" absolute-path? ] unit-test
{ f } [ "/cygdrive/c/builds" absolute-path? ] unit-test

{ "c:\\foo\\" } [ "c:\\foo\\bar" parent-directory ] unit-test
{ "c:\\" } [ "c:\\foo\\" parent-directory ] unit-test
{ "c:\\" } [ "c:\\foo" parent-directory ] unit-test
! { "c:" "c:\\" "c:/" } [ directory ] each -- all do the same thing
{ "c:\\" } [ "c:\\" parent-directory ] unit-test
{ "Z:\\" } [ "Z:\\" parent-directory ] unit-test
{ "c:" } [ "c:" parent-directory ] unit-test
{ "Z:" } [ "Z:" parent-directory ] unit-test

{ f } [ "" root-directory? ] unit-test
{ t } [ "\\" root-directory? ] unit-test
{ t } [ "\\\\" root-directory? ] unit-test
{ t } [ "/" root-directory? ] unit-test
{ t } [ "//" root-directory? ] unit-test
{ t } [ "c:\\" trim-tail-separators root-directory? ] unit-test
{ t } [ "Z:\\" trim-tail-separators root-directory? ] unit-test
{ f } [ "c:\\foo" root-directory? ] unit-test
{ f } [ "." root-directory? ] unit-test
{ f } [ ".." root-directory? ] unit-test
{ t } [ "\\\\?\\c:\\" root-directory? ] unit-test
{ t } [ "\\\\?\\c:" root-directory? ] unit-test
{ f } [ "\\\\?\\c:\\bar" root-directory? ] unit-test

{ "\\\\a\\b\\c\\foo.xls" } [ "//a/b/c/foo.xls" normalize-path ] unit-test
{ "\\\\a\\b\\c\\foo.xls" } [ "\\\\a\\b\\c\\foo.xls" normalize-path ] unit-test

{ "\\foo\\bar" } [ "/foo/bar" normalize-path ":" split1 nip ] unit-test

{ "\\\\?\\C:\\builds\\factor\\log.txt" } [
    "C:\\builds\\factor\\12345\\"
    "..\\log.txt" append-path normalize-path
] unit-test

! A Win32 BOOL of zero is truthy in Factor and must be checked numerically.
[ win32-file new INVALID_HANDLE_VALUE >>handle set-end-of-file ]
[ windows-error? ] must-fail-with

: test-process-handle-count ( -- count )
    GetCurrentProcess 0 DWORD <ref>
    [ GetProcessHandleCount win32-error=0/f ] keep DWORD deref ;

! FindFirstStream search handles must be closed after every enumeration.
{ t } [
    [| path |
        path touch-file
        path file-streams drop
        test-process-handle-count :> before
        20 [ path file-streams drop ] times
        test-process-handle-count before =
    ] with-test-file
] unit-test

{ "\\\\?\\C:\\builds\\" } [
    "C:\\builds\\factor\\12345\\"
    "..\\.." append-path normalize-path
] unit-test

{ "\\\\?\\C:\\builds\\" } [
    "C:\\builds\\factor\\12345\\"
    "..\\.." append-path normalize-path
] unit-test

{ "c:\\blah" } [ "c:\\foo\\bar" "\\blah" append-path ] unit-test
{ t } [ "" resource-path 2 tail file-exists? ] unit-test

! win32-file-attributes
{
    { +read-only+ +hidden+ }
} [
    3 win32-file-attributes
] unit-test

! set-file-attributes & save-image
{ ${ KERNEL-ERROR ERROR-IO EIO f } } [
    [
        "read-only.image" temp-file {
            [ ?delete-file ]
            [ touch-file ]
            [ FILE_ATTRIBUTE_READONLY set-file-attributes ]
            [ save-image ]
        } cleave
    ] [ ] recover
] unit-test

! test that we can open a shared file
! https://github.com/factor/factor/pull/1636
{ } [
    "open-file-" "-test.txt" [
        [ open-write ] [ open-read ] bi [ dispose ] bi@
    ] cleanup-unique-file
] unit-test
