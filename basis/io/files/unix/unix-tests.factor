USING: accessors arrays calendar destructors grouping io.directories
io.encodings.utf16 io.files io.files.info io.files.info.unix
io.files.unix io.launcher io.pathnames io.ports kernel libc literals
locals math math.bitwise math.functions namespaces sequences
sequences.generalizations strings system tools.test unix unix.ffi
unix.groups unix.users ;
FROM: math.functions => truncate ;

{ "/usr/libexec/" } [ "/usr/libexec/awk/" parent-directory ] unit-test
{ "/etc/" } [ "/etc/passwd" parent-directory ] unit-test
{ "/" } [ "/etc/" parent-directory ] unit-test
{ "/" } [ "/etc" parent-directory ] unit-test
{ "/" } [ "/" parent-directory ] unit-test

{ f } [ "" root-directory? ] unit-test
{ t } [ "/" root-directory? ] unit-test
{ t } [ "//" root-directory? ] unit-test
{ t } [ "///////" root-directory? ] unit-test

{ "/" } [ "/" file-name ] unit-test
{ "///" } [ "///" file-name ] unit-test

{ "/" } [ "/" "../.." append-path ] unit-test
{ "/" } [ "/" "../../" append-path ] unit-test
{ "/lib" } [ "/" "../lib" append-path ] unit-test
{ "/lib/" } [ "/" "../lib/" append-path ] unit-test
{ "/lib" } [ "/" "../../lib" append-path ] unit-test
{ "/lib/" } [ "/" "../../lib/" append-path ] unit-test

{ "/lib" } [ "/usr/" "/lib" append-path ] unit-test
{ "/lib/" } [ "/usr/" "/lib/" append-path ] unit-test
{ "/lib/bux" } [ "/usr" "/lib/bux" append-path ] unit-test
{ "/lib/bux/" } [ "/usr" "/lib/bux/" append-path ] unit-test
{ t } [ "/foo" absolute-path? ] unit-test

[| path |

    { 0o777 } [
        path flags{ USER-ALL GROUP-ALL OTHER-ALL } set-file-permissions
        path file-permissions 0o7777 mask
    ] unit-test

    { t } [ path user-read? ] unit-test
    { t } [ path user-write? ] unit-test
    { t } [ path user-execute? ] unit-test
    { t } [ path group-read? ] unit-test
    { t } [ path group-write? ] unit-test
    { t } [ path group-execute? ] unit-test
    { t } [ path other-read? ] unit-test
    { t } [ path other-write? ] unit-test
    { t } [ path other-execute? ] unit-test

    { 0o776 } [
        path f set-other-execute
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info other-execute? ] unit-test

    { 0o774 } [
        path f set-other-write
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info other-write? ] unit-test

    { 0o770 } [
        path f set-other-read
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info other-read? ] unit-test

    { 0o760 } [
        path f set-group-execute
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info group-execute? ] unit-test

    { 0o740 } [
        path f set-group-write
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info group-write? ] unit-test

    { 0o700 } [
        path f set-group-read
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info group-read? ] unit-test

    { 0o600 } [
        path f set-user-execute
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info other-execute? ] unit-test

    { 0o400 } [
        path f set-user-write
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info other-write? ] unit-test

    { 0o000 } [
        path f set-user-read
        path file-permissions 0o7777 mask
    ] unit-test

    { f } [ path file-info other-read? ] unit-test

    { 0o771 } [
        path flags{ USER-ALL GROUP-ALL OTHER-EXECUTE } set-file-permissions
        path file-permissions 0o7777 mask
    ] unit-test

] with-test-file

[| path |

    { t } [
        path now
        [ set-file-access-time ] 2keep
        [ file-info accessed>> ]
        [ [ [ truncate >integer ] change-second >gmt ] bi@ ] bi* =
    ] unit-test

    { t }
    [
        path now
        [ set-file-modified-time ] 2keep
        [ file-info modified>> ]
        [ [ [ truncate >integer ] change-second >gmt ] bi@ ] bi* =
    ] unit-test

    { t }
    [
        path now [ dup 2array set-file-times ] 2keep
        [ file-info [ modified>> ] [ accessed>> ] bi ] dip
        3array
        [ [ truncate >integer ] change-second >gmt ] map all-equal?
    ] unit-test

    { } [ path f now 2array set-file-times ] unit-test
    { } [ path now f 2array set-file-times ] unit-test
    { } [ path f f 2array set-file-times ] unit-test


    { } [ path real-user-name set-file-user ] unit-test
    { } [ path real-user-id set-file-user ] unit-test
    { } [ path real-group-name set-file-group ] unit-test
    { } [ path real-group-id set-file-group ] unit-test

    { t } [ path file-user-name real-user-name = ] unit-test
    { t } [ path file-group-name real-group-name = ] unit-test

    { } [ path real-user-id real-group-id set-file-ids ] unit-test

    { } [ path f real-group-id set-file-ids ] unit-test

    { } [ path real-user-id f set-file-ids ] unit-test

    { } [ path f f set-file-ids ] unit-test

] with-test-file

{ t } [ 0o4000 uid? ] unit-test
{ t } [ 0o2000 gid? ] unit-test
{ t } [ 0o1000 sticky? ] unit-test
{ t } [ 0o400 user-read? ] unit-test
{ t } [ 0o200 user-write? ] unit-test
{ t } [ 0o100 user-execute? ] unit-test
{ t } [ 0o040 group-read? ] unit-test
{ t } [ 0o020 group-write? ] unit-test
{ t } [ 0o010 group-execute? ] unit-test
{ t } [ 0o004 other-read? ] unit-test
{ t } [ 0o002 other-write? ] unit-test
{ t } [ 0o001 other-execute? ] unit-test

{ f } [ 0 uid? ] unit-test
{ f } [ 0 gid? ] unit-test
{ f } [ 0 sticky? ] unit-test
{ f } [ 0 user-read? ] unit-test
{ f } [ 0 user-write? ] unit-test
{ f } [ 0 user-execute? ] unit-test
{ f } [ 0 group-read? ] unit-test
{ f } [ 0 group-write? ] unit-test
{ f } [ 0 group-execute? ] unit-test
{ f } [ 0 other-read? ] unit-test
{ f } [ 0 other-write? ] unit-test
{ f } [ 0 other-execute? ] unit-test

! (cwd)
{ t } [ 1 (cwd) string? ] unit-test

os linux? [
    { t } [ "/proc/self/exe" read-symbolic-link string? ] unit-test

    ! This file can be opened for writing but rejects SEEK_END. Do not
    ! write any bytes; verify the failing append constructor closes it.
    { t } [
        "/proc/self/fd" directory-files length
        [ "/proc/self/mem" open-append close-file ]
        [ dup unix-system-call-error? [ errno>> EINVAL = ] [ drop f ] if ]
        must-fail-with
        "/proc/self/fd" directory-files length =
    ] unit-test

    ! UTF-16 writes a two-byte BOM in <encoder>. A one-byte output
    ! buffer forces a write during construction; /dev/full rejects it.
    { t } [
        "/proc/self/fd" directory-files length
        [
            1 default-buffer-size [
                "/dev/full" utf16 <file-appender> dispose
            ] with-variable
        ] [ dup libc-error? [ errno>> ENOSPC = ] [ drop f ] if ] must-fail-with
        "/proc/self/fd" directory-files length =
    ] unit-test
] when

"resource:basis/io/files/unix/fixtures/append.factor" run-test-file

[
    vm-path "-i=" image-path append "-no-user-init" "-no-monitors"
    "resource:basis/io/files/unix/fixtures/fifo-run.factor" absolute-path
    5 narray <process> swap >>command 20 seconds >>timeout try-process
] must-not-fail
