! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs byte-arrays combinators fry
io io.encodings.binary io.sockets kernel make math math.parser
namespaces pack random sequences strings ;

IN: memcached

! TODO:
! - quiet commands
! - CAS
! - expirations
! - initial-value for incr/decr


SYMBOL: memcached-server
"127.0.0.1" 11211 <inet> memcached-server set-global

: with-memcached ( quot -- )
    memcached-server get-global
    binary [ call ] with-client ; inline

ERROR: key-not-found ;
ERROR: key-exists ;
ERROR: value-too-large ;
ERROR: invalid-arguments ;
ERROR: item-not-stored ;
ERROR: value-not-numeric ;
ERROR: unknown-command ;
ERROR: out-of-memory ;

<PRIVATE

! Commands
CONSTANT: GET      HEX: 00
CONSTANT: SET      HEX: 01
CONSTANT: ADD      HEX: 02
CONSTANT: REPLACE  HEX: 03
CONSTANT: DELETE   HEX: 04
CONSTANT: INCR     HEX: 05
CONSTANT: DECR     HEX: 06
CONSTANT: QUIT     HEX: 07
CONSTANT: FLUSH    HEX: 08
CONSTANT: GETQ     HEX: 09
CONSTANT: NOOP     HEX: 0A
CONSTANT: VERSION  HEX: 0B
CONSTANT: GETK     HEX: 0C
CONSTANT: GETKQ    HEX: 0D
CONSTANT: APPEND   HEX: 0E
CONSTANT: PREPEND  HEX: 0F
CONSTANT: STAT     HEX: 10
CONSTANT: SETQ     HEX: 11
CONSTANT: ADDQ     HEX: 12
CONSTANT: REPLACEQ HEX: 13
CONSTANT: DELETEQ  HEX: 14
CONSTANT: INCRQ    HEX: 15
CONSTANT: DECRQ    HEX: 16
CONSTANT: QUITQ    HEX: 17
CONSTANT: FLUSHQ   HEX: 18
CONSTANT: APPENDQ  HEX: 19
CONSTANT: PREPENDQ HEX: 1A

! Errors
CONSTANT: NOT_FOUND    HEX: 01
CONSTANT: EXISTS       HEX: 02
CONSTANT: TOO_LARGE    HEX: 03
CONSTANT: INVALID_ARGS HEX: 04
CONSTANT: NOT_STORED   HEX: 05
CONSTANT: NOT_NUMERIC  HEX: 06
CONSTANT: UNKNOWN_CMD  HEX: 81
CONSTANT: MEMORY       HEX: 82

TUPLE: request cmd key val extra opaque cas ;

: <request> ( cmd -- request )
    "" "" "" random-32 0 \ request boa ;

: send-header ( request -- )
    {
        [ cmd>> ]
        [ key>> length ]
        [ extra>> length ]
        [
            [ key>> length ]
            [ extra>> length ]
            [ val>> length ] tri + +
        ]
        [ opaque>> ]
        [ cas>> ]
    } cleave
    ! magic, opcode, keylen, extralen, datatype, status,
    ! bodylen, opaque, cas [ big-endian ]
    '[ HEX: 80 _ _ _ 0 0 _ _ _ ] "CCSCCSIIQ" pack-be write ;

: (send) ( str -- )
    [ >byte-array write ] unless-empty ;

: send-request ( request -- )
    {
        [ send-header    ]
        [ extra>> (send) ]
        [ key>>   (send) ]
        [ val>>   (send) ]
    } cleave flush ;

: read-header ( -- header )
    "CCSCCSIIQ" [ packed-length read ] [ unpack-be ] bi ;

: check-magic ( header -- )
    first HEX: 81 = [ "bad magic" throw ] unless ;

: check-status ( header -- )
    [ 5 ] dip nth {
        { NOT_FOUND    [ key-not-found     ] }
        { EXISTS       [ key-exists        ] }
        { TOO_LARGE    [ value-too-large   ] }
        { INVALID_ARGS [ invalid-arguments ] }
        { NOT_STORED   [ item-not-stored   ] }
        { NOT_NUMERIC  [ value-not-numeric ] }
        { UNKNOWN_CMD  [ unknown-command   ] }
        { MEMORY       [ out-of-memory     ] }
        [ drop ]
    } case ;

: check-opaque ( opaque header -- ? )
    [ 7 ] dip nth = ;

: (read) ( n -- str )
    dup 0 > [ read >string ] [ drop "" ] if ;

: read-key ( header -- key )
    [ 2 ] dip nth (read) ;

: read-val ( header -- val )
    [ [ 6 ] dip nth ] [ [ 2 ] dip nth ] bi - (read) ;

: read-body ( header -- val key )
    {
        [ check-magic  ]
        [ check-status ]
        [ read-key     ]
        [ read-val     ]
    } cleave swap ;

: read-response ( -- val key )
    read-header read-body ;

: submit ( request -- response )
    send-request read-response drop ;

: (cmd) ( key cmd -- request )
    <request> swap >>key ;

: (incr/decr) ( amt key cmd -- response )
    (cmd) swap '[ _ 0 0 ] "QQI" pack-be >>extra ! amt init exp
    submit "Q" unpack-be first ;

: (mutate) ( val key cmd -- )
    (cmd) swap >>val { 0 0 } "II" pack-be >>extra ! flags exp
    submit drop ;

: (cat) ( val key cmd -- )
    (cmd) swap >>val submit drop ;

PRIVATE>

: m/version ( -- version ) VERSION <request> submit ;

: m/noop ( -- ) NOOP <request> submit drop ;

: m/incr-val ( amt key -- val ) INCR (incr/decr) ;

: m/incr ( key -- val ) 1 swap m/incr-val ;

: m/decr-val ( amt key -- val ) DECR (incr/decr) ;

: m/decr ( key -- val ) 1 swap m/decr-val ;

: m/get ( key -- val ) GET (cmd) submit 4 tail ;

: m/getq ( opaque key -- )
    GETQ (cmd) swap >>opaque send-request ;

: m/getseq ( keys -- vals )
    [ H{ } clone ] dip
    [ <enum> [ m/getq ] assoc-each ]
    [ length 10 + NOOP <request> swap >>opaque send-request ]
    [
        <enum> [
            assoc-size 10 + '[
                _ read-header [ check-opaque ] keep swap
            ]
        ] [
            '[
                [ read-body drop 4 tail ]
                [ [ 7 ] dip nth _ at ]
                bi pick set-at
            ]
        ] bi until drop
    ] tri ;

: m/set ( val key -- ) SET (mutate) ;

: m/add ( val key -- ) ADD (mutate) ;

: m/replace ( val key -- ) REPLACE (mutate) ;

: m/delete ( key -- ) DELETE (cmd) submit drop ;

: m/append ( val key -- ) APPEND (cat) ;

: m/prepend ( val key -- ) PREPEND (cat) ;

: m/flush-later ( seconds -- )
    FLUSH <request> swap 1array "I" pack-be >>extra ! timebomb
    submit drop ;

: m/flush ( -- ) 0 m/flush-later ;

: m/stats ( -- stats )
    STAT <request> send-request
    [ read-response dup length 0 > ]
    [ swap 2array ] produce 2nip ;

: m/quit ( -- ) QUIT <request> submit drop ;


