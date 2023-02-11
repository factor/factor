! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
arrays ascii assocs combinators combinators.smart grouping
hashtables io io.backend io.directories io.encodings.binary
io.files io.files.links io.pathnames kernel
linux.input-events.ffi math namespaces pack prettyprint
sequences splitting unix.time ;
FROM: io => read ;
IN: linux.input-events

: input-events-assoc ( path -- assoc )
    dup '[
        _ qualified-directory-files
        [ read-link normalize-path ] zip-with
    ] with-directory ;

: input-events-by-id-assoc ( -- assoc )
    "/dev/input/by-id/" input-events-assoc ;

: input-events-by-path-assoc ( -- assoc )
    "/dev/input/by-path/" input-events-assoc ;

: devices-by-type-assoc ( -- assoc )
    input-events-by-id-assoc [
        first "-" split1-last nip
        [ digit? ] trim-tail
    ] collect-by ;

: event-code-value ( type code value -- a b c )
    [ <INPUT_EVENT> ] 2dip
    pick {
        { EV_SYN [ [ <INPUT_SYN> ] dip ] }
        { EV_KEY [ [ <INPUT_KEY> ] dip ] }
        { EV_REL [ [ <INPUT_REL> ] dip ] }
        { EV_ABS [ [ <INPUT_ABS> ] dip ] }
        { EV_MSC [ [ <INPUT_MSC> ] dip ] }
        { EV_SW  [ [ <INPUT_SW> ] dip ] }
        { EV_LED [ [ <INPUT_LED> ] dip ] }
        { EV_SND [ [ <INPUT_SND> ] dip ] }
        { EV_REP [ [ <INPUT_REP> ] dip ] }
        { EV_FF [ [ <INPUT_FF> ] dip ] }
        ! { EV_PWR [ [ <INPUT_PWR> ] dip ] }
        ! { EV_FF_STATUS [ [ <INPUT_FF_STATUS> ] dip ] }
        [ drop ]
    } case ;

: evdev-explode-bitfield ( handle ev count -- seq )
    enum>number 8 /mod [ drop 1 + ] unless-zero evdev-get-bytes seq>explode-positions ;

: evdev-get-syn ( handle -- seq )
    0 EV_CNT evdev-explode-bitfield ;

: EV>seq ( handle EV -- seq )
    dup <INPUT_EVENT> {
        { EV_SYN [ drop evdev-get-syn [ <INPUT_EVENT> ] zip-with ] }
        { EV_KEY [ KEY_CNT evdev-explode-bitfield [ <INPUT_KEY> ] zip-with ] }
        { EV_REL [ REL_CNT evdev-explode-bitfield [ <INPUT_REL> ] zip-with ] }
        { EV_ABS [
            [ ABS_CNT evdev-explode-bitfield ]
            [ drop over [ evdev-get-abs ] with map ] 2bi
            [ [ <INPUT_ABS> ] zip-with ] dip zip
        ] }
        { EV_MSC [ MSC_CNT evdev-explode-bitfield [ <INPUT_MSC> ] zip-with ] }
        { EV_SW  [ SW_CNT evdev-explode-bitfield [ <INPUT_SW> ] zip-with ] }
        { EV_LED [ LED_CNT evdev-explode-bitfield [ <INPUT_LED> ] zip-with ] }
        { EV_SND [ SND_CNT evdev-explode-bitfield [ <INPUT_SND> ] zip-with ] }
        { EV_REP [
            drop evdev-get-repeat "II" unpack
            [ <INPUT_REP> swap 2array ] map-index
        ] }
        { EV_FF [ FF_CNT evdev-explode-bitfield [ <INPUT_FF> ] zip-with ] }
        ! { EV_PWR [ PWR_CNT evdev-explode-bitfield ] }
        { EV_FF_STATUS [ FF_STATUS_MAX evdev-explode-bitfield ] }
        ! [ nip drop "broken" ]
    } case ;

: evdev-get-all-bits ( handle -- all-bits )
    dup evdev-get-syn
    [
        [ nip <INPUT_EVENT> ]
        [ EV>seq ] 2bi 2array
    ] with map >hashtable ;

: evdev-get-all-mt-slots ( handle -- seq )
    INPUT_ABS enum>values [
        [ 65 int <c-array> ] dip
        0 pick set-nth
        [ byte-length ] keep evdev-get-mt-slots
        [ 0 = ] trim-tail
    ] with map sift
    [ unclip <INPUT_ABS> swap 2array ] map ;

: with-event-device ( ..x path quot: ( ..x path fd -- ..y ) -- ..y )
    [ binary over ] dip '[
        _ input-stream get handle>> fd>> @
    ] with-file-reader ; inline

: named ( value key -- pair )
    swap 2array ; inline

: get-event-device-info ( path -- hashtable )
    [
        '[
            _ "path" named
            _ {
                [ evdev-get-id "id" named ]
                [ evdev-get-name "name" named ]
                [ evdev-get-physical "physical" named ]
                [ evdev-get-unique "unique" named ]
                [ evdev-get-prop "props" named ]
                [ evdev-get-all-mt-slots "mt-slots" named ]
                [ evdev-get-key seq>explode-positions [ <INPUT_KEY> ] zip-with "keys" named ]
                [ evdev-get-led seq>explode-positions [ <INPUT_LED> ] zip-with "leds" named ]
                [ evdev-get-sound seq>explode-positions [ <INPUT_SND> ] zip-with "sounds" named ]
                [ evdev-get-switch seq>explode-positions [ <INPUT_SW> ] zip-with "switches" named ]
                [ evdev-get-simulataneous-effects "effects" named ]
                [ evdev-get-event-mask "event-mask" named ]
                [ evdev-get-all-bits "capabilities" named ]
            } cleave
        ] output>array >hashtable
    ] with-event-device ;

: all-controller-stats ( -- seq )
    input-events-by-id-assoc values
    [ file-name "event" head? ] filter
    [ get-event-device-info ] map ;

: events-by-file-name ( -- hashtable )
    all-controller-stats [ "path" of file-name ] collect-by ;

: get-input-events-type ( str -- seq )
    [ input-events-by-id-assoc ] dip
    '[ first _ tail? ] filter ;

: get-input-events-joysticks ( -- seq ) "event-joystick" get-input-events-type ;
: get-input-events-keyboards ( -- seq ) "event-kbd" get-input-events-type ;
: get-input-events-mice ( -- seq ) "event-mouse" get-input-events-type ;

: read-input-events ( -- seq )
    240 read-partial 24 group [
        "QQSSi" unpack-le
        2 cut
        [ first2 <timeval> ]
        [ first3 event-code-value ] bi* 4array
    ] map ;

SLOT: state
SLOT: quit?

: read-controller-loop ( controller -- )
    [ path>> ] [ state>> ] [ ] tri
    '[
        2drop
        [
            _ read-input-events [
                ! "." write
                first4
                [ drop ] 3dip spin {
                    { EV_SYN [ dup SYN_REPORT = [ 2drop ] [ 2array . ] if ] }
                    { EV_KEY [ over 1 = [ pick set-at ] [ nip over delete-at ] if ] }
                    { EV_ABS [ pick set-at ] }
                    { EV_REL [ swap 2array . ] }
                    { EV_MSC [ swap 2array . ] }
                    [
                        "unhandled: " write 3array .
                        ! 3drop
                    ]
                } case
            ] each
            . ! state
            ! drop ! state
            _ quit?>> not
        ] loop
    ] with-event-device ;
