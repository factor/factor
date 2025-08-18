! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.data arrays assocs byte-arrays
calendar combinators decimals endian grouping hashtables io
io.encodings.binary io.encodings.string io.encodings.utf8
io.files io.streams.byte-array io.streams.string kernel math
math.order math.parser namespaces sbufs sequences
sequences.generalizations sets splitting strings vectors ;

IN: pickle

ERROR: invalid-opcode opcode ;
ERROR: unsupported-protocol proto ;
ERROR: unsupported-class class ;
ERROR: unsupported-feature ;
ERROR: invalid-string ;
ERROR: invalid-memo key ;

<PRIVATE

ERROR: bad-escape char ;

: escape ( escape -- ch )
    H{
        { CHAR: a  CHAR: \a }
        { CHAR: b  CHAR: \b }
        { CHAR: e  CHAR: \e }
        { CHAR: f  CHAR: \f }
        { CHAR: n  CHAR: \n }
        { CHAR: r  CHAR: \r }
        { CHAR: t  CHAR: \t }
        { CHAR: s  CHAR: \s }
        { CHAR: v  CHAR: \v }
        { CHAR: \s CHAR: \s }
        { CHAR: 0  CHAR: \0 }
        { CHAR: \\ CHAR: \\ }
        { CHAR: \" CHAR: \" }
        { CHAR: ' CHAR: ' }
    } ?at [ bad-escape ] unless ;

: oct-escape ( str -- ch/f str' )
    dup 3 index-or-length head-slice [
        [ CHAR: 0 CHAR: 7 between? not ] find drop
    ] keep '[ _ length ] unless* [ f ] when-zero
    [ cut-slice [ oct> ] dip ] [ f swap ] if* ;

: next-escape ( str -- ch str' )
    oct-escape over [
        nip unclip-slice {
            { CHAR: x [ 2 cut-slice [ hex> ] dip ] }
            { CHAR: u [ 4 cut-slice [ hex> ] dip ] }
            { CHAR: U [ 8 cut-slice [ hex> ] dip ] }
            { CHAR: \n [ f swap ] }
            [ escape swap ]
        } case
    ] unless ;

: (unescape-string) ( accum str i/f -- accum )
    [
        cut-slice [ append! ] dip
        rest-slice next-escape [ [ suffix! ] when* ] dip
        CHAR: \\ over index (unescape-string)
    ] [
        append!
    ] if* ;

: unescape-string ( str -- str' )
    CHAR: \\ over index [
        [ [ length <sbuf> ] keep ] dip (unescape-string)
    ] when* "" like ;

SYMBOLS: +marker+ +no-return+ ;

: stack ( -- stack ) \ stack get ;

: memo ( -- memo ) \ memo get ;

: construct-array ( args -- obj )
    unclip {
        { CHAR: c [ alien.c-types:char ] }
        { CHAR: u [ alien.c-types:char ] }
        { CHAR: b [ int8_t ] }
        { CHAR: B [ uint8_t ] }
        { CHAR: h [ int16_t ] }
        { CHAR: H [ uint16_t ] }
        { CHAR: i [ int32_t ] }
        { CHAR: I [ uint32_t ] }
        { CHAR: l [ int64_t ] }
        { CHAR: L [ uint64_t ] }
        { CHAR: f [ alien.c-types:float ] }
        { CHAR: d [ alien.c-types:double ] }
    } case >c-array ;

: construct-bytes ( args -- obj )
    dup length {
        { 0 [ drop B{ } clone ] }
        { 1 [ first >byte-array ] }
    } case ;

: construct-complex ( args -- obj )
    first2 rect> ;

: construct-set ( args -- obj )
    fast-set ;

: construct-decimal ( args -- obj )
    first string>decimal ;

: construct-duration ( args -- obj )
    [ 0 0 ] dip [ first 0 0 ] [ second ] [ third 1,000,000 / + ] tri <duration> ;

: construct-date ( args -- obj )
    first3 <date-gmt> ;

: construct-datetime ( args -- obj )
    ! XXX: support timezones
    7 firstn 1,000,000 / + instant <timestamp> ;

: construct-time ( args -- obj )
    [ 0 0 0 ] dip first4 1,000,000 / + instant <timestamp> ;

CONSTANT: constructors H{
    { "__builtin__.bytes" construct-bytes }
    { "__builtin__.bytearray" construct-bytes }
    { "__builtin__.complex" construct-complex }
    { "__builtin__.set" construct-set }
    { "array.array" construct-array }
    { "builtins.bytearray" construct-bytes }
    { "builtins.complex" construct-complex }
    { "builtins.set" construct-set }
    { "cdecimal.Decimal" construct-decimal }
    { "decimal.Decimal" construct-decimal }
    { "datetime.timedelta" construct-duration }
    { "datetime.date" construct-date }
    { "datetime.datetime" construct-datetime }
    { "datetime.time" construct-time }
}

: construct ( args typename -- obj )
    constructors ?at [ execute( args -- obj ) ] [ unsupported-class ] if ;

: get-memo ( i -- )
    memo ?at [ stack push ] [ invalid-memo ] if ;

: put-memo ( i -- )
    [ stack last ] dip memo set-at ;

: pop-from-marker ( -- items )
    +marker+ stack last-index
    [ 1 + stack swap tail ] [ stack shorten ] bi ;

: load-mark ( -- ) +marker+ stack push ;
: load-pop ( -- ) stack pop* ;
: load-pop-mark ( -- ) +marker+ stack last-index stack shorten ;
: load-dup ( -- ) stack last stack push ;
: load-float ( -- ) readln dec> >float stack push ;
: load-int ( -- )
    readln B{ } like {
        { B{ 48 49 } [ t ] }
        { B{ 48 48 } [ f ] }
        [ dec> ]
    } case stack push ;
: load-binint ( -- ) 4 read signed-le> stack push ;
: load-binint1 ( -- ) read1 stack push ;
: load-long ( -- ) readln "L" ?tail drop dec> stack push ;
: load-binint2 ( -- ) 2 read le> stack push ;
: load-none ( -- ) null stack push ;
: load-persid ( -- ) unsupported-feature ;
: load-binpersid ( -- ) unsupported-feature ;
: load-reduce ( -- ) stack pop stack pop construct stack push ;
: load-string ( -- )
    readln {
        { [ "'" ?head ] [ "'" ?tail [ t ] [ invalid-string ] if ] }
        { [ "\"" ?head ] [ "\"" ?tail [ t ] [ invalid-string ] if ] }
        [ f ]
    } cond [ unescape-string stack push ] [ invalid-string ] if ;
: load-binstring ( -- ) 4 read le> read >string stack push ;
: load-short-binstring ( -- ) read1 read >string stack push ;
: load-unicode ( -- ) readln unescape-string stack push ;
: load-binunicode ( -- ) 4 read le> read utf8 decode stack push ;
: load-append ( -- ) stack pop stack last push ;
: load-build ( -- ) unsupported-feature ;
: load-global ( -- ) readln readln "." glue stack push ;
: load-dict ( -- ) pop-from-marker 2 group >hashtable stack push ;
: load-empty-dict ( -- ) H{ } clone stack push ;
: load-appends ( -- ) pop-from-marker stack last push-all ;
: load-get ( -- ) readln dec> get-memo ;
: load-binget ( -- ) read1 get-memo ;
: load-inst ( -- )
    readln readln "." glue [ pop-from-marker ] dip construct stack push ;
: load-long-binget ( -- ) 4 read le> get-memo ;
: load-list ( -- ) pop-from-marker >vector stack push ;
: load-empty-list ( -- ) V{ } clone stack push ;
: load-obj ( -- ) pop-from-marker unclip construct stack push ;
: load-put ( -- ) readln dec> put-memo ;
: load-binput ( -- ) read1 put-memo ;
: load-long-binput ( -- ) 4 read le> put-memo ;
: load-setitem ( -- ) stack pop stack pop stack last set-at ;
: load-tuple ( -- ) pop-from-marker stack push ;
: load-empty-tuple ( -- ) { } clone stack push ;
: load-setitems ( -- )
    pop-from-marker 2 group stack last swap assoc-union! drop ;
: load-binfloat ( -- ) 8 read be> bits>double stack push ;
: load-proto ( -- )
    read1 dup 0 5 between? [ drop ] [ unsupported-protocol ] if ;
: load-newobj ( -- ) load-reduce ; ! do the same as class(*args) instead of class.__new__(class,*args)
: load-ext1 ( -- ) unsupported-feature ;
: load-ext2 ( -- ) unsupported-feature ;
: load-ext4 ( -- ) unsupported-feature ;
: load-tuple1 ( -- ) stack pop 1array stack push ;
: load-tuple2 ( -- ) stack pop [ stack pop ] dip 2array stack push ;
: load-tuple3 ( -- ) stack pop [ stack pop [ stack pop ] dip ] dip 3array stack push ;
: load-true ( -- ) t stack push ;
: load-false ( -- ) f stack push ;
: load-long1 ( -- ) read1 read signed-le> stack push ;
: load-long4 ( -- ) 4 read le> read signed-le> stack push ;
: load-binbytes ( -- ) 4 read le> read >byte-array stack push ;
: load-short-binbytes ( -- ) read1 read >byte-array stack push ;
: load-binunicode8 ( -- ) 8 read le> read utf8 decode stack push ;
: load-short-binunicode ( -- ) read1 read utf8 decode stack push ;
: load-binbytes8 ( -- ) 8 read le> read >byte-array stack push ;
: load-empty-set ( -- ) HS{ } clone stack push ;
: load-additems ( -- ) pop-from-marker stack last adjoin-all ;
: load-frozenset ( -- ) pop-from-marker fast-set stack push ;
: load-memoize ( -- ) memo assoc-size put-memo ;
: load-frame ( -- ) 8 read drop ; ! skip the frame opcode and length
: load-newobj-ex ( -- )
    stack pop assoc-empty? t assert= ! kwargs not yet supported
    stack pop stack pop construct stack push ;
: load-stack-global ( -- ) stack pop stack pop swap construct stack push ;
: load-bytearray8 ( -- ) load-binbytes8 ; ! bytes vs bytearray python types?
: load-readonly-buffer ( -- ) ; ! readonly vs read/write buffers?
: load-next-buffer ( -- ) unsupported-feature ;

: unpickle-dispatch ( opcode -- value )
    +no-return+ swap {
        ! Protocol 0 and 1
        { CHAR: ( [ load-mark ] }
        { CHAR: . [ drop stack pop ] }
        { CHAR: 0 [ load-pop ] }
        { CHAR: 1 [ load-pop-mark ] }
        { CHAR: 2 [ load-dup ] }
        { CHAR: F [ load-float ] }
        { CHAR: G [ load-binfloat ] }
        { CHAR: I [ load-int ] }
        { CHAR: J [ load-binint ] }
        { CHAR: K [ load-binint1 ] }
        { CHAR: L [ load-long ] }
        { CHAR: M [ load-binint2 ] }
        { CHAR: N [ load-none ] }
        { CHAR: P [ load-persid ] }
        { CHAR: Q [ load-binpersid ] }
        { CHAR: R [ load-reduce ] }
        { CHAR: S [ load-string ] }
        { CHAR: T [ load-binstring ] }
        { CHAR: U [ load-short-binstring ] }
        { CHAR: V [ load-unicode ] }
        { CHAR: X [ load-binunicode ] }
        { CHAR: a [ load-append ] }
        { CHAR: b [ load-build ] }
        { CHAR: c [ load-global ] }
        { CHAR: d [ load-dict ] }
        { CHAR: e [ load-appends ] }
        { CHAR: g [ load-get ] }
        { CHAR: h [ load-binget ] }
        { CHAR: i [ load-inst ] }
        { CHAR: j [ load-long-binget ] }
        { CHAR: l [ load-list ] }
        { CHAR: ] [ load-empty-list ] }
        { CHAR: o [ load-obj ] }
        { CHAR: p [ load-put ] }
        { CHAR: q [ load-binput ] }
        { CHAR: r [ load-long-binput ] }
        { CHAR: s [ load-setitem ] }
        { CHAR: t [ load-tuple ] }
        { CHAR: u [ load-setitems ] }
        { CHAR: } [ load-empty-dict ] }
        { CHAR: ) [ load-empty-tuple ] }

        ! Protocol 2
        { 0x80 [ load-proto ] }
        { 0x81 [ load-newobj ] }
        { 0x82 [ load-ext1 ] }
        { 0x83 [ load-ext2 ] }
        { 0x84 [ load-ext4 ] }
        { 0x85 [ load-tuple1 ] }
        { 0x86 [ load-tuple2 ] }
        { 0x87 [ load-tuple3 ] }
        { 0x88 [ load-true ] }
        { 0x89 [ load-false ] }
        { 0x8a [ load-long1 ] }
        { 0x8b [ load-long4 ] }

        ! Protocol 3 (Python 3.x)
        { CHAR: B [ load-binbytes ] }
        { CHAR: C [ load-short-binbytes ] }

        ! Protocol 4 (Python 3.4-3.7)
        { 0x8c [ load-short-binunicode ] }
        { 0x8d [ load-binunicode8 ] }
        { 0x8e [ load-binbytes8 ] }
        { 0x8f [ load-empty-set ] }
        { 0x90 [ load-additems ] }
        { 0x91 [ load-frozenset ] }
        { 0x92 [ load-newobj-ex ] }
        { 0x93 [ load-stack-global ] }
        { 0x94 [ load-memoize ] }
        { 0x95 [ load-frame ] }

        ! Protocol 5 (Python 3.8+)
        { 0x96 [ load-bytearray8 ] }
        { 0x97 [ load-readonly-buffer ] }
        { 0x98 [ load-next-buffer ] }

        [ invalid-opcode ]
    } case ;

: unpickle ( -- obj )
    f [ drop read1 unpickle-dispatch dup +no-return+ = ] loop ;

PRIVATE>

: read-pickle ( -- obj )
    H{ } clone
        V{ } clone \ stack pick set-at
        H{ } clone \ memo pick set-at
    [ unpickle ] with-variables ;

GENERIC: pickle> ( string -- obj )

M: string pickle> [ read-pickle ] with-string-reader ;

M: byte-array pickle> binary [ read-pickle ] with-byte-reader ;

: file>pickle ( path -- obj )
    binary [ read-pickle ] with-file-reader ;
