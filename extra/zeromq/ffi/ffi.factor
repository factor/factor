! Copyright (C) 2011-2013 Eungju PARK, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: alien alien.accessors alien.c-types alien.data
alien.libraries alien.syntax assocs byte-arrays classes.struct
combinators kernel literals math system ;

IN: zeromq.ffi

C-LIBRARY: zmq cdecl {
    { windows "libzmq.dll" }
    { macos "libzmq.dylib" }
    { unix "libzmq.so" }
}

LIBRARY: zmq

!
! 0MQ versioning support.
!

! Run-time API version detection
FUNCTION: void zmq_version ( int* major, int* minor, int* patch )

!
! 0MQ errors.
!

! A number random enough not to collide with different errno ranges on
! different OSes. The assumption is that error_t is at least 32-bit type.
<< CONSTANT: ZMQ_HAUSNUMERO 156384712 >>

! Native 0MQ error codes.
CONSTANT: EFSM $[ ZMQ_HAUSNUMERO 51 + ]
CONSTANT: ENOCOMPATPROTO $[ ZMQ_HAUSNUMERO 52 + ]
CONSTANT: ETERM $[ ZMQ_HAUSNUMERO 53 + ]
CONSTANT: EMTHREAD $[ ZMQ_HAUSNUMERO 54 + ]

! This function retrieves the errno as it is known to 0MQ library. The goal
! of this function is to make the code 100% portable, including where 0MQ
! compiled with certain CRT library (on Windows) is linked to an
! application that uses different CRT library.
FUNCTION: int zmq_errno ( )

! Resolves system errors and 0MQ errors to human-readable string.
FUNCTION: c-string zmq_strerror ( int errnum )

!
! 0MQ infrastructure (a.k.a. context) initialisation & termination.
!

! New API
! Context options
CONSTANT: ZMQ_IO_THREADS  1
CONSTANT: ZMQ_MAX_SOCKETS 2

! Default for new contexts
CONSTANT: ZMQ_IO_THREADS_DFLT  1
CONSTANT: ZMQ_MAX_SOCKETS_DFLT 1024

FUNCTION: void* zmq_ctx_new ( )
FUNCTION: int zmq_ctx_destroy ( void* context )
FUNCTION: int zmq_ctx_set ( void* context, int option, int optval )
FUNCTION: int zmq_ctx_get ( void* context, int option )

! Old (legacy) API
FUNCTION: void* zmq_init ( int io_threads )
FUNCTION: int zmq_term ( void* context )

!
! 0MQ message definition.
!

FUNCTION: int zmq_msg_init ( void* msg )
FUNCTION: int zmq_msg_init_size ( void* msg, size_t size )
FUNCTION: int zmq_msg_init_data ( void* msg, void* data, size_t size, void* ffn, void* hint )
FUNCTION: int zmq_msg_send ( void* msg, void* s, int flags )
FUNCTION: int zmq_msg_recv ( void* msg, void* s, int flags )
FUNCTION: int zmq_msg_close ( void* msg )
FUNCTION: int zmq_msg_move ( void* dest, void* src )
FUNCTION: int zmq_msg_copy ( void* dest, void* src )
FUNCTION: void* zmq_msg_data ( void* msg )
FUNCTION: size_t zmq_msg_size ( void* msg )
FUNCTION: int zmq_msg_more ( void* msg )
FUNCTION: int zmq_msg_get ( void* msg, int option )
FUNCTION: int zmq_msg_set ( void* msg, int option, int optval )

!
! 0MQ socket definition.
!

! Socket types.
CONSTANT: ZMQ_PAIR 0
CONSTANT: ZMQ_PUB 1
CONSTANT: ZMQ_SUB 2
CONSTANT: ZMQ_REQ 3
CONSTANT: ZMQ_REP 4
CONSTANT: ZMQ_DEALER 5
CONSTANT: ZMQ_ROUTER 6
CONSTANT: ZMQ_PULL 7
CONSTANT: ZMQ_PUSH 8
CONSTANT: ZMQ_XPUB 9
CONSTANT: ZMQ_XSUB 10

! Deprecated aliases
ALIAS: ZMQ_XREQ ZMQ_DEALER
ALIAS: ZMQ_XREP ZMQ_ROUTER

! Socket options.
CONSTANT: ZMQ_AFFINITY 4
CONSTANT: ZMQ_IDENTITY 5
CONSTANT: ZMQ_SUBSCRIBE 6
CONSTANT: ZMQ_UNSUBSCRIBE 7
CONSTANT: ZMQ_RATE 8
CONSTANT: ZMQ_RECOVERY_IVL 9
CONSTANT: ZMQ_SNDBUF 11
CONSTANT: ZMQ_RCVBUF 12
CONSTANT: ZMQ_RCVMORE 13
CONSTANT: ZMQ_FD 14
CONSTANT: ZMQ_EVENTS 15
CONSTANT: ZMQ_TYPE 16
CONSTANT: ZMQ_LINGER 17
CONSTANT: ZMQ_RECONNECT_IVL 18
CONSTANT: ZMQ_BACKLOG 19
CONSTANT: ZMQ_RECONNECT_IVL_MAX 21
CONSTANT: ZMQ_MAXMSGSIZE 22
CONSTANT: ZMQ_SNDHWM 23
CONSTANT: ZMQ_RCVHWM 24
CONSTANT: ZMQ_MULTICAST_HOPS 25
CONSTANT: ZMQ_RCVTIMEO 27
CONSTANT: ZMQ_SNDTIMEO 28
CONSTANT: ZMQ_IPV4ONLY 31
CONSTANT: ZMQ_LAST_ENDPOINT 32
CONSTANT: ZMQ_ROUTER_MANDATORY 33
CONSTANT: ZMQ_TCP_KEEPALIVE 34
CONSTANT: ZMQ_TCP_KEEPALIVE_CNT 35
CONSTANT: ZMQ_TCP_KEEPALIVE_IDLE 36
CONSTANT: ZMQ_TCP_KEEPALIVE_INTVL 37
CONSTANT: ZMQ_TCP_ACCEPT_FILTER 38
CONSTANT: ZMQ_DELAY_ATTACH_ON_CONNECT 39
CONSTANT: ZMQ_XPUB_VERBOSE 40

! Message options
CONSTANT: ZMQ_MORE 1

! Send/recv options.
CONSTANT: ZMQ_DONTWAIT 1
CONSTANT: ZMQ_SNDMORE 2

! Deprecated aliases
ALIAS: ZMQ_NOBLOCK ZMQ_DONTWAIT
ALIAS: ZMQ_FAIL_UNROUTABLE ZMQ_ROUTER_MANDATORY
ALIAS: ZMQ_ROUTER_BEHAVIOR ZMQ_ROUTER_MANDATORY

!
! 0MQ socket events and monitoring
!

! Socket transport events (tcp and ipc only)
CONSTANT: ZMQ_EVENT_CONNECTED 1
CONSTANT: ZMQ_EVENT_CONNECT_DELAYED 2
CONSTANT: ZMQ_EVENT_CONNECT_RETRIED 4

CONSTANT: ZMQ_EVENT_LISTENING 8
CONSTANT: ZMQ_EVENT_BIND_FAILED 16

CONSTANT: ZMQ_EVENT_ACCEPTED 32
CONSTANT: ZMQ_EVENT_ACCEPT_FAILED 64

CONSTANT: ZMQ_EVENT_CLOSED 128
CONSTANT: ZMQ_EVENT_CLOSE_FAILED 256
CONSTANT: ZMQ_EVENT_DISCONNECTED 512

CONSTANT: ZMQ_EVENT_ALL flags{
    ZMQ_EVENT_CONNECTED ZMQ_EVENT_CONNECT_DELAYED
    ZMQ_EVENT_CONNECT_RETRIED ZMQ_EVENT_LISTENING
    ZMQ_EVENT_BIND_FAILED ZMQ_EVENT_ACCEPTED
    ZMQ_EVENT_ACCEPT_FAILED ZMQ_EVENT_CLOSED
    ZMQ_EVENT_CLOSE_FAILED ZMQ_EVENT_DISCONNECTED
}

! Socket event data (union member per event)
STRUCT: zmq_event_t
    { event int }
    { addr c-string }
    { fd-or-err int } ;

FUNCTION: void* zmq_socket ( void* ctx, int type )
FUNCTION: int zmq_close ( void* s )
FUNCTION: int zmq_setsockopt ( void* s, int option, void* optval, size_t optvallen )
FUNCTION: int zmq_getsockopt ( void* s, int option, void* optval, size_t* optvallen )
FUNCTION: int zmq_bind ( void* s, c-string addr )
FUNCTION: int zmq_connect ( void* s, c-string addr )
FUNCTION: int zmq_unbind ( void* s, c-string addr )
FUNCTION: int zmq_disconnect ( void* s, c-string addr )
FUNCTION: int zmq_send ( void* s, void* buf, size_t len, int flags )
FUNCTION: int zmq_recv ( void* s, void* buf, size_t len, int flags )
FUNCTION: int zmq_socket_monitor ( void* s, c-string addr, int events )

FUNCTION: int zmq_sendmsg ( void* s, void* msg, int flags )
FUNCTION: int zmq_recvmsg ( void* s, void* msg, int flags )

! Experimental
FUNCTION: int zmq_sendiov ( void* s, void* iov, size_t count, int flags )
FUNCTION: int zmq_recviov ( void* s, void* iov, size_t* count, int flags )

!
! I/O multiplexing.
!

CONSTANT: ZMQ_POLLIN 1
CONSTANT: ZMQ_POLLOUT 2
CONSTANT: ZMQ_POLLERR 4

! FIXME: { fd SOCKET } on Windows
STRUCT: zmq_pollitem_t
    { socket void* }
    { fd int }
    { events short }
    { revents short } ;

FUNCTION: int zmq_poll ( zmq_pollitem_t* items, int nitems, long timeout )

! Built-in message proxy (3-way)

FUNCTION: int zmq_proxy ( void* frontend, void* backend, void* capture )

! Deprecated aliases
CONSTANT: ZMQ_STREAMER 1
CONSTANT: ZMQ_FORWARDER 2
CONSTANT: ZMQ_QUEUE 3
! Deprecated method
FUNCTION: int zmq_device ( int type, void* frontend, void* backend )
