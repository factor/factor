! Copyright (C) 2026 erg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays classes.struct
combinators continuations destructors kernel libc locals math math.bitwise
math.order sequences unix unix.ffi unix.linux.io-uring ;
IN: io.uring

TUPLE: io-uring < disposable
    fd params
    sq-ring sq-ring-size cq-ring cq-ring-size
    sqes sqes-size sqe-entry-size cqe-entry-size
    sq-head sq-tail sq-ring-mask sq-ring-entries sq-flags
    sq-dropped sq-array
    cq-head cq-tail cq-ring-mask cq-ring-entries cq-overflow
    cq-cqes ;

: alien+ ( c-ptr n -- c-ptr' ) swap <displaced-alien> ; inline

: u32@ ( alien -- n ) uint32_t deref ; inline

: u32! ( n alien -- ) 0 uint32_t set-alien-value ; inline

: uchar-at@ ( alien offset -- n ) uchar alien-value ; inline

: ushort-at@ ( alien offset -- n ) ushort alien-value ; inline

: i32-at@ ( alien offset -- n ) int32_t alien-value ; inline

: u32-at@ ( alien offset -- n ) uint32_t alien-value ; inline

: u64-at@ ( alien offset -- n ) uint64_t alien-value ; inline

: uchar-at! ( n alien offset -- ) uchar set-alien-value ; inline

: ushort-at! ( n alien offset -- ) ushort set-alien-value ; inline

: int-at! ( n alien offset -- ) int set-alien-value ; inline

: u32-at! ( n alien offset -- ) uint32_t set-alien-value ; inline

: u64-at! ( n alien offset -- ) uint64_t set-alien-value ; inline

: ptr>u64 ( c-ptr/f -- n )
    dup [ >c-ptr alien-address ] [ drop 0 ] if ; inline

: flag-set? ( value flag -- ? ) bitand zero? not ; inline

:: mmap-uring ( fd size offset -- alien )
    f size PROT_READ PROT_WRITE bitor MAP_SHARED fd offset mmap
    dup MAP_FAILED = [ throw-errno ] when ;

: munmap-uring ( alien/f size -- )
    over [
        dup zero? [ 2drop ] [ munmap io-error ] if
    ] [ 2drop ] if ;

M: io-uring dispose*
    {
        [ [ sqes>> ] [ sqes-size>> ] bi munmap-uring ]
        [ [ cq-ring>> ] [ cq-ring-size>> ] bi munmap-uring ]
        [ [ sq-ring>> ] [ sq-ring-size>> ] bi munmap-uring ]
        [ fd>> [ close-file ] when* ]
    } cleave ;

:: sq-ring-size ( params -- n )
    params sq-off>> array>>
    params sq-entries>> uint32_t heap-size * + ;

:: cq-ring-size ( params -- n )
    params cq-off>> cqes>>
    params cq-entries>>
    params flags>> IORING_SETUP_CQE32 flag-set?
    [ io-uring-cqe heap-size 2 * ] [ io-uring-cqe heap-size ] if
    * + ;

:: sqes-size ( params -- n )
    params sq-entries>>
    params flags>> IORING_SETUP_SQE128 flag-set?
    [ io-uring-sqe heap-size 2 * ] [ io-uring-sqe heap-size ] if
    * ;

: sqe-entry-size ( params -- n )
    flags>> IORING_SETUP_SQE128 flag-set?
    [ io-uring-sqe heap-size 2 * ] [ io-uring-sqe heap-size ] if ;

: cqe-entry-size ( params -- n )
    flags>> IORING_SETUP_CQE32 flag-set?
    [ io-uring-cqe heap-size 2 * ] [ io-uring-cqe heap-size ] if ;

:: map-rings ( ring -- )
    ring fd>> :> fd
    ring params>> :> params
    params sq-ring-size :> sq-size
    params cq-ring-size :> cq-size
    params features>> IORING_FEAT_SINGLE_MMAP flag-set? [
        sq-size cq-size max :> ring-size
        fd ring-size IORING_OFF_SQ_RING mmap-uring
        [ ring sq-ring<< ] [ ring cq-ring<< ] bi
        ring-size ring sq-ring-size<<
        0 ring cq-ring-size<<
    ] [
        fd sq-size IORING_OFF_SQ_RING mmap-uring ring sq-ring<<
        sq-size ring sq-ring-size<<
        fd cq-size IORING_OFF_CQ_RING mmap-uring ring cq-ring<<
        cq-size ring cq-ring-size<<
    ] if
    params sqe-entry-size ring sqe-entry-size<<
    params cqe-entry-size ring cqe-entry-size<<
    params sqes-size :> sqes-bytes
    fd sqes-bytes IORING_OFF_SQES mmap-uring ring sqes<<
    sqes-bytes ring sqes-size<< ;

:: ptr-at ( base offset -- alien ) base offset alien+ ; inline

:: init-ring-pointers ( ring -- )
    ring sq-ring>> :> sq
    ring cq-ring>> :> cq
    ring params>> sq-off>> :> sq-off
    ring params>> cq-off>> :> cq-off
    sq sq-off head>> ptr-at ring sq-head<<
    sq sq-off tail>> ptr-at ring sq-tail<<
    sq sq-off ring-mask>> ptr-at ring sq-ring-mask<<
    sq sq-off ring-entries>> ptr-at ring sq-ring-entries<<
    sq sq-off flags>> ptr-at ring sq-flags<<
    sq sq-off dropped>> ptr-at ring sq-dropped<<
    sq sq-off array>> ptr-at ring sq-array<<
    cq cq-off head>> ptr-at ring cq-head<<
    cq cq-off tail>> ptr-at ring cq-tail<<
    cq cq-off ring-mask>> ptr-at ring cq-ring-mask<<
    cq cq-off ring-entries>> ptr-at ring cq-ring-entries<<
    cq cq-off overflow>> ptr-at ring cq-overflow<<
    cq cq-off cqes>> ptr-at ring cq-cqes<< ;

:: <io-uring-flags> ( entries flags -- ring )
    io-uring-params <struct> flags >>flags :> params
    entries params io_uring_setup dup io-error :> fd
    io-uring new-disposable
        fd >>fd
        params >>params :> ring
    [
        ring map-rings
        ring init-ring-pointers
        ring
    ] [
        ring dispose rethrow
    ] recover ;

: <io-uring> ( entries -- ring ) 0 <io-uring-flags> ;

: io-uring-available? ( -- ? )
    [
        [ 2 <io-uring> &dispose drop ] with-destructors
        t
    ] [ drop f ] recover ;

: pending-sqes ( ring -- n )
    [ sq-tail>> u32@ ] [ sq-head>> u32@ ] bi - ;

: cq-ready ( ring -- n )
    [ cq-tail>> u32@ ] [ cq-head>> u32@ ] bi - ;

: sq-full? ( ring -- ? )
    [ pending-sqes ] [ sq-ring-entries>> u32@ ] bi >= ;

: io-uring-sq-ready ( ring -- n )
    pending-sqes ;

: io-uring-cq-ready ( ring -- n )
    cq-ready ;

: io-uring-sq-full? ( ring -- ? )
    sq-full? ;

:: sqe-alien-at ( ring index -- sqe )
    ring sqes>> index ring sqe-entry-size>> * alien+ ;

:: cqe-alien-at ( ring index -- cqe )
    ring cq-cqes>> index ring cqe-entry-size>> * alien+ ;

:: set-sq-array ( ring index -- )
    index
    ring sq-array>> index uint32_t heap-size * alien+
    u32! ;

:: io-uring-get-sqe-alien ( ring -- sqe/f )
    ring sq-full? [
        f
    ] [
        ring sq-tail>> u32@ :> tail
        tail ring sq-ring-mask>> u32@ bitand :> index
        ring index sqe-alien-at :> sqe
        sqe 0 ring sqe-entry-size>> memset
        ring index set-sq-array
        tail 1 + ring sq-tail>> u32!
        sqe
    ] if ;

: io-uring-get-sqe ( ring -- sqe/f )
    io-uring-get-sqe-alien
    [ io-uring-sqe memory>struct ] [ f ] if* ;

:: io-uring-peek-cqe-alien ( ring -- cqe/f )
    ring cq-ready zero? [
        f
    ] [
        ring cq-head>> u32@ ring cq-ring-mask>> u32@ bitand
        ring swap cqe-alien-at
    ] if ;

: io-uring-peek-cqe ( ring -- cqe/f )
    io-uring-peek-cqe-alien
    [ io-uring-cqe memory>struct ] [ f ] if* ;

CONSTANT: cqe-user-data-offset 0
CONSTANT: cqe-res-offset 8
CONSTANT: cqe-flags-offset 12

: io-uring-cqe-nr ( cqe -- n )
    >c-ptr cqe-flags-offset u32-at@ IORING_CQE_F_32 flag-set?
    [ 2 ] [ 1 ] if ;

: io-uring-cq-advance ( ring n -- )
    swap [ cq-head>> u32@ + ] [ cq-head>> ] bi u32! ;

: io-uring-cqe-seen ( ring cqe -- )
    io-uring-cqe-nr io-uring-cq-advance ;

:: io-uring-enter ( ring to-submit min-complete flags -- n )
    ring fd>> to-submit min-complete flags f 0 io_uring_enter
    dup io-error ;

:: io-uring-register ( ring opcode arg nr-args -- n )
    ring fd>> opcode arg nr-args io_uring_register dup io-error ;

:: io-uring-register-buffers ( ring iovecs nr-args -- n )
    ring IORING_REGISTER_BUFFERS iovecs nr-args io-uring-register ;

:: io-uring-unregister-buffers ( ring -- n )
    ring IORING_UNREGISTER_BUFFERS f 0 io-uring-register ;

:: io-uring-register-buffers2 ( ring rsrc-register nr-args -- n )
    ring IORING_REGISTER_BUFFERS2 rsrc-register nr-args io-uring-register ;

:: io-uring-register-buffers-update ( ring rsrc-update nr-args -- n )
    ring IORING_REGISTER_BUFFERS_UPDATE rsrc-update nr-args io-uring-register ;

:: io-uring-register-files ( ring fds nr-args -- n )
    ring IORING_REGISTER_FILES fds nr-args io-uring-register ;

:: io-uring-unregister-files ( ring -- n )
    ring IORING_UNREGISTER_FILES f 0 io-uring-register ;

:: io-uring-register-files2 ( ring rsrc-register nr-args -- n )
    ring IORING_REGISTER_FILES2 rsrc-register nr-args io-uring-register ;

:: io-uring-register-files-update ( ring update nr-args -- n )
    ring IORING_REGISTER_FILES_UPDATE update nr-args io-uring-register ;

:: io-uring-register-files-update2 ( ring update nr-args -- n )
    ring IORING_REGISTER_FILES_UPDATE2 update nr-args io-uring-register ;

:: io-uring-register-eventfd ( ring fd -- n )
    ring IORING_REGISTER_EVENTFD fd int <ref> 1 io-uring-register ;

:: io-uring-unregister-eventfd ( ring -- n )
    ring IORING_UNREGISTER_EVENTFD f 0 io-uring-register ;

:: io-uring-register-eventfd-async ( ring fd -- n )
    ring IORING_REGISTER_EVENTFD_ASYNC fd int <ref> 1 io-uring-register ;

:: io-uring-register-probe ( ring probe nr-args -- n )
    ring IORING_REGISTER_PROBE probe nr-args io-uring-register ;

:: io-uring-register-personality ( ring -- n )
    ring IORING_REGISTER_PERSONALITY f 0 io-uring-register ;

:: io-uring-unregister-personality ( ring personality -- n )
    ring IORING_UNREGISTER_PERSONALITY f personality io-uring-register ;

:: io-uring-register-restrictions ( ring restrictions nr-args -- n )
    ring IORING_REGISTER_RESTRICTIONS restrictions nr-args io-uring-register ;

:: io-uring-register-enable-rings ( ring -- n )
    ring IORING_REGISTER_ENABLE_RINGS f 0 io-uring-register ;

:: io-uring-register-iowq-aff ( ring cpuset cpusz -- n )
    ring IORING_REGISTER_IOWQ_AFF cpuset cpusz io-uring-register ;

:: io-uring-unregister-iowq-aff ( ring -- n )
    ring IORING_UNREGISTER_IOWQ_AFF f 0 io-uring-register ;

:: io-uring-register-iowq-max-workers ( ring values nr-args -- n )
    ring IORING_REGISTER_IOWQ_MAX_WORKERS values nr-args io-uring-register ;

:: io-uring-register-ring-fds ( ring fds nr-args -- n )
    ring IORING_REGISTER_RING_FDS fds nr-args io-uring-register ;

:: io-uring-unregister-ring-fds ( ring fds nr-args -- n )
    ring IORING_UNREGISTER_RING_FDS fds nr-args io-uring-register ;

:: io-uring-register-pbuf-ring ( ring buf-reg nr-args -- n )
    ring IORING_REGISTER_PBUF_RING buf-reg nr-args io-uring-register ;

:: io-uring-unregister-pbuf-ring ( ring buf-reg nr-args -- n )
    ring IORING_UNREGISTER_PBUF_RING buf-reg nr-args io-uring-register ;

:: io-uring-register-sync-cancel ( ring sync-cancel nr-args -- n )
    ring IORING_REGISTER_SYNC_CANCEL sync-cancel nr-args io-uring-register ;

:: io-uring-register-file-alloc-range ( ring range nr-args -- n )
    ring IORING_REGISTER_FILE_ALLOC_RANGE range nr-args io-uring-register ;

:: io-uring-register-pbuf-status ( ring status nr-args -- n )
    ring IORING_REGISTER_PBUF_STATUS status nr-args io-uring-register ;

:: io-uring-register-napi ( ring napi nr-args -- n )
    ring IORING_REGISTER_NAPI napi nr-args io-uring-register ;

:: io-uring-unregister-napi ( ring napi nr-args -- n )
    ring IORING_UNREGISTER_NAPI napi nr-args io-uring-register ;

:: io-uring-register-clock ( ring clock-register nr-args -- n )
    ring IORING_REGISTER_CLOCK clock-register nr-args io-uring-register ;

:: io-uring-register-clone-buffers ( ring clone-buffers nr-args -- n )
    ring IORING_REGISTER_CLONE_BUFFERS clone-buffers nr-args io-uring-register ;

:: io-uring-register-send-msg-ring ( ring msg nr-args -- n )
    ring IORING_REGISTER_SEND_MSG_RING msg nr-args io-uring-register ;

:: io-uring-register-zcrx-ifq ( ring ifq nr-args -- n )
    ring IORING_REGISTER_ZCRX_IFQ ifq nr-args io-uring-register ;

:: io-uring-register-resize-rings ( ring params nr-args -- n )
    ring IORING_REGISTER_RESIZE_RINGS params nr-args io-uring-register ;

:: io-uring-register-mem-region ( ring mem-region nr-args -- n )
    ring IORING_REGISTER_MEM_REGION mem-region nr-args io-uring-register ;

:: io-uring-register-query ( ring query nr-args -- n )
    ring IORING_REGISTER_QUERY query nr-args io-uring-register ;

:: io-uring-register-zcrx-ctrl ( ring ctrl nr-args -- n )
    ring IORING_REGISTER_ZCRX_CTRL ctrl nr-args io-uring-register ;

:: io-uring-register-bpf-filter ( ring filter nr-args -- n )
    ring IORING_REGISTER_BPF_FILTER filter nr-args io-uring-register ;

: io-uring-submit ( ring -- n )
    dup pending-sqes 0 0 io-uring-enter ;

:: io-uring-submit-and-wait ( ring min-complete -- n )
    ring ring pending-sqes min-complete IORING_ENTER_GETEVENTS
    io-uring-enter ;

:: io-uring-wait ( ring min-complete -- n )
    ring 0 min-complete IORING_ENTER_GETEVENTS io-uring-enter ;

:: io-uring-wait-cqe-alien ( ring -- cqe )
    ring io-uring-peek-cqe-alien [
        ring 1 io-uring-wait drop ring io-uring-wait-cqe-alien
    ] unless* ;

:: io-uring-wait-cqe ( ring -- cqe )
    ring io-uring-wait-cqe-alien io-uring-cqe memory>struct ;

CONSTANT: sqe-opcode-offset 0
CONSTANT: sqe-flags-offset 1
CONSTANT: sqe-ioprio-offset 2
CONSTANT: sqe-fd-offset 4
CONSTANT: sqe-off-offset 8
CONSTANT: sqe-cmd-op-offset 8
CONSTANT: sqe-addr-offset 16
CONSTANT: sqe-level-offset 16
CONSTANT: sqe-optname-offset 20
CONSTANT: sqe-len-offset 24
CONSTANT: sqe-rw-flags-offset 28
CONSTANT: sqe-user-data-offset 32
CONSTANT: sqe-buf-index-offset 40
CONSTANT: sqe-personality-offset 42
CONSTANT: sqe-file-index-offset 44
CONSTANT: sqe-addr-len-offset 44
CONSTANT: sqe-addr3-offset 48
CONSTANT: sqe-attr-type-mask-offset 56

CONSTANT: AT_FDCWD -100

:: io-uring-prep-rw-alien ( opcode sqe fd addr len offset user-data -- )
    opcode sqe >c-ptr sqe-opcode-offset uchar-at!
    fd sqe >c-ptr sqe-fd-offset int-at!
    offset sqe >c-ptr sqe-off-offset u64-at!
    addr ptr>u64 sqe >c-ptr sqe-addr-offset u64-at!
    len sqe >c-ptr sqe-len-offset u32-at!
    user-data sqe >c-ptr sqe-user-data-offset u64-at! ;

:: prep-rw ( opcode sqe fd addr len offset user-data -- alien-sqe )
    sqe >c-ptr :> p
    opcode p sqe-opcode-offset uchar-at!
    fd p sqe-fd-offset int-at!
    offset p sqe-off-offset u64-at!
    addr ptr>u64 p sqe-addr-offset u64-at!
    len p sqe-len-offset u32-at!
    user-data p sqe-user-data-offset u64-at!
    p ;

: io-uring-sqe-user-data@ ( sqe -- n )
    >c-ptr sqe-user-data-offset u64-at@ ;

: io-uring-sqe-user-data! ( user-data sqe -- )
    >c-ptr sqe-user-data-offset u64-at! ;

: io-uring-sqe-flags@ ( sqe -- n )
    >c-ptr sqe-flags-offset uchar-at@ ;

: io-uring-sqe-flags! ( flags sqe -- )
    >c-ptr sqe-flags-offset uchar-at! ;

:: io-uring-sqe-flags+ ( flags sqe -- )
    sqe io-uring-sqe-flags@ flags bitor sqe io-uring-sqe-flags! ;

: io-uring-sqe-ioprio@ ( sqe -- n )
    >c-ptr sqe-ioprio-offset ushort-at@ ;

: io-uring-sqe-ioprio! ( ioprio sqe -- )
    >c-ptr sqe-ioprio-offset ushort-at! ;

:: io-uring-sqe-ioprio+ ( flags sqe -- )
    sqe io-uring-sqe-ioprio@ flags bitor sqe io-uring-sqe-ioprio! ;

: io-uring-sqe-buf-group! ( bgid sqe -- )
    >c-ptr sqe-buf-index-offset ushort-at! ;

: io-uring-sqe-buf-index! ( index sqe -- )
    >c-ptr sqe-buf-index-offset ushort-at! ;

: io-uring-sqe-personality! ( personality sqe -- )
    >c-ptr sqe-personality-offset ushort-at! ;

:: io-uring-sqe-target-fixed-file! ( file-index sqe -- )
    file-index IORING_FILE_INDEX_ALLOC = [ file-index 1 - ] [ file-index ] if
    1 + sqe >c-ptr sqe-file-index-offset u32-at! ;

:: io-uring-prep-read-alien ( sqe fd addr len offset user-data -- )
    IORING_OP_READ sqe fd addr len offset user-data io-uring-prep-rw-alien ;

:: io-uring-prep-write-alien ( sqe fd addr len offset user-data -- )
    IORING_OP_WRITE sqe fd addr len offset user-data io-uring-prep-rw-alien ;

:: io-uring-prep-read-fixed-alien ( sqe fd addr len offset buf-index user-data -- )
    IORING_OP_READ_FIXED sqe fd addr len offset user-data io-uring-prep-rw-alien
    buf-index sqe >c-ptr sqe-buf-index-offset ushort-at! ;

:: io-uring-prep-write-fixed-alien ( sqe fd addr len offset buf-index user-data -- )
    IORING_OP_WRITE_FIXED sqe fd addr len offset user-data io-uring-prep-rw-alien
    buf-index sqe >c-ptr sqe-buf-index-offset ushort-at! ;

:: io-uring-sqe-fixed-file ( sqe -- )
    IOSQE_FIXED_FILE sqe io-uring-sqe-flags+ ;

:: io-uring-prep-nop-alien ( sqe user-data -- )
    IORING_OP_NOP sqe >c-ptr sqe-opcode-offset uchar-at!
    -1 sqe >c-ptr sqe-fd-offset int-at!
    user-data sqe >c-ptr sqe-user-data-offset u64-at! ;

: io-uring-cqe-user-data@ ( cqe -- n )
    >c-ptr cqe-user-data-offset u64-at@ ;

: io-uring-cqe-res@ ( cqe -- n )
    >c-ptr cqe-res-offset i32-at@ ;

: io-uring-cqe-flags@ ( cqe -- n )
    >c-ptr cqe-flags-offset u32-at@ ;

:: io-uring-prep-rw ( opcode sqe fd addr len offset user-data -- )
    opcode sqe fd addr len offset user-data prep-rw drop ;

:: io-uring-prep-read ( sqe fd addr len offset user-data -- )
    IORING_OP_READ sqe fd addr len offset user-data io-uring-prep-rw ;

:: io-uring-prep-write ( sqe fd addr len offset user-data -- )
    IORING_OP_WRITE sqe fd addr len offset user-data io-uring-prep-rw ;

:: io-uring-prep-nop ( sqe user-data -- )
    sqe user-data io-uring-prep-nop-alien ;

:: io-uring-prep-nop128 ( sqe user-data -- )
    IORING_OP_NOP128 sqe -1 f 0 0 user-data prep-rw drop ;

:: io-uring-prep-readv ( sqe fd iovecs nr-vecs offset user-data -- )
    IORING_OP_READV sqe fd iovecs nr-vecs offset user-data prep-rw drop ;

:: io-uring-prep-readv2 ( sqe fd iovecs nr-vecs offset flags user-data -- )
    IORING_OP_READV sqe fd iovecs nr-vecs offset user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-readv-fixed ( sqe fd iovecs nr-vecs offset flags buf-index user-data -- )
    sqe fd iovecs nr-vecs offset flags user-data io-uring-prep-readv2
    IORING_OP_READV_FIXED sqe >c-ptr sqe-opcode-offset uchar-at!
    buf-index sqe io-uring-sqe-buf-index! ;

:: io-uring-prep-writev ( sqe fd iovecs nr-vecs offset user-data -- )
    IORING_OP_WRITEV sqe fd iovecs nr-vecs offset user-data prep-rw drop ;

:: io-uring-prep-writev2 ( sqe fd iovecs nr-vecs offset flags user-data -- )
    IORING_OP_WRITEV sqe fd iovecs nr-vecs offset user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-writev-fixed ( sqe fd iovecs nr-vecs offset flags buf-index user-data -- )
    sqe fd iovecs nr-vecs offset flags user-data io-uring-prep-writev2
    IORING_OP_WRITEV_FIXED sqe >c-ptr sqe-opcode-offset uchar-at!
    buf-index sqe io-uring-sqe-buf-index! ;

:: io-uring-prep-read-fixed ( sqe fd addr len offset buf-index user-data -- )
    sqe fd addr len offset buf-index user-data io-uring-prep-read-fixed-alien ;

:: io-uring-prep-write-fixed ( sqe fd addr len offset buf-index user-data -- )
    sqe fd addr len offset buf-index user-data io-uring-prep-write-fixed-alien ;

:: io-uring-prep-fsync ( sqe fd fsync-flags user-data -- )
    IORING_OP_FSYNC sqe fd f 0 0 user-data prep-rw
    fsync-flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-poll-add ( sqe fd poll-mask user-data -- )
    IORING_OP_POLL_ADD sqe fd f 0 0 user-data prep-rw
    poll-mask swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-poll-multishot ( sqe fd poll-mask user-data -- )
    sqe fd poll-mask user-data io-uring-prep-poll-add
    IORING_POLL_ADD_MULTI sqe >c-ptr sqe-len-offset u32-at! ;

:: io-uring-prep-poll-remove ( sqe old-user-data user-data -- )
    IORING_OP_POLL_REMOVE sqe -1 f 0 0 user-data prep-rw
    old-user-data swap sqe-addr-offset u64-at! ;

:: io-uring-prep-poll-update ( sqe old-user-data new-user-data poll-mask flags user-data -- )
    IORING_OP_POLL_REMOVE sqe -1 f flags new-user-data user-data prep-rw :> p
    old-user-data p sqe-addr-offset u64-at!
    poll-mask p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-timeout ( sqe ts count flags user-data -- )
    IORING_OP_TIMEOUT sqe -1 ts 1 count user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-timeout-remove ( sqe target-user-data flags user-data -- )
    IORING_OP_TIMEOUT_REMOVE sqe -1 f 0 0 user-data prep-rw :> p
    target-user-data p sqe-addr-offset u64-at!
    flags p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-timeout-update ( sqe ts target-user-data flags user-data -- )
    IORING_OP_TIMEOUT_REMOVE sqe -1 f 0 ts ptr>u64 user-data prep-rw :> p
    target-user-data p sqe-addr-offset u64-at!
    flags IORING_TIMEOUT_UPDATE bitor p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-link-timeout ( sqe ts flags user-data -- )
    IORING_OP_LINK_TIMEOUT sqe -1 ts 1 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-accept ( sqe fd addr addrlen flags user-data -- )
    IORING_OP_ACCEPT sqe fd addr 0 addrlen ptr>u64 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-accept-direct ( sqe fd addr addrlen flags file-index user-data -- )
    sqe fd addr addrlen flags user-data io-uring-prep-accept
    file-index sqe io-uring-sqe-target-fixed-file! ;

:: io-uring-prep-multishot-accept ( sqe fd addr addrlen flags user-data -- )
    sqe fd addr addrlen flags user-data io-uring-prep-accept
    IORING_ACCEPT_MULTISHOT sqe io-uring-sqe-ioprio+ ;

:: io-uring-prep-multishot-accept-direct ( sqe fd addr addrlen flags user-data -- )
    sqe fd addr addrlen flags user-data io-uring-prep-multishot-accept
    IORING_FILE_INDEX_ALLOC sqe io-uring-sqe-target-fixed-file! ;

:: io-uring-prep-cancel64 ( sqe target-user-data flags user-data -- )
    IORING_OP_ASYNC_CANCEL sqe -1 f 0 0 user-data prep-rw :> p
    target-user-data p sqe-addr-offset u64-at!
    flags p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-cancel-fd ( sqe fd flags user-data -- )
    IORING_OP_ASYNC_CANCEL sqe fd f 0 0 user-data prep-rw
    flags IORING_ASYNC_CANCEL_FD bitor swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-connect ( sqe fd addr addrlen user-data -- )
    IORING_OP_CONNECT sqe fd addr 0 addrlen user-data prep-rw drop ;

:: io-uring-prep-bind ( sqe fd addr addrlen user-data -- )
    IORING_OP_BIND sqe fd addr 0 addrlen user-data prep-rw drop ;

:: io-uring-prep-listen ( sqe fd backlog user-data -- )
    IORING_OP_LISTEN sqe fd f backlog 0 user-data prep-rw drop ;

:: io-uring-prep-epoll-wait ( sqe fd events maxevents flags user-data -- )
    IORING_OP_EPOLL_WAIT sqe fd events maxevents 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-files-update ( sqe fds nr-fds offset user-data -- )
    IORING_OP_FILES_UPDATE sqe -1 fds nr-fds offset user-data prep-rw drop ;

:: io-uring-prep-fallocate ( sqe fd mode offset len user-data -- )
    IORING_OP_FALLOCATE sqe fd f mode offset user-data prep-rw
    len swap sqe-addr-offset u64-at! ;

:: io-uring-prep-openat ( sqe dfd path flags mode user-data -- )
    IORING_OP_OPENAT sqe dfd path mode 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-openat-direct ( sqe dfd path flags mode file-index user-data -- )
    sqe dfd path flags mode user-data io-uring-prep-openat
    file-index sqe io-uring-sqe-target-fixed-file! ;

:: io-uring-prep-open ( sqe path flags mode user-data -- )
    sqe AT_FDCWD path flags mode user-data io-uring-prep-openat ;

:: io-uring-prep-open-direct ( sqe path flags mode file-index user-data -- )
    sqe AT_FDCWD path flags mode file-index user-data io-uring-prep-openat-direct ;

:: io-uring-prep-openat2 ( sqe dfd path how how-size user-data -- )
    IORING_OP_OPENAT2 sqe dfd path how-size how ptr>u64 user-data prep-rw drop ;

:: io-uring-prep-openat2-direct ( sqe dfd path how how-size file-index user-data -- )
    sqe dfd path how how-size user-data io-uring-prep-openat2
    file-index sqe io-uring-sqe-target-fixed-file! ;

:: io-uring-prep-close ( sqe fd user-data -- )
    IORING_OP_CLOSE sqe fd f 0 0 user-data prep-rw drop ;

:: io-uring-prep-close-direct ( sqe file-index user-data -- )
    sqe 0 user-data io-uring-prep-close
    file-index sqe io-uring-sqe-target-fixed-file! ;

:: io-uring-prep-statx ( sqe dfd path flags mask statxbuf user-data -- )
    IORING_OP_STATX sqe dfd path mask statxbuf ptr>u64 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-read-multishot ( sqe fd nbytes offset buf-group user-data -- )
    IORING_OP_READ_MULTISHOT sqe fd f nbytes offset user-data prep-rw drop
    buf-group sqe io-uring-sqe-buf-group!
    IOSQE_BUFFER_SELECT sqe io-uring-sqe-flags! ;

:: io-uring-prep-fadvise ( sqe fd offset len advice user-data -- )
    IORING_OP_FADVISE sqe fd f len offset user-data prep-rw
    advice swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-fadvise64 ( sqe fd offset len advice user-data -- )
    IORING_OP_FADVISE sqe fd f 0 offset user-data prep-rw :> p
    len p sqe-addr-offset u64-at!
    advice p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-madvise ( sqe addr length advice user-data -- )
    IORING_OP_MADVISE sqe -1 addr length 0 user-data prep-rw
    advice swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-madvise64 ( sqe addr length advice user-data -- )
    IORING_OP_MADVISE sqe -1 addr 0 length user-data prep-rw
    advice swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-send ( sqe sockfd buf len flags user-data -- )
    IORING_OP_SEND sqe sockfd buf len 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-send-bundle ( sqe sockfd len flags user-data -- )
    sqe sockfd f len flags user-data io-uring-prep-send
    IORING_RECVSEND_BUNDLE sqe io-uring-sqe-ioprio+ ;

:: io-uring-prep-send-set-addr ( sqe dest-addr addr-len -- )
    sqe >c-ptr :> p
    dest-addr ptr>u64 p sqe-off-offset u64-at!
    addr-len p sqe-addr-len-offset ushort-at! ;

:: io-uring-prep-sendto ( sqe sockfd buf len flags addr addrlen user-data -- )
    sqe sockfd buf len flags user-data io-uring-prep-send
    sqe addr addrlen io-uring-prep-send-set-addr ;

:: io-uring-prep-send-zc ( sqe sockfd buf len flags zc-flags user-data -- )
    IORING_OP_SEND_ZC sqe sockfd buf len 0 user-data prep-rw :> p
    flags p sqe-rw-flags-offset u32-at!
    zc-flags p sqe-ioprio-offset ushort-at! ;

:: io-uring-prep-send-zc-fixed ( sqe sockfd buf len flags zc-flags buf-index user-data -- )
    sqe sockfd buf len flags zc-flags user-data io-uring-prep-send-zc
    IORING_RECVSEND_FIXED_BUF sqe io-uring-sqe-ioprio+
    buf-index sqe io-uring-sqe-buf-index! ;

:: io-uring-prep-sendmsg ( sqe fd msg flags user-data -- )
    IORING_OP_SENDMSG sqe fd msg 1 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-sendmsg-zc ( sqe fd msg flags user-data -- )
    sqe fd msg flags user-data io-uring-prep-sendmsg
    IORING_OP_SENDMSG_ZC sqe >c-ptr sqe-opcode-offset uchar-at! ;

:: io-uring-prep-sendmsg-zc-fixed ( sqe fd msg flags buf-index user-data -- )
    sqe fd msg flags user-data io-uring-prep-sendmsg-zc
    IORING_RECVSEND_FIXED_BUF sqe io-uring-sqe-ioprio+
    buf-index sqe io-uring-sqe-buf-index! ;

:: io-uring-prep-recv ( sqe sockfd buf len flags user-data -- )
    IORING_OP_RECV sqe sockfd buf len 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-recv-multishot ( sqe sockfd buf len flags user-data -- )
    sqe sockfd buf len flags user-data io-uring-prep-recv
    IORING_RECV_MULTISHOT sqe io-uring-sqe-ioprio+ ;

:: io-uring-prep-recvmsg ( sqe fd msg flags user-data -- )
    IORING_OP_RECVMSG sqe fd msg 1 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-recvmsg-multishot ( sqe fd msg flags user-data -- )
    sqe fd msg flags user-data io-uring-prep-recvmsg
    IORING_RECV_MULTISHOT sqe io-uring-sqe-ioprio+ ;

:: io-uring-prep-epoll-ctl ( sqe epfd fd op ev user-data -- )
    IORING_OP_EPOLL_CTL sqe epfd ev op fd user-data prep-rw drop ;

:: io-uring-prep-splice ( sqe fd-in off-in fd-out off-out nbytes flags user-data -- )
    IORING_OP_SPLICE sqe fd-out f nbytes off-out user-data prep-rw :> p
    off-in p sqe-addr-offset u64-at!
    fd-in p sqe-file-index-offset int-at!
    flags p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-tee ( sqe fd-in fd-out nbytes flags user-data -- )
    IORING_OP_TEE sqe fd-out f nbytes 0 user-data prep-rw :> p
    fd-in p sqe-file-index-offset int-at!
    flags p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-provide-buffers ( sqe addr len nr bgid bid user-data -- )
    IORING_OP_PROVIDE_BUFFERS sqe nr addr len bid user-data prep-rw drop
    bgid sqe io-uring-sqe-buf-group! ;

:: io-uring-prep-remove-buffers ( sqe nr bgid user-data -- )
    IORING_OP_REMOVE_BUFFERS sqe nr f 0 0 user-data prep-rw drop
    bgid sqe io-uring-sqe-buf-group! ;

:: io-uring-prep-shutdown ( sqe fd how user-data -- )
    IORING_OP_SHUTDOWN sqe fd f how 0 user-data prep-rw drop ;

:: io-uring-prep-renameat ( sqe olddfd oldpath newdfd newpath flags user-data -- )
    IORING_OP_RENAMEAT sqe olddfd oldpath newdfd newpath ptr>u64 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-rename ( sqe oldpath newpath user-data -- )
    sqe AT_FDCWD oldpath AT_FDCWD newpath 0 user-data io-uring-prep-renameat ;

:: io-uring-prep-unlinkat ( sqe dfd path flags user-data -- )
    IORING_OP_UNLINKAT sqe dfd path 0 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-unlink ( sqe path flags user-data -- )
    sqe AT_FDCWD path flags user-data io-uring-prep-unlinkat ;

:: io-uring-prep-mkdirat ( sqe dfd path mode user-data -- )
    IORING_OP_MKDIRAT sqe dfd path mode 0 user-data prep-rw drop ;

:: io-uring-prep-mkdir ( sqe path mode user-data -- )
    sqe AT_FDCWD path mode user-data io-uring-prep-mkdirat ;

:: io-uring-prep-symlinkat ( sqe target newdirfd linkpath user-data -- )
    IORING_OP_SYMLINKAT sqe newdirfd target 0 linkpath ptr>u64 user-data prep-rw drop ;

:: io-uring-prep-symlink ( sqe target linkpath user-data -- )
    sqe target AT_FDCWD linkpath user-data io-uring-prep-symlinkat ;

:: io-uring-prep-linkat ( sqe olddfd oldpath newdfd newpath flags user-data -- )
    IORING_OP_LINKAT sqe olddfd oldpath newdfd newpath ptr>u64 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-link ( sqe oldpath newpath flags user-data -- )
    sqe AT_FDCWD oldpath AT_FDCWD newpath flags user-data io-uring-prep-linkat ;

:: io-uring-prep-msg-ring ( sqe fd len data flags user-data -- )
    IORING_OP_MSG_RING sqe fd f len data user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-msg-ring-cqe-flags ( sqe fd len data flags cqe-flags user-data -- )
    sqe fd len data flags IORING_MSG_RING_FLAGS_PASS bitor user-data io-uring-prep-msg-ring
    cqe-flags sqe >c-ptr sqe-file-index-offset u32-at! ;

:: io-uring-prep-msg-ring-fd ( sqe fd source-fd target-fd data flags user-data -- )
    IORING_OP_MSG_RING sqe fd f 0 data user-data prep-rw :> p
    IORING_MSG_SEND_FD p sqe-addr-offset u64-at!
    source-fd p sqe-addr3-offset u64-at!
    flags p sqe-rw-flags-offset u32-at!
    target-fd sqe io-uring-sqe-target-fixed-file! ;

:: io-uring-prep-msg-ring-fd-alloc ( sqe fd source-fd data flags user-data -- )
    sqe fd source-fd IORING_FILE_INDEX_ALLOC data flags user-data io-uring-prep-msg-ring-fd ;

:: io-uring-prep-getxattr ( sqe name value path len user-data -- )
    IORING_OP_GETXATTR sqe 0 name len value ptr>u64 user-data prep-rw :> p
    path ptr>u64 p sqe-addr3-offset u64-at!
    0 p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-setxattr ( sqe name value path flags len user-data -- )
    IORING_OP_SETXATTR sqe 0 name len value ptr>u64 user-data prep-rw :> p
    path ptr>u64 p sqe-addr3-offset u64-at!
    flags p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-fgetxattr ( sqe fd name value len user-data -- )
    IORING_OP_FGETXATTR sqe fd name len value ptr>u64 user-data prep-rw
    0 swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-fsetxattr ( sqe fd name value flags len user-data -- )
    IORING_OP_FSETXATTR sqe fd name len value ptr>u64 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-socket ( sqe domain type protocol flags user-data -- )
    IORING_OP_SOCKET sqe domain f protocol type user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-socket-direct ( sqe domain type protocol file-index flags user-data -- )
    sqe domain type protocol flags user-data io-uring-prep-socket
    file-index sqe io-uring-sqe-target-fixed-file! ;

:: io-uring-prep-socket-direct-alloc ( sqe domain type protocol flags user-data -- )
    sqe domain type protocol IORING_FILE_INDEX_ALLOC flags user-data io-uring-prep-socket-direct ;

:: io-uring-prep-uring-cmd ( sqe cmd-op fd user-data -- )
    sqe >c-ptr :> p
    IORING_OP_URING_CMD p sqe-opcode-offset uchar-at!
    fd p sqe-fd-offset int-at!
    cmd-op p sqe-cmd-op-offset u32-at!
    0 p 12 u32-at!
    0 p sqe-addr-offset u64-at!
    0 p sqe-len-offset u32-at!
    user-data p sqe-user-data-offset u64-at! ;

:: io-uring-prep-uring-cmd128 ( sqe cmd-op fd user-data -- )
    sqe cmd-op fd user-data io-uring-prep-uring-cmd
    IORING_OP_URING_CMD128 sqe >c-ptr sqe-opcode-offset uchar-at! ;

:: io-uring-prep-cmd-sock ( sqe cmd-op fd level optname optval optlen user-data -- )
    sqe cmd-op fd user-data io-uring-prep-uring-cmd
    sqe >c-ptr :> p
    optval ptr>u64 p sqe-addr3-offset u64-at!
    optname p sqe-optname-offset u32-at!
    optlen p sqe-file-index-offset u32-at!
    level p sqe-level-offset u32-at! ;

:: io-uring-prep-cmd-getsockname ( sqe fd sockaddr sockaddr-len peer user-data -- )
    sqe SOCKET_URING_OP_GETSOCKNAME fd user-data io-uring-prep-uring-cmd
    sqe >c-ptr :> p
    sockaddr ptr>u64 p sqe-addr-offset u64-at!
    sockaddr-len ptr>u64 p sqe-addr3-offset u64-at!
    peer p sqe-file-index-offset u32-at! ;

:: io-uring-prep-waitid ( sqe idtype id infop options flags user-data -- )
    IORING_OP_WAITID sqe id f idtype 0 user-data prep-rw :> p
    flags p sqe-rw-flags-offset u32-at!
    options p sqe-file-index-offset u32-at!
    infop ptr>u64 p sqe-off-offset u64-at! ;

:: io-uring-prep-futex-wake ( sqe futex val mask futex-flags flags user-data -- )
    IORING_OP_FUTEX_WAKE sqe futex-flags futex 0 val user-data prep-rw :> p
    flags p sqe-rw-flags-offset u32-at!
    mask p sqe-addr3-offset u64-at! ;

:: io-uring-prep-futex-wait ( sqe futex val mask futex-flags flags user-data -- )
    IORING_OP_FUTEX_WAIT sqe futex-flags futex 0 val user-data prep-rw :> p
    flags p sqe-rw-flags-offset u32-at!
    mask p sqe-addr3-offset u64-at! ;

:: io-uring-prep-futex-waitv ( sqe futex nr-futex flags user-data -- )
    IORING_OP_FUTEX_WAITV sqe 0 futex nr-futex 0 user-data prep-rw
    flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-fixed-fd-install ( sqe fd flags user-data -- )
    IORING_OP_FIXED_FD_INSTALL sqe fd f 0 0 user-data prep-rw :> p
    IOSQE_FIXED_FILE p sqe-flags-offset uchar-at!
    flags p sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-ftruncate ( sqe fd len user-data -- )
    IORING_OP_FTRUNCATE sqe fd f 0 len user-data prep-rw drop ;

:: io-uring-prep-cmd-discard ( sqe fd offset nbytes user-data -- )
    sqe BLOCK_URING_CMD_DISCARD fd user-data io-uring-prep-uring-cmd
    sqe >c-ptr :> p
    offset p sqe-addr-offset u64-at!
    nbytes p sqe-addr3-offset u64-at! ;

:: io-uring-prep-pipe ( sqe fds pipe-flags user-data -- )
    IORING_OP_PIPE sqe 0 fds 0 0 user-data prep-rw
    pipe-flags swap sqe-rw-flags-offset u32-at! ;

:: io-uring-prep-pipe-direct ( sqe fds pipe-flags file-index user-data -- )
    sqe fds pipe-flags user-data io-uring-prep-pipe
    file-index sqe io-uring-sqe-target-fixed-file! ;

ERROR: io-uring-submission-queue-full ring ;
ERROR: io-uring-operation-error errno ;

TUPLE: io-uring-completion user-data res flags ;

:: <io-uring-completion> ( cqe -- completion )
    cqe io-uring-cqe-user-data@
    cqe io-uring-cqe-res@
    cqe io-uring-cqe-flags@
    io-uring-completion boa ;

: io-uring-check-result ( n -- n )
    dup 0 < [ neg io-uring-operation-error ] when ;

: io-uring-completion-result ( completion -- n )
    res>> io-uring-check-result ;

: with-io-uring ( entries quot: ( ring -- ... ) -- ... )
    [ <io-uring> ] dip with-disposal ; inline

:: io-uring-require-sqe ( ring -- sqe )
    ring io-uring-get-sqe-alien [
        ! The SQE is already zeroed and reserved by io-uring-get-sqe-alien.
    ] [
        ring io-uring-submission-queue-full
    ] if* ;

:: io-uring-queue ( ring quot: ( sqe -- ) -- )
    ring io-uring-require-sqe quot call( sqe -- ) ; inline

:: io-uring-queue-nop ( ring user-data -- )
    ring [ user-data io-uring-prep-nop-alien ] io-uring-queue ;

:: io-uring-queue-read ( ring fd buf len offset user-data -- )
    ring [
        fd buf len offset user-data io-uring-prep-read-alien
    ] io-uring-queue ;

:: io-uring-queue-write ( ring fd buf len offset user-data -- )
    ring [
        fd buf len offset user-data io-uring-prep-write-alien
    ] io-uring-queue ;

:: io-uring-queue-read-fixed ( ring fd buf len offset buf-index user-data -- )
    ring [
        fd buf len offset buf-index user-data io-uring-prep-read-fixed-alien
    ] io-uring-queue ;

:: io-uring-queue-write-fixed ( ring fd buf len offset buf-index user-data -- )
    ring [
        fd buf len offset buf-index user-data io-uring-prep-write-fixed-alien
    ] io-uring-queue ;

:: io-uring-peek-completion ( ring -- completion/f )
    ring io-uring-peek-cqe-alien [
        :> cqe
        cqe <io-uring-completion> :> completion
        ring cqe io-uring-cqe-seen
        completion
    ] [ f ] if* ;

:: io-uring-wait-completion ( ring -- completion )
    ring io-uring-wait-cqe-alien :> cqe
    cqe <io-uring-completion> :> completion
    ring cqe io-uring-cqe-seen
    completion ;

:: io-uring-wait-completions ( ring n -- completions )
    V{ } clone :> completions
    n [
        ring io-uring-wait-completion completions push
    ] times
    completions >array ;

:: io-uring-submit-and-wait-completion ( ring -- completion )
    ring 1 io-uring-submit-and-wait drop
    ring io-uring-wait-completion ;

:: io-uring-submit-and-wait-completions ( ring min-complete -- completions )
    ring min-complete io-uring-submit-and-wait drop
    ring min-complete io-uring-wait-completions ;

:: io-uring-read ( ring fd buf len offset -- n )
    ring fd buf len offset 0 io-uring-queue-read
    ring io-uring-submit-and-wait-completion io-uring-completion-result ;

:: io-uring-write ( ring fd buf len offset -- n )
    ring fd buf len offset 0 io-uring-queue-write
    ring io-uring-submit-and-wait-completion io-uring-completion-result ;

:: io-uring-read-fixed ( ring fd buf len offset buf-index -- n )
    ring fd buf len offset buf-index 0 io-uring-queue-read-fixed
    ring io-uring-submit-and-wait-completion io-uring-completion-result ;

:: io-uring-write-fixed ( ring fd buf len offset buf-index -- n )
    ring fd buf len offset buf-index 0 io-uring-queue-write-fixed
    ring io-uring-submit-and-wait-completion io-uring-completion-result ;
