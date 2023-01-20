! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays calendar combinators formatting
io.sockets kernel math pack random sequences ;

IN: ntp

<PRIVATE

CONSTANT: REQUEST B{ 0x1b 0 0 0 0 0 0 0
                     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                     0 0 0 0 0 0 0 0 }

: (time) ( sequence -- timestamp )
    [ first ] [ second 32 2^ / ] bi + seconds
    1900 1 1 0 0 0 instant <timestamp> time+ ;

: (leap) ( leap -- string/f )
    {
        { 0 [ "no warning" ] }
        { 1 [ "last minute has 61 seconds" ] }
        { 2 [ "last minute has 59 seconds" ] }
        { 3 [ "alarm condition (clock not synchronized)" ] }
        [ drop f ]
    } case ;

: (mode) ( mode -- string )
    {
        { 0 [ "unspecified" ] }
        { 1 [ "symmetric active" ] }
        { 2 [ "symmetric passive" ] }
        { 3 [ "client" ] }
        { 4 [ "server" ] }
        { 5 [ "broadcast" ] }
        { 6 [ "reserved for NTP control message" ] }
        { 7 [ "reserved for private use" ] }
        [ drop f ]
    } case ;

: (stratum) ( stratum -- string )
    {
        { 0 [ "unspecified or unavailable" ] }
        { 1 [ "primary reference (e.g., radio clock)" ] }
        [
            [ 1 > ] [ 255 < ] bi and
            [ "secondary reference (via NTP or SNTP)" ]
            [ "invalid stratum" throw ] if
        ]
    } case ;

: (ref-id) ( ref-id stratum -- string )
    [
        {
            [ -24 shift 0xff bitand ]
            [ -16 shift 0xff bitand ]
            [ -8 shift 0xff bitand ]
            [ 0xff bitand ]
        } cleave
    ] dip {
        { 0 [ "%c%c%c%c" sprintf ] }
        { 1 [ "%c%c%c%c" sprintf ] }
        [
            [ 1 > ] [ 255 < ] bi and
            [ "%d.%d.%d.%d" sprintf ]
            [ "invalid stratum" throw ] if
        ]
    } case ;

TUPLE: ntp leap version mode stratum poll precision
root-delay root-dispersion ref-id ref-timestamp
orig-timestamp recv-timestamp tx-timestamp ;

: (ntp) ( payload -- ntp )
    "CCCcIIIIIIIIIII" unpack-be {
        [ first -6 shift 0x3 bitand ]  ! leap
        [ first -3 shift 0x7 bitand ]  ! version
        [ first 0x7 bitand ]           ! mode
        [ second ]                        ! stratum
        [ third ]                         ! poll
        [ [ 3 ] dip nth ]                 ! precision
        [ [ 4 ] dip nth 16 2^ / ]         ! root-delay
        [ [ 5 ] dip nth 16 2^ / ]         ! root-dispersion
        [ [ 6 ] dip nth ]                 ! ref-id
        [ [ { 7 8 } ] dip nths (time) ]   ! ref-timestamp
        [ [ { 9 10 } ] dip nths (time) ]  ! orig-timestamp
        [ [ { 11 12 } ] dip nths (time) ] ! recv-timestamp
        [ [ { 13 14 } ] dip nths (time) ] ! tx-timestamp
    } cleave ntp boa
    dup stratum>> '[ _ (ref-id) ] change-ref-id
    [ dup (leap) 2array ] change-leap
    [ dup (mode) 2array ] change-mode
    [ dup (stratum) 2array ] change-stratum ;

PRIVATE>

! TODO:
! - socket timeout?
! - format request properly?
! - strftime should format millis?
! - why does <inet4> resolve-host not work?

: <ntp> ( host -- ntp )
    123 <inet> resolve-host
    [ inet4? ] filter random [
        [ REQUEST ] 2dip [ send ] [ receive drop ] bi (ntp)
    ] with-any-port-local-datagram ;

: default-ntp ( -- ntp )
    "pool.ntp.org" <ntp> ;

: local-ntp ( -- ntp )
    "localhost" <ntp> ;
