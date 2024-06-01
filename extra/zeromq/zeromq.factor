! Copyright (C) 2011-2013 Eungju PARK, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays byte-arrays
classes.struct combinators destructors fry kernel libc math math.order
memoize sequences zeromq.ffi ;

IN: zeromq

ERROR: zmq-error n string ;

: throw-zmq-error ( -- )
    zmq_errno dup zmq_strerror zmq-error ; inline

: check-zmq-error ( retval -- )
    [ throw-zmq-error ] unless-zero ; inline

: zmq-version ( -- version )
    { int int int } [ zmq_version ] with-out-parameters 3array ;

: zmq-version-numeric ( -- n )
    zmq-version first3 [ 100 * ] [ 10 * ] [ 1 * ] tri* + + ;

! See
! https://github.com/chuckremes/ffi-rzmq-core/blob/master/lib/ffi-rzmq-core/structures.rb
MEMO: zmq-msg-size ( -- x )
    zmq-version-numeric 410 <=> {
        { +lt+ [ 32 ] }
        { +eq+ [ 48 ] }
        { +gt+ [ 64 ] }
    } case ;

! This word should be used to allocate the zmq_msg_t struct because
! the size of it varies between versions.
: <zmq_msg_t> ( -- byte-array )
    zmq-msg-size (byte-array) ;

GENERIC#: zmq-setopt 2 ( obj name value -- )
GENERIC#: zmq-getopt 1 ( obj name -- value )

TUPLE: zmq-message underlying disposed ;

: <zmq-message> ( -- msg )
    <zmq_msg_t>
    [ zmq_msg_init check-zmq-error ]
    [ f zmq-message boa ] bi ;

M: zmq-message dispose*
    underlying>> zmq_msg_close check-zmq-error ;

: byte-array>zmq-message ( byte-array -- msg )
    <zmq_msg_t>
    [ over length zmq_msg_init_size check-zmq-error ]
    [ zmq_msg_data swap dup length memcpy ]
    [ zmq-message boa ] tri ;

: zmq-message>byte-array ( msg -- byte-array )
    underlying>> [ zmq_msg_data ] [ zmq_msg_size ] bi
    [ drop B{ } ] [ memory>byte-array ] if-zero ;

TUPLE: zmq-context underlying disposed ;

! this uses the "New API" with version 3
! previous versions should use zmq_init and zmq_term

: <zmq-context> ( -- context )
    zmq_ctx_new f zmq-context boa ;

M: zmq-context dispose*
    underlying>> zmq_ctx_destroy check-zmq-error ;

M: zmq-context zmq-setopt
    [ underlying>> ] 2dip zmq_ctx_set check-zmq-error ;

M: zmq-context zmq-getopt
    [ underlying>> ] dip zmq_ctx_get ;

TUPLE: zmq-socket underlying disposed ;

: <zmq-socket> ( context type -- socket )
    [ underlying>> ] dip zmq_socket
    dup [ throw-zmq-error ] unless
    f zmq-socket boa ;

M: zmq-socket dispose*
    underlying>> zmq_close check-zmq-error ;

M: zmq-socket zmq-setopt
    [ underlying>> ] 2dip over {
        { ZMQ_SUBSCRIBE [ dup length ] }
        { ZMQ_UNSUBSCRIBE [ dup length ] }
        { ZMQ_RCVTIMEO [ 4 ] }
        { ZMQ_SNDTIMEO [ 4 ] }
    } case zmq_setsockopt check-zmq-error ;

: zmq-bind ( socket addr -- )
    [ underlying>> ] dip zmq_bind check-zmq-error ;

: zmq-unbind ( socket addr -- )
    [ underlying>> ] dip zmq_unbind check-zmq-error ;

: zmq-connect ( socket addr -- )
    [ underlying>> ] dip zmq_connect check-zmq-error ;

: zmq-disconnect ( socket addr -- )
    [ underlying>> ] dip zmq_disconnect check-zmq-error ;

: zmq-sendmsg ( socket msg flags -- )
    [ [ underlying>> ] bi@ ] dip zmq_sendmsg
    0 < [ throw-zmq-error ] when ;

: zmq-recvmsg ( socket msg flags -- )
    [ [ underlying>> ] bi@ ] dip zmq_recvmsg
    0 < [ throw-zmq-error ] when ;

: zmq-send ( socket byte-array flags -- )
    [ byte-array>zmq-message ] dip
    '[ _ zmq-sendmsg ] with-disposal ;

: zmq-recv ( socket flags -- byte-array )
    <zmq-message> [
        [ swap zmq-recvmsg ] [ zmq-message>byte-array ] bi
    ] with-disposal ;
