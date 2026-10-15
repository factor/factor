! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data assocs bit-arrays byte-arrays
classes destructors generic io.backend.unix.multiplexers io.backend.unix.multiplexers.select
kernel libc locals math math.order sequences unix.ffi unix.types ;
IN: io.backend.unix.multiplexers.select.haiku

CONSTANT: HAIKU_MSG_PEEK 0x0002
CONSTANT: HAIKU_MSG_DONTWAIT 0x0080
CONSTANT: HAIKU_DATAGRAM_RESCAN_NANOS 50000000
TUPLE: haiku-select-mx < select-mx ;

: <haiku-select-mx> ( -- mx )
    haiku-select-mx new-mx
        FD_SETSIZE 8 * <bit-array> >>read-fdset
        FD_SETSIZE 8 * <bit-array> >>write-fdset ;
M: haiku-select-mx dispose* drop ;

! Classify actual descriptors. Ordinary files, pipes, streams and local sockets
! retain their existing select path and do not shorten an infinite wait.
:: haiku-udp-family ( descriptor -- family/f )
    -1 int <ref> :> kind
    4 socklen_t <ref> :> length
    descriptor SOL_SOCKET SO_TYPE kind length getsockopt 0 =
    kind int deref SOCK_DGRAM = and [
        128 <byte-array> :> address
        128 socklen_t <ref> :> address-length
        descriptor address address-length getsockname 0 = [
            1 address nth :> family
            family AF_INET = family AF_INET6 = or family f ?
        ] [ f ] if
    ] [ f ] if ;

! A peek neither removes a real zero packet nor clears its pending socket error.
! An untouched AF_UNSPEC sender is never treated as a packet.
:: haiku-udp-ready? ( descriptor -- ? )
    descriptor haiku-udp-family :> family
    family [
        128 <byte-array> :> address
        128 socklen_t <ref> :> length
        descriptor 1 <byte-array> 1 HAIKU_MSG_PEEK HAIKU_MSG_DONTWAIT bitor
        address length recvfrom :> count
        count 0 >= [
            length socklen_t deref 2 >= 1 address nth family = and
        ] [ errno dup EAGAIN = swap EINTR = or not ] if
    ] [ f ] if ;

:: haiku-rescan-udp ( descriptors mx -- ready? )
    f :> ready!
    descriptors [| descriptor |
        descriptor mx reads>> key? [
            descriptor haiku-udp-ready? [
                descriptor mx input-available t ready!
            ] when
        ] when
    ] each ready ;

! Stock Haiku checks UDP byte count when registering select read interests.
! An already queued empty packet therefore misses level readiness. Keep select
! as the primary wait and check actual nonconsuming packet readiness, with a
! bounded rescan only while UDP reads are pending to close the registration race.
M:: haiku-select-mx wait-for-events ( nanos mx -- )
    mx reads>> keys [ haiku-udp-family ] filter :> datagrams
    datagrams mx haiku-rescan-udp :> ready
    ready [ 0 ] [
        datagrams empty? [ nanos ] [
            nanos [ HAIKU_DATAGRAM_RESCAN_NANOS min ]
            [ HAIKU_DATAGRAM_RESCAN_NANOS ] if*
        ] if
    ] if mx call-next-method
    datagrams mx haiku-rescan-udp drop ;
