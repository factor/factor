USING: accessors continuations destructors io.backend.unix
io.encodings.ascii io.files io.mmap kernel libc locals math
namespaces sets tools.test unix unix.ffi ;

! mmap on a directory fails after opening it. Both registrations and the
! native file descriptor must be released by the failed constructor.
{ t } [
    [
        disposables get cardinality
        [ "." <mapped-file-reader> dispose ] [ libc-error? ] must-fail-with
        disposables get cardinality =
    ] with-test-directory
] unit-test

! Even when unmapping fails, dispose must close the file descriptor.
! Preserve the real address/length so the test can release the mapping.
{ t } [
    [| path |
        "mapped" path ascii set-file-contents
        path <mapped-file-reader> :> mapped
        mapped address>> :> address
        mapped length>> :> size
        mapped handle>> dup fd? [ handle-fd ] when :> raw-fd
        [
            [ mapped 0 >>length dispose ]
            [ dup libc-error? [ errno>> EINVAL = ] [ drop f ] if ] must-fail-with
            raw-fd F_GETFL 0 fcntl -1 =
        ] [
            address size munmap io-error
            raw-fd F_GETFL 0 fcntl -1 = [ raw-fd close-file ] unless
        ] finally
    ] with-test-file
] unit-test
