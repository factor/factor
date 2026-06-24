! Copyright (C) 2026 erg.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax classes.struct kernel
locals math ;
IN: unix.linux.io-uring

LIBRARY: libc

! x86-64 Linux syscall numbers.
CONSTANT: __NR_io_uring_setup    425
CONSTANT: __NR_io_uring_enter    426
CONSTANT: __NR_io_uring_register 427

STRUCT: io-uring-sqe
    { opcode uchar }
    { flags uchar }
    { ioprio ushort }
    { fd int }
    { off uint64_t }
    { addr uint64_t }
    { len uint32_t }
    { rw-flags uint32_t }
    { user-data uint64_t }
    { buf-index uint16_t }
    { personality uint16_t }
    { file-index uint32_t }
    { addr3 uint64_t }
    { pad2 uint64_t } ;

STRUCT: io-uring-attr-pi
    { flags uint16_t }
    { app-tag uint16_t }
    { len uint32_t }
    { addr uint64_t }
    { seed uint64_t }
    { rsvd uint64_t } ;

STRUCT: io-uring-cqe
    { user-data uint64_t }
    { res int32_t }
    { flags uint32_t } ;

STRUCT: io-sqring-offsets
    { head uint32_t }
    { tail uint32_t }
    { ring-mask uint32_t }
    { ring-entries uint32_t }
    { flags uint32_t }
    { dropped uint32_t }
    { array uint32_t }
    { resv1 uint32_t }
    { user-addr uint64_t } ;

STRUCT: io-cqring-offsets
    { head uint32_t }
    { tail uint32_t }
    { ring-mask uint32_t }
    { ring-entries uint32_t }
    { overflow uint32_t }
    { cqes uint32_t }
    { flags uint32_t }
    { resv1 uint32_t }
    { user-addr uint64_t } ;

STRUCT: io-uring-params
    { sq-entries uint32_t }
    { cq-entries uint32_t }
    { flags uint32_t }
    { sq-thread-cpu uint32_t }
    { sq-thread-idle uint32_t }
    { features uint32_t }
    { wq-fd uint32_t }
    { resv uint32_t[3] }
    { sq-off io-sqring-offsets }
    { cq-off io-cqring-offsets } ;

STRUCT: io-uring-files-update
    { offset uint32_t }
    { resv uint32_t }
    { fds uint64_t } ;

STRUCT: io-uring-region-desc
    { user-addr uint64_t }
    { size uint64_t }
    { flags uint32_t }
    { id uint32_t }
    { mmap-offset uint64_t }
    { resv uint64_t[4] } ;

STRUCT: io-uring-mem-region-reg
    { region-uptr uint64_t }
    { flags uint64_t }
    { resv uint64_t[2] } ;

STRUCT: io-uring-rsrc-register
    { nr uint32_t }
    { flags uint32_t }
    { resv2 uint64_t }
    { data uint64_t }
    { tags uint64_t } ;

STRUCT: io-uring-rsrc-update
    { offset uint32_t }
    { resv uint32_t }
    { data uint64_t } ;

STRUCT: io-uring-rsrc-update2
    { offset uint32_t }
    { resv uint32_t }
    { data uint64_t }
    { tags uint64_t }
    { nr uint32_t }
    { resv2 uint32_t } ;

STRUCT: io-uring-probe-op
    { op uchar }
    { resv uchar }
    { flags uint16_t }
    { resv2 uint32_t } ;

STRUCT: io-uring-probe
    { last-op uchar }
    { ops-len uchar }
    { resv uint16_t }
    { resv2 uint32_t[3] } ;

STRUCT: io-uring-restriction
    { opcode uint16_t }
    { op uchar }
    { resv uchar }
    { resv2 uint32_t[3] } ;

STRUCT: io-uring-task-restriction
    { flags uint16_t }
    { nr-res uint16_t }
    { resv uint32_t[3] } ;

STRUCT: io-uring-clock-register
    { clockid uint32_t }
    { resv uint32_t[3] } ;

STRUCT: io-uring-clone-buffers
    { src-fd uint32_t }
    { flags uint32_t }
    { src-off uint32_t }
    { dst-off uint32_t }
    { nr uint32_t }
    { pad uint32_t[3] } ;

STRUCT: io-uring-buf
    { addr uint64_t }
    { len uint32_t }
    { bid uint16_t }
    { resv uint16_t } ;

STRUCT: io-uring-buf-ring
    { resv1 uint64_t }
    { resv2 uint32_t }
    { resv3 uint16_t }
    { tail uint16_t } ;

STRUCT: io-uring-buf-reg
    { ring-addr uint64_t }
    { ring-entries uint32_t }
    { bgid uint16_t }
    { flags uint16_t }
    { min-left uint32_t }
    { resv uint32_t[5] } ;

STRUCT: io-uring-buf-status
    { buf-group uint32_t }
    { head uint32_t }
    { resv uint32_t[8] } ;

STRUCT: io-uring-napi
    { busy-poll-to uint32_t }
    { prefer-busy-poll uchar }
    { opcode uchar }
    { pad uchar[2] }
    { op-param uint32_t }
    { resv uint32_t } ;

STRUCT: io-timespec
    { sec uint64_t }
    { nsec uint64_t } ;

STRUCT: io-uring-reg-wait
    { ts io-timespec }
    { min-wait-usec uint32_t }
    { flags uint32_t }
    { sigmask uint64_t }
    { sigmask-sz uint32_t }
    { pad uint32_t[3] }
    { pad2 uint64_t[2] } ;

STRUCT: io-uring-getevents-arg
    { sigmask uint64_t }
    { sigmask-sz uint32_t }
    { min-wait-usec uint32_t }
    { ts uint64_t } ;

STRUCT: io-uring-sync-cancel-reg
    { addr uint64_t }
    { fd int32_t }
    { flags uint32_t }
    { timeout io-timespec }
    { opcode uchar }
    { pad uchar[7] }
    { pad2 uint64_t[3] } ;

STRUCT: io-uring-file-index-range
    { off uint32_t }
    { len uint32_t }
    { resv uint64_t } ;

STRUCT: io-uring-recvmsg-out
    { namelen uint32_t }
    { controllen uint32_t }
    { payloadlen uint32_t }
    { flags uint32_t } ;

STRUCT: io-uring-query-hdr
    { next-entry uint64_t }
    { query-data uint64_t }
    { query-op uint32_t }
    { size uint32_t }
    { result int32_t }
    { resv uint32_t[3] } ;

STRUCT: io-uring-query-opcode
    { nr-request-opcodes uint32_t }
    { nr-register-opcodes uint32_t }
    { feature-flags uint64_t }
    { ring-setup-flags uint64_t }
    { enter-flags uint64_t }
    { sqe-flags uint64_t }
    { nr-query-opcodes uint32_t }
    { pad uint32_t } ;

STRUCT: io-uring-query-zcrx
    { register-flags uint64_t }
    { area-flags uint64_t }
    { nr-ctrl-opcodes uint32_t }
    { features uint32_t }
    { rq-hdr-size uint32_t }
    { rq-hdr-alignment uint32_t }
    { resv2 uint64_t } ;

STRUCT: io-uring-query-scq
    { hdr-size uint64_t }
    { hdr-alignment uint64_t } ;

STRUCT: io-uring-zcrx-rqe
    { off uint64_t }
    { len uint32_t }
    { pad uint32_t } ;

STRUCT: io-uring-zcrx-cqe
    { off uint64_t }
    { pad uint64_t } ;

STRUCT: io-uring-zcrx-offsets
    { head uint32_t }
    { tail uint32_t }
    { rqes uint32_t }
    { resv2 uint32_t }
    { resv uint64_t[2] } ;

STRUCT: io-uring-zcrx-area-reg
    { addr uint64_t }
    { len uint64_t }
    { rq-area-token uint64_t }
    { flags uint32_t }
    { dmabuf-fd uint32_t }
    { resv2 uint64_t[2] } ;

STRUCT: io-uring-zcrx-ifq-reg
    { if-idx uint32_t }
    { if-rxq uint32_t }
    { rq-entries uint32_t }
    { flags uint32_t }
    { area-ptr uint64_t }
    { region-ptr uint64_t }
    { offsets io-uring-zcrx-offsets }
    { zcrx-id uint32_t }
    { rx-buf-len uint32_t }
    { resv uint64_t[3] } ;

STRUCT: zcrx-ctrl-flush-rq
    { resv uint64_t[6] } ;

STRUCT: zcrx-ctrl-export
    { zcrx-fd uint32_t }
    { resv1 uint32_t[11] } ;

STRUCT: zcrx-ctrl
    { zcrx-id uint32_t }
    { op uint32_t }
    { resv uint64_t[2] }
    { data uint64_t[6] } ;

STRUCT: io-uring-bpf-ctx
    { user-data uint64_t }
    { opcode uchar }
    { sqe-flags uchar }
    { pdu-size uchar }
    { pad uchar[5] }
    { pdu uint64_t[3] } ;

STRUCT: io-uring-bpf-filter
    { opcode uint32_t }
    { flags uint32_t }
    { filter-len uint32_t }
    { pdu-size uchar }
    { resv uchar[3] }
    { filter-ptr uint64_t }
    { resv2 uint64_t[5] } ;

STRUCT: io-uring-bpf
    { cmd-type uint16_t }
    { cmd-flags uint16_t }
    { resv uint32_t }
    { filter io-uring-bpf-filter } ;

STRUCT: io-uring-mock-probe
    { features uint64_t }
    { resv uint64_t[9] } ;

STRUCT: io-uring-mock-create
    { out-fd uint32_t }
    { flags uint32_t }
    { file-size uint64_t }
    { rw-delay-ns uint64_t }
    { resv uint64_t[13] } ;

:: io_uring_setup ( entries params -- fd )
    __NR_io_uring_setup entries params
    long "libc" "syscall" { long uint void* } t alien-invoke ; inline

:: io_uring_enter ( fd to-submit min-complete flags sig sz -- n )
    __NR_io_uring_enter fd to-submit min-complete flags sig sz
    long "libc" "syscall"
    { long uint uint uint uint void* size_t } t alien-invoke ; inline

:: io_uring_register ( fd opcode arg nr-args -- n )
    __NR_io_uring_register fd opcode arg nr-args
    long "libc" "syscall" { long uint uint void* uint } t alien-invoke ; inline

CONSTANT: IORING_FILE_INDEX_ALLOC 0xffffffff

CONSTANT: IORING_RW_ATTR_FLAG_PI 0x01

CONSTANT: IOSQE_FIXED_FILE       0x01
CONSTANT: IOSQE_IO_DRAIN         0x02
CONSTANT: IOSQE_IO_LINK          0x04
CONSTANT: IOSQE_IO_HARDLINK      0x08
CONSTANT: IOSQE_ASYNC            0x10
CONSTANT: IOSQE_BUFFER_SELECT    0x20
CONSTANT: IOSQE_CQE_SKIP_SUCCESS 0x40

CONSTANT: IORING_SETUP_IOPOLL                 0x000001
CONSTANT: IORING_SETUP_SQPOLL                 0x000002
CONSTANT: IORING_SETUP_SQ_AFF                 0x000004
CONSTANT: IORING_SETUP_CQSIZE                 0x000008
CONSTANT: IORING_SETUP_CLAMP                  0x000010
CONSTANT: IORING_SETUP_ATTACH_WQ              0x000020
CONSTANT: IORING_SETUP_R_DISABLED             0x000040
CONSTANT: IORING_SETUP_SUBMIT_ALL             0x000080
CONSTANT: IORING_SETUP_COOP_TASKRUN           0x000100
CONSTANT: IORING_SETUP_TASKRUN_FLAG           0x000200
CONSTANT: IORING_SETUP_SQE128                 0x000400
CONSTANT: IORING_SETUP_CQE32                  0x000800
CONSTANT: IORING_SETUP_SINGLE_ISSUER          0x001000
CONSTANT: IORING_SETUP_DEFER_TASKRUN          0x002000
CONSTANT: IORING_SETUP_NO_MMAP                0x004000
CONSTANT: IORING_SETUP_REGISTERED_FD_ONLY     0x008000
CONSTANT: IORING_SETUP_NO_SQARRAY             0x010000
CONSTANT: IORING_SETUP_HYBRID_IOPOLL          0x020000
CONSTANT: IORING_SETUP_CQE_MIXED              0x040000
CONSTANT: IORING_SETUP_SQE_MIXED              0x080000
CONSTANT: IORING_SETUP_SQ_REWIND              0x100000

CONSTANT: IORING_OP_NOP              0
CONSTANT: IORING_OP_READV            1
CONSTANT: IORING_OP_WRITEV           2
CONSTANT: IORING_OP_FSYNC            3
CONSTANT: IORING_OP_READ_FIXED       4
CONSTANT: IORING_OP_WRITE_FIXED      5
CONSTANT: IORING_OP_POLL_ADD         6
CONSTANT: IORING_OP_POLL_REMOVE      7
CONSTANT: IORING_OP_SYNC_FILE_RANGE  8
CONSTANT: IORING_OP_SENDMSG          9
CONSTANT: IORING_OP_RECVMSG          10
CONSTANT: IORING_OP_TIMEOUT          11
CONSTANT: IORING_OP_TIMEOUT_REMOVE   12
CONSTANT: IORING_OP_ACCEPT           13
CONSTANT: IORING_OP_ASYNC_CANCEL     14
CONSTANT: IORING_OP_LINK_TIMEOUT     15
CONSTANT: IORING_OP_CONNECT          16
CONSTANT: IORING_OP_FALLOCATE        17
CONSTANT: IORING_OP_OPENAT           18
CONSTANT: IORING_OP_CLOSE            19
CONSTANT: IORING_OP_FILES_UPDATE     20
CONSTANT: IORING_OP_STATX            21
CONSTANT: IORING_OP_READ             22
CONSTANT: IORING_OP_WRITE            23
CONSTANT: IORING_OP_FADVISE          24
CONSTANT: IORING_OP_MADVISE          25
CONSTANT: IORING_OP_SEND             26
CONSTANT: IORING_OP_RECV             27
CONSTANT: IORING_OP_OPENAT2          28
CONSTANT: IORING_OP_EPOLL_CTL        29
CONSTANT: IORING_OP_SPLICE           30
CONSTANT: IORING_OP_PROVIDE_BUFFERS  31
CONSTANT: IORING_OP_REMOVE_BUFFERS   32
CONSTANT: IORING_OP_TEE              33
CONSTANT: IORING_OP_SHUTDOWN         34
CONSTANT: IORING_OP_RENAMEAT         35
CONSTANT: IORING_OP_UNLINKAT         36
CONSTANT: IORING_OP_MKDIRAT          37
CONSTANT: IORING_OP_SYMLINKAT        38
CONSTANT: IORING_OP_LINKAT           39
CONSTANT: IORING_OP_MSG_RING         40
CONSTANT: IORING_OP_FSETXATTR        41
CONSTANT: IORING_OP_SETXATTR         42
CONSTANT: IORING_OP_FGETXATTR        43
CONSTANT: IORING_OP_GETXATTR         44
CONSTANT: IORING_OP_SOCKET           45
CONSTANT: IORING_OP_URING_CMD        46
CONSTANT: IORING_OP_SEND_ZC          47
CONSTANT: IORING_OP_SENDMSG_ZC       48
CONSTANT: IORING_OP_READ_MULTISHOT   49
CONSTANT: IORING_OP_WAITID           50
CONSTANT: IORING_OP_FUTEX_WAIT       51
CONSTANT: IORING_OP_FUTEX_WAKE       52
CONSTANT: IORING_OP_FUTEX_WAITV      53
CONSTANT: IORING_OP_FIXED_FD_INSTALL 54
CONSTANT: IORING_OP_FTRUNCATE        55
CONSTANT: IORING_OP_BIND             56
CONSTANT: IORING_OP_LISTEN           57
CONSTANT: IORING_OP_RECV_ZC          58
CONSTANT: IORING_OP_EPOLL_WAIT       59
CONSTANT: IORING_OP_READV_FIXED      60
CONSTANT: IORING_OP_WRITEV_FIXED     61
CONSTANT: IORING_OP_PIPE             62
CONSTANT: IORING_OP_NOP128           63
CONSTANT: IORING_OP_URING_CMD128     64
CONSTANT: IORING_OP_LAST             65

CONSTANT: IORING_URING_CMD_FIXED    0x01
CONSTANT: IORING_URING_CMD_MULTISHOT 0x02
CONSTANT: IORING_URING_CMD_MASK      0x03

CONSTANT: IORING_FSYNC_DATASYNC 0x01

CONSTANT: IORING_TIMEOUT_ABS            0x01
CONSTANT: IORING_TIMEOUT_UPDATE         0x02
CONSTANT: IORING_TIMEOUT_BOOTTIME       0x04
CONSTANT: IORING_TIMEOUT_REALTIME       0x08
CONSTANT: IORING_LINK_TIMEOUT_UPDATE    0x10
CONSTANT: IORING_TIMEOUT_ETIME_SUCCESS  0x20
CONSTANT: IORING_TIMEOUT_MULTISHOT      0x40
CONSTANT: IORING_TIMEOUT_IMMEDIATE_ARG  0x80
CONSTANT: IORING_TIMEOUT_CLOCK_MASK      0x0c
CONSTANT: IORING_TIMEOUT_UPDATE_MASK     0x12

CONSTANT: SPLICE_F_FD_IN_FIXED 0x80000000

CONSTANT: IORING_POLL_ADD_MULTI        0x01
CONSTANT: IORING_POLL_UPDATE_EVENTS    0x02
CONSTANT: IORING_POLL_UPDATE_USER_DATA 0x04
CONSTANT: IORING_POLL_ADD_LEVEL        0x08

CONSTANT: IORING_ASYNC_CANCEL_ALL        0x01
CONSTANT: IORING_ASYNC_CANCEL_FD         0x02
CONSTANT: IORING_ASYNC_CANCEL_ANY        0x04
CONSTANT: IORING_ASYNC_CANCEL_FD_FIXED   0x08
CONSTANT: IORING_ASYNC_CANCEL_USERDATA   0x10
CONSTANT: IORING_ASYNC_CANCEL_OP         0x20

CONSTANT: IORING_RECVSEND_POLL_FIRST 0x01
CONSTANT: IORING_RECV_MULTISHOT      0x02
CONSTANT: IORING_RECVSEND_FIXED_BUF  0x04
CONSTANT: IORING_SEND_ZC_REPORT_USAGE 0x08
CONSTANT: IORING_RECVSEND_BUNDLE     0x10
CONSTANT: IORING_SEND_VECTORIZED     0x20

CONSTANT: IORING_NOTIF_USAGE_ZC_COPIED 0x80000000

CONSTANT: IORING_ACCEPT_MULTISHOT  0x01
CONSTANT: IORING_ACCEPT_DONTWAIT   0x02
CONSTANT: IORING_ACCEPT_POLL_FIRST 0x04

CONSTANT: IORING_MSG_DATA    0
CONSTANT: IORING_MSG_SEND_FD 1

CONSTANT: IORING_MSG_RING_CQE_SKIP   0x01
CONSTANT: IORING_MSG_RING_FLAGS_PASS 0x02

CONSTANT: IORING_FIXED_FD_NO_CLOEXEC 0x01

CONSTANT: IORING_NOP_INJECT_RESULT 0x01
CONSTANT: IORING_NOP_FILE          0x02
CONSTANT: IORING_NOP_FIXED_FILE    0x04
CONSTANT: IORING_NOP_FIXED_BUFFER  0x08
CONSTANT: IORING_NOP_TW            0x10
CONSTANT: IORING_NOP_CQE32         0x20

CONSTANT: IORING_CQE_F_BUFFER        0x0001
CONSTANT: IORING_CQE_F_MORE          0x0002
CONSTANT: IORING_CQE_F_SOCK_NONEMPTY 0x0004
CONSTANT: IORING_CQE_F_NOTIF         0x0008
CONSTANT: IORING_CQE_F_BUF_MORE      0x0010
CONSTANT: IORING_CQE_F_SKIP          0x0020
CONSTANT: IORING_CQE_F_32            0x8000

CONSTANT: IORING_CQE_BUFFER_SHIFT 16

CONSTANT: IORING_OFF_SQ_RING    0x00000000
CONSTANT: IORING_OFF_CQ_RING    0x08000000
CONSTANT: IORING_OFF_SQES       0x10000000
CONSTANT: IORING_OFF_PBUF_RING  0x80000000
CONSTANT: IORING_OFF_PBUF_SHIFT 16
CONSTANT: IORING_OFF_MMAP_MASK  0xf8000000

CONSTANT: IORING_SQ_NEED_WAKEUP 0x01
CONSTANT: IORING_SQ_CQ_OVERFLOW 0x02
CONSTANT: IORING_SQ_TASKRUN     0x04

CONSTANT: IORING_CQ_EVENTFD_DISABLED 0x01

CONSTANT: IORING_ENTER_GETEVENTS        0x01
CONSTANT: IORING_ENTER_SQ_WAKEUP        0x02
CONSTANT: IORING_ENTER_SQ_WAIT          0x04
CONSTANT: IORING_ENTER_EXT_ARG          0x08
CONSTANT: IORING_ENTER_REGISTERED_RING  0x10
CONSTANT: IORING_ENTER_ABS_TIMER        0x20
CONSTANT: IORING_ENTER_EXT_ARG_REG      0x40
CONSTANT: IORING_ENTER_NO_IOWAIT        0x80

CONSTANT: IORING_FEAT_SINGLE_MMAP     0x00001
CONSTANT: IORING_FEAT_NODROP          0x00002
CONSTANT: IORING_FEAT_SUBMIT_STABLE   0x00004
CONSTANT: IORING_FEAT_RW_CUR_POS      0x00008
CONSTANT: IORING_FEAT_CUR_PERSONALITY 0x00010
CONSTANT: IORING_FEAT_FAST_POLL       0x00020
CONSTANT: IORING_FEAT_POLL_32BITS     0x00040
CONSTANT: IORING_FEAT_SQPOLL_NONFIXED 0x00080
CONSTANT: IORING_FEAT_EXT_ARG         0x00100
CONSTANT: IORING_FEAT_NATIVE_WORKERS  0x00200
CONSTANT: IORING_FEAT_RSRC_TAGS       0x00400
CONSTANT: IORING_FEAT_CQE_SKIP        0x00800
CONSTANT: IORING_FEAT_LINKED_FILE     0x01000
CONSTANT: IORING_FEAT_REG_REG_RING    0x02000
CONSTANT: IORING_FEAT_RECVSEND_BUNDLE 0x04000
CONSTANT: IORING_FEAT_MIN_TIMEOUT     0x08000
CONSTANT: IORING_FEAT_RW_ATTR         0x10000
CONSTANT: IORING_FEAT_NO_IOWAIT       0x20000

CONSTANT: IORING_REGISTER_BUFFERS              0
CONSTANT: IORING_UNREGISTER_BUFFERS            1
CONSTANT: IORING_REGISTER_FILES                2
CONSTANT: IORING_UNREGISTER_FILES              3
CONSTANT: IORING_REGISTER_EVENTFD              4
CONSTANT: IORING_UNREGISTER_EVENTFD            5
CONSTANT: IORING_REGISTER_FILES_UPDATE         6
CONSTANT: IORING_REGISTER_EVENTFD_ASYNC        7
CONSTANT: IORING_REGISTER_PROBE                8
CONSTANT: IORING_REGISTER_PERSONALITY          9
CONSTANT: IORING_UNREGISTER_PERSONALITY        10
CONSTANT: IORING_REGISTER_RESTRICTIONS         11
CONSTANT: IORING_REGISTER_ENABLE_RINGS         12
CONSTANT: IORING_REGISTER_FILES2               13
CONSTANT: IORING_REGISTER_FILES_UPDATE2        14
CONSTANT: IORING_REGISTER_BUFFERS2             15
CONSTANT: IORING_REGISTER_BUFFERS_UPDATE       16
CONSTANT: IORING_REGISTER_IOWQ_AFF             17
CONSTANT: IORING_UNREGISTER_IOWQ_AFF           18
CONSTANT: IORING_REGISTER_IOWQ_MAX_WORKERS     19
CONSTANT: IORING_REGISTER_RING_FDS             20
CONSTANT: IORING_UNREGISTER_RING_FDS           21
CONSTANT: IORING_REGISTER_PBUF_RING            22
CONSTANT: IORING_UNREGISTER_PBUF_RING          23
CONSTANT: IORING_REGISTER_SYNC_CANCEL          24
CONSTANT: IORING_REGISTER_FILE_ALLOC_RANGE     25
CONSTANT: IORING_REGISTER_PBUF_STATUS          26
CONSTANT: IORING_REGISTER_NAPI                 27
CONSTANT: IORING_UNREGISTER_NAPI               28
CONSTANT: IORING_REGISTER_CLOCK                29
CONSTANT: IORING_REGISTER_CLONE_BUFFERS        30
CONSTANT: IORING_REGISTER_SEND_MSG_RING        31
CONSTANT: IORING_REGISTER_ZCRX_IFQ             32
CONSTANT: IORING_REGISTER_RESIZE_RINGS         33
CONSTANT: IORING_REGISTER_MEM_REGION           34
CONSTANT: IORING_REGISTER_QUERY                35
CONSTANT: IORING_REGISTER_ZCRX_CTRL            36
CONSTANT: IORING_REGISTER_BPF_FILTER           37
CONSTANT: IORING_REGISTER_LAST                 38
CONSTANT: IORING_REGISTER_USE_REGISTERED_RING  0x80000000

CONSTANT: IORING_REGISTER_FILES_SKIP -2

CONSTANT: IO_WQ_BOUND   0
CONSTANT: IO_WQ_UNBOUND 1

CONSTANT: IORING_MEM_REGION_TYPE_USER     1
CONSTANT: IORING_MEM_REGION_REG_WAIT_ARG  1

CONSTANT: IORING_RSRC_REGISTER_SPARSE 0x01

CONSTANT: IO_URING_OP_SUPPORTED 0x01

CONSTANT: IORING_REGISTER_SRC_REGISTERED 0x01
CONSTANT: IORING_REGISTER_DST_REPLACE    0x02

CONSTANT: IOU_PBUF_RING_MMAP 1
CONSTANT: IOU_PBUF_RING_INC  2

CONSTANT: IO_URING_NAPI_REGISTER_OP    0
CONSTANT: IO_URING_NAPI_STATIC_ADD_ID  1
CONSTANT: IO_URING_NAPI_STATIC_DEL_ID  2

CONSTANT: IO_URING_NAPI_TRACKING_DYNAMIC  0
CONSTANT: IO_URING_NAPI_TRACKING_STATIC   1
CONSTANT: IO_URING_NAPI_TRACKING_INACTIVE 255

CONSTANT: IORING_RESTRICTION_REGISTER_OP         0
CONSTANT: IORING_RESTRICTION_SQE_OP              1
CONSTANT: IORING_RESTRICTION_SQE_FLAGS_ALLOWED   2
CONSTANT: IORING_RESTRICTION_SQE_FLAGS_REQUIRED  3
CONSTANT: IORING_RESTRICTION_LAST                4

CONSTANT: IORING_REG_WAIT_TS 0x01

CONSTANT: SOCKET_URING_OP_SIOCINQ      0
CONSTANT: SOCKET_URING_OP_SIOCOUTQ     1
CONSTANT: SOCKET_URING_OP_GETSOCKOPT   2
CONSTANT: SOCKET_URING_OP_SETSOCKOPT   3
CONSTANT: SOCKET_URING_OP_TX_TIMESTAMP 4
CONSTANT: SOCKET_URING_OP_GETSOCKNAME  5

CONSTANT: BLOCK_URING_CMD_DISCARD 0x1200

CONSTANT: IORING_TIMESTAMP_HW_SHIFT   16
CONSTANT: IORING_TIMESTAMP_TYPE_SHIFT 17
CONSTANT: IORING_CQE_F_TSTAMP_HW      0x00010000

CONSTANT: IO_URING_QUERY_OPCODES 0
CONSTANT: IO_URING_QUERY_ZCRX    1
CONSTANT: IO_URING_QUERY_SCQ     2
CONSTANT: IO_URING_QUERY_MAX     3

CONSTANT: IORING_ZCRX_AREA_SHIFT 48
CONSTANT: IORING_ZCRX_AREA_MASK  0xffff000000000000

CONSTANT: IORING_ZCRX_AREA_DMABUF 1

CONSTANT: ZCRX_REG_IMPORT 1
CONSTANT: ZCRX_REG_NODEV  2

CONSTANT: ZCRX_FEATURE_RX_PAGE_SIZE 0x01

CONSTANT: ZCRX_CTRL_FLUSH_RQ 0
CONSTANT: ZCRX_CTRL_EXPORT   1
CONSTANT: ZCRX_CTRL_LAST     2

CONSTANT: IO_URING_BPF_FILTER_DENY_REST 0x01
CONSTANT: IO_URING_BPF_FILTER_SZ_STRICT 0x02

CONSTANT: IO_URING_BPF_CMD_FILTER 1

CONSTANT: IORING_MOCK_FEAT_CMD_COPY 0
CONSTANT: IORING_MOCK_FEAT_RW_ZERO  1
CONSTANT: IORING_MOCK_FEAT_RW_NOWAIT 2
CONSTANT: IORING_MOCK_FEAT_RW_ASYNC 3
CONSTANT: IORING_MOCK_FEAT_POLL     4
CONSTANT: IORING_MOCK_FEAT_END      5

CONSTANT: IORING_MOCK_CREATE_F_SUPPORT_NOWAIT 1
CONSTANT: IORING_MOCK_CREATE_F_POLL           2

CONSTANT: IORING_MOCK_MGR_CMD_PROBE  0
CONSTANT: IORING_MOCK_MGR_CMD_CREATE 1

CONSTANT: IORING_MOCK_CMD_COPY_REGBUF 0
CONSTANT: IORING_MOCK_COPY_FROM       1
