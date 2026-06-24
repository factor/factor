! Copyright (C) 2026 erg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct combinators destructors
io.uring kernel literals locals tools.test unix.linux.io-uring ;
IN: io.uring.tests

{ 64 } [ io-uring-sqe heap-size ] unit-test
{ 16 } [ io-uring-cqe heap-size ] unit-test
{ 40 } [ io-sqring-offsets heap-size ] unit-test
{ 40 } [ io-cqring-offsets heap-size ] unit-test
{ 120 } [ io-uring-params heap-size ] unit-test
{ 32 } [ io-uring-attr-pi heap-size ] unit-test
{ 16 } [ io-uring-files-update heap-size ] unit-test
{ 64 } [ io-uring-region-desc heap-size ] unit-test
{ 32 } [ io-uring-mem-region-reg heap-size ] unit-test
{ 32 } [ io-uring-rsrc-register heap-size ] unit-test
{ 16 } [ io-uring-rsrc-update heap-size ] unit-test
{ 32 } [ io-uring-rsrc-update2 heap-size ] unit-test
{ 8 } [ io-uring-probe-op heap-size ] unit-test
{ 16 } [ io-uring-probe heap-size ] unit-test
{ 16 } [ io-uring-restriction heap-size ] unit-test
{ 16 } [ io-uring-task-restriction heap-size ] unit-test
{ 16 } [ io-uring-clock-register heap-size ] unit-test
{ 32 } [ io-uring-clone-buffers heap-size ] unit-test
{ 16 } [ io-uring-buf heap-size ] unit-test
{ 16 } [ io-uring-buf-ring heap-size ] unit-test
{ 40 } [ io-uring-buf-reg heap-size ] unit-test
{ 40 } [ io-uring-buf-status heap-size ] unit-test
{ 16 } [ io-uring-napi heap-size ] unit-test
{ 16 } [ io-timespec heap-size ] unit-test
{ 64 } [ io-uring-reg-wait heap-size ] unit-test
{ 24 } [ io-uring-getevents-arg heap-size ] unit-test
{ 64 } [ io-uring-sync-cancel-reg heap-size ] unit-test
{ 16 } [ io-uring-file-index-range heap-size ] unit-test
{ 16 } [ io-uring-recvmsg-out heap-size ] unit-test
{ 40 } [ io-uring-query-hdr heap-size ] unit-test
{ 48 } [ io-uring-query-opcode heap-size ] unit-test
{ 40 } [ io-uring-query-zcrx heap-size ] unit-test
{ 16 } [ io-uring-query-scq heap-size ] unit-test
{ 16 } [ io-uring-zcrx-rqe heap-size ] unit-test
{ 16 } [ io-uring-zcrx-cqe heap-size ] unit-test
{ 32 } [ io-uring-zcrx-offsets heap-size ] unit-test
{ 48 } [ io-uring-zcrx-area-reg heap-size ] unit-test
{ 96 } [ io-uring-zcrx-ifq-reg heap-size ] unit-test
{ 48 } [ zcrx-ctrl-flush-rq heap-size ] unit-test
{ 48 } [ zcrx-ctrl-export heap-size ] unit-test
{ 72 } [ zcrx-ctrl heap-size ] unit-test
{ 40 } [ io-uring-bpf-ctx heap-size ] unit-test
{ 64 } [ io-uring-bpf-filter heap-size ] unit-test
{ 72 } [ io-uring-bpf heap-size ] unit-test
{ 80 } [ io-uring-mock-probe heap-size ] unit-test
{ 128 } [ io-uring-mock-create heap-size ] unit-test

{ $[ IORING_OP_READ_FIXED ] 5 77 } [
    io-uring-sqe <struct>
    dup 10 f 20 30 5 77 io-uring-prep-read-fixed
    [ opcode>> ] [ buf-index>> ] [ user-data>> ] tri
] unit-test

{ $[ IORING_OP_OPENAT ] 8 8 10 } [
    io-uring-sqe <struct>
    dup 9 f 8 420 7 10 io-uring-prep-openat-direct
    { [ opcode>> ] [ rw-flags>> ] [ file-index>> ] [ user-data>> ] } cleave
] unit-test

{ $[ IORING_OP_TIMEOUT ] $[ IORING_TIMEOUT_ABS ] 4 9 } [
    io-uring-sqe <struct>
    dup f 4 IORING_TIMEOUT_ABS 9 io-uring-prep-timeout
    { [ opcode>> ] [ rw-flags>> ] [ off>> ] [ user-data>> ] } cleave
] unit-test

{ $[ IORING_OP_SEND_ZC ] $[ IORING_RECVSEND_FIXED_BUF ] 12 123 } [
    io-uring-sqe <struct>
    dup 5 f 10 0 0 12 123 io-uring-prep-send-zc-fixed
    { [ opcode>> ] [ ioprio>> ] [ buf-index>> ] [ user-data>> ] } cleave
] unit-test

{ $[ IORING_OP_MSG_RING ] $[ IORING_MSG_SEND_FD ] 44 8 55 99 } [
    io-uring-sqe <struct>
    dup 3 44 7 55 0 99 io-uring-prep-msg-ring-fd
    { [ opcode>> ] [ addr>> ] [ addr3>> ] [ file-index>> ] [ off>> ] [ user-data>> ] } cleave
] unit-test

:: smoke-prep ( quot: ( sqe -- ) -- )
    io-uring-sqe <struct> quot call( sqe -- ) ;

{ t } [
    [ IORING_OP_READ swap 1 f 2 3 4 io-uring-prep-rw-alien ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-read-alien ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-write-alien ] smoke-prep
    [ 1 f 2 3 4 5 io-uring-prep-read-fixed-alien ] smoke-prep
    [ 1 f 2 3 4 5 io-uring-prep-write-fixed-alien ] smoke-prep
    [ 1 io-uring-prep-nop-alien ] smoke-prep
    [ IORING_OP_READ swap 1 f 2 3 4 io-uring-prep-rw ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-read ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-write ] smoke-prep
    [ 1 io-uring-prep-nop ] smoke-prep
    [ 1 io-uring-prep-nop128 ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-readv ] smoke-prep
    [ 1 f 2 3 4 5 io-uring-prep-readv2 ] smoke-prep
    [ 1 f 2 3 4 5 6 io-uring-prep-readv-fixed ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-writev ] smoke-prep
    [ 1 f 2 3 4 5 io-uring-prep-writev2 ] smoke-prep
    [ 1 f 2 3 4 5 6 io-uring-prep-writev-fixed ] smoke-prep
    [ 1 f 2 3 4 5 io-uring-prep-read-fixed ] smoke-prep
    [ 1 f 2 3 4 5 io-uring-prep-write-fixed ] smoke-prep
    [ 1 2 3 io-uring-prep-fsync ] smoke-prep
    [ 1 2 3 io-uring-prep-poll-add ] smoke-prep
    [ 1 2 3 io-uring-prep-poll-multishot ] smoke-prep
    [ 1 2 io-uring-prep-poll-remove ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-poll-update ] smoke-prep
    [ f 1 2 3 io-uring-prep-timeout ] smoke-prep
    [ 1 2 3 io-uring-prep-timeout-remove ] smoke-prep
    [ f 1 2 3 io-uring-prep-timeout-update ] smoke-prep
    [ f 1 2 io-uring-prep-link-timeout ] smoke-prep
    [ 1 f f 2 3 io-uring-prep-accept ] smoke-prep
    [ 1 f f 2 3 4 io-uring-prep-accept-direct ] smoke-prep
    [ 1 f f 2 3 io-uring-prep-multishot-accept ] smoke-prep
    [ 1 f f 2 3 io-uring-prep-multishot-accept-direct ] smoke-prep
    [ 1 2 3 io-uring-prep-cancel64 ] smoke-prep
    [ 1 2 3 io-uring-prep-cancel-fd ] smoke-prep
    [ 1 f 2 3 io-uring-prep-connect ] smoke-prep
    [ 1 f 2 3 io-uring-prep-bind ] smoke-prep
    [ 1 2 3 io-uring-prep-listen ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-epoll-wait ] smoke-prep
    [ f 1 2 3 io-uring-prep-files-update ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-fallocate ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-openat ] smoke-prep
    [ 1 f 2 3 4 5 io-uring-prep-openat-direct ] smoke-prep
    [ f 1 2 3 io-uring-prep-open ] smoke-prep
    [ f 1 2 3 4 io-uring-prep-open-direct ] smoke-prep
    [ 1 f f 2 3 io-uring-prep-openat2 ] smoke-prep
    [ 1 f f 2 3 4 io-uring-prep-openat2-direct ] smoke-prep
    [ 1 2 io-uring-prep-close ] smoke-prep
    [ 1 2 io-uring-prep-close-direct ] smoke-prep
    [ 1 f 2 3 f 4 io-uring-prep-statx ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-read-multishot ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-fadvise ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-fadvise64 ] smoke-prep
    [ f 1 2 3 io-uring-prep-madvise ] smoke-prep
    [ f 1 2 3 io-uring-prep-madvise64 ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-send ] smoke-prep
    [ 1 2 3 4 io-uring-prep-send-bundle ] smoke-prep
    [ f 1 io-uring-prep-send-set-addr ] smoke-prep
    [ 1 f 2 3 f 4 5 io-uring-prep-sendto ] smoke-prep
    [ 1 f 2 3 4 5 io-uring-prep-send-zc ] smoke-prep
    [ 1 f 2 3 4 5 6 io-uring-prep-send-zc-fixed ] smoke-prep
    [ 1 f 2 3 io-uring-prep-sendmsg ] smoke-prep
    [ 1 f 2 3 io-uring-prep-sendmsg-zc ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-sendmsg-zc-fixed ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-recv ] smoke-prep
    [ 1 f 2 3 4 io-uring-prep-recv-multishot ] smoke-prep
    [ 1 f 2 3 io-uring-prep-recvmsg ] smoke-prep
    [ 1 f 2 3 io-uring-prep-recvmsg-multishot ] smoke-prep
    [ 1 2 3 f 4 io-uring-prep-epoll-ctl ] smoke-prep
    [ 1 2 3 4 5 6 7 io-uring-prep-splice ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-tee ] smoke-prep
    [ f 1 2 3 4 5 io-uring-prep-provide-buffers ] smoke-prep
    [ 1 2 3 io-uring-prep-remove-buffers ] smoke-prep
    [ 1 2 3 io-uring-prep-shutdown ] smoke-prep
    [ 1 f 2 f 3 4 io-uring-prep-renameat ] smoke-prep
    [ f f 1 io-uring-prep-rename ] smoke-prep
    [ 1 f 2 3 io-uring-prep-unlinkat ] smoke-prep
    [ f 1 2 io-uring-prep-unlink ] smoke-prep
    [ 1 f 2 3 io-uring-prep-mkdirat ] smoke-prep
    [ f 1 2 io-uring-prep-mkdir ] smoke-prep
    [ f 1 f 2 io-uring-prep-symlinkat ] smoke-prep
    [ f f 1 io-uring-prep-symlink ] smoke-prep
    [ 1 f 2 f 3 4 io-uring-prep-linkat ] smoke-prep
    [ f f 1 2 io-uring-prep-link ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-msg-ring ] smoke-prep
    [ 1 2 3 4 5 6 io-uring-prep-msg-ring-cqe-flags ] smoke-prep
    [ 1 2 3 4 5 6 io-uring-prep-msg-ring-fd ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-msg-ring-fd-alloc ] smoke-prep
    [ f f f 1 2 io-uring-prep-getxattr ] smoke-prep
    [ f f f 1 2 3 io-uring-prep-setxattr ] smoke-prep
    [ 1 f f 2 3 io-uring-prep-fgetxattr ] smoke-prep
    [ 1 f f 2 3 4 io-uring-prep-fsetxattr ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-socket ] smoke-prep
    [ 1 2 3 4 5 6 io-uring-prep-socket-direct ] smoke-prep
    [ 1 2 3 4 5 io-uring-prep-socket-direct-alloc ] smoke-prep
    [ 1 2 3 io-uring-prep-uring-cmd ] smoke-prep
    [ 1 2 3 io-uring-prep-uring-cmd128 ] smoke-prep
    [ 1 2 3 4 f 5 6 io-uring-prep-cmd-sock ] smoke-prep
    [ 1 f f 2 3 io-uring-prep-cmd-getsockname ] smoke-prep
    [ 1 2 f 3 4 5 io-uring-prep-waitid ] smoke-prep
    [ f 1 2 3 4 5 io-uring-prep-futex-wake ] smoke-prep
    [ f 1 2 3 4 5 io-uring-prep-futex-wait ] smoke-prep
    [ f 1 2 3 io-uring-prep-futex-waitv ] smoke-prep
    [ 1 2 3 io-uring-prep-fixed-fd-install ] smoke-prep
    [ 1 2 3 io-uring-prep-ftruncate ] smoke-prep
    [ 1 2 3 4 io-uring-prep-cmd-discard ] smoke-prep
    [ f 1 2 io-uring-prep-pipe ] smoke-prep
    [ f 1 2 3 io-uring-prep-pipe-direct ] smoke-prep
    t
] unit-test

:: io-uring-nop-test ( -- ? )
    [
        8 <io-uring> &dispose :> ring
        ring io-uring-get-sqe :> sqe
        sqe 12345 io-uring-prep-nop
        ring 1 io-uring-submit-and-wait drop
        ring io-uring-wait-cqe :> cqe
        cqe user-data>> 12345 =
        cqe res>> 0 = and
        ring cqe io-uring-cqe-seen
    ] with-destructors ;

:: io-uring-completion-test ( -- ? )
    [
        8 <io-uring> &dispose :> ring
        ring 6789 io-uring-queue-nop
        ring io-uring-sq-ready 1 = :> queued?
        ring io-uring-submit-and-wait-completion :> completion
        completion user-data>> 6789 =
        completion io-uring-completion-result 0 = and
        queued? and
    ] with-destructors ;

:: io-uring-queue-test ( -- ? )
    [
        8 <io-uring> &dispose :> ring
        ring 1 f 2 3 4 io-uring-queue-read
        ring 1 f 2 3 5 io-uring-queue-write
        ring 1 f 2 3 0 6 io-uring-queue-read-fixed
        ring 1 f 2 3 0 7 io-uring-queue-write-fixed
        ring io-uring-sq-ready 4 =
    ] with-destructors ;

{ t } [
    io-uring-available? [ io-uring-nop-test ] [ t ] if
] unit-test

{ t } [
    io-uring-available? [ io-uring-completion-test ] [ t ] if
] unit-test

{ t } [
    io-uring-available? [ io-uring-queue-test ] [ t ] if
] unit-test
