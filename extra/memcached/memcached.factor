! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs byte-arrays combinators io
io.encodings.binary io.sockets kernel math namespaces pack
random sequences strings ;

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
CONSTANT: GET      0x00
CONSTANT: SET      0x01
CONSTANT: ADD      0x02
CONSTANT: REPLACE  0x03
CONSTANT: DELETE   0x04
CONSTANT: INCR     0x05
CONSTANT: DECR     0x06
CONSTANT: QUIT     0x07
CONSTANT: FLUSH    0x08
CONSTANT: GETQ     0x09
CONSTANT: NOOP     0x0A
CONSTANT: VERSION  0x0B
CONSTANT: GETK     0x0C
CONSTANT: GETKQ    0x0D
CONSTANT: APPEND   0x0E
CONSTANT: PREPEND  0x0F
CONSTANT: STAT     0x10
CONSTANT: SETQ     0x11
CONSTANT: ADDQ     0x12
CONSTANT: REPLACEQ 0x13
CONSTANT: DELETEQ  0x14
CONSTANT: INCRQ    0x15
CONSTANT: DECRQ    0x16
CONSTANT: QUITQ    0x17
CONSTANT: FLUSHQ   0x18
CONSTANT: APPENDQ  0x19
CONSTANT: PREPENDQ 0x1A

! Errors
CONSTANT: NOT_FOUND    0x01
CONSTANT: EXISTS       0x02
CONSTANT: TOO_LARGE    0x03
CONSTANT: INVALID_ARGS 0x04
CONSTANT: NOT_STORED   0x05
CONSTANT: NOT_NUMERIC  0x06
CONSTANT: UNKNOWN_CMD  0x81
CONSTANT: MEMORY       0x82

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
    '[ 0x80 _ _ _ 0 0 _ _ _ ] "CCSCCSIIQ" pack-be write ;

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
    first 0x81 = [ "bad magic" throw ] unless ;

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
    [ <enumerated> [ m/getq ] assoc-each ]
    [ length 10 + NOOP <request> swap >>opaque send-request ]
    [
        <enumerated> [
            assoc-size 10 + '[
                _ read-header [ check-opaque ] 1check
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
