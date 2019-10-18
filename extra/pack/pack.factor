USING: alien alien.c-types arrays assocs byte-arrays inference
inference.transforms io io.binary io.streams.string kernel
math math.parser namespaces parser prettyprint
quotations sequences strings threads vectors
words macros ;
IN: pack

SYMBOL: big-endian

: big-endian? ( -- ? )
    1 <int> *char zero? ;

: clear-bit ( m n -- o )
    2^ bitnot bitand ;

: >endian ( obj n -- str )
    big-endian get [ >be ] [ >le ] if ; inline

: endian> ( obj -- str )
    big-endian get [ be> ] [ le> ] if ; inline

GENERIC: b, ( n obj -- )
M: integer b, ( m n -- ) >endian % ;

! for doing native, platform-dependent sized values
M: string b, ( n string -- ) heap-size b, ;
: read-native ( string -- n ) heap-size read endian> ;

! Portable
: s8, ( n -- ) 1 b, ;
: u8, ( n -- ) 1 b, ;
: s16, ( n -- ) 2 b, ;
: u16, ( n -- ) 2 b, ;
: s24, ( n -- ) 3 b, ;
: u24, ( n -- ) 3 b, ;
: s32, ( n -- ) 4 b, ;
: u32, ( n -- ) 4 b, ;
: s64, ( n -- ) 8 b, ;
: u64, ( n -- ) 8 b, ;
: s128, ( n -- ) 16 b, ;
: u128, ( n -- ) 16 b, ;
: float, ( n -- ) float>bits 4 b, ;
: double, ( n -- ) double>bits 8 b, ;
: c-string, ( str -- ) % 0 u8, ;

: (>128-ber) ( n -- )
    dup 0 > [
        [ HEX: 7f bitand HEX: 80 bitor , ] keep -7 shift
        (>128-ber)
    ] [
        drop
    ] if ;

: >128-ber ( n -- str )
    [
        [ HEX: 7f bitand , ] keep -7 shift
        (>128-ber)
    ] { } make reverse ;

: >signed ( x n -- y )
    2dup neg 1+ shift 1 = [ 2^ - ] [ drop ] if ;

: read-signed ( n -- str )
    dup read endian> swap 8 * >signed ;

: read-unsigned ( n -- m ) read endian> ;

: read-s8 ( -- n ) 1 read-signed ;
: read-u8 ( -- n ) 1 read-unsigned ;
: read-s16 ( -- n ) 2 read-signed ;
: read-u16 ( -- n ) 2 read-unsigned ;
: read-s24 ( -- n ) 3 read-signed ;
: read-u24 ( -- n ) 3 read-unsigned ;
: read-s32 ( -- n ) 4 read-signed ;
: read-u32 ( -- n ) 4 read-unsigned ;
: read-s64 ( -- n ) 8 read-signed ;
: read-u64 ( -- n ) 8 read-signed ;
: read-s128 ( -- n ) 16 read-signed ;
: read-u128 ( -- n ) 16 read-unsigned ;

: read-float ( -- n )
    4 read endian> bits>float ;

: read-double ( -- n )
    8 read endian> bits>double ;

: read-c-string ( -- str/f )
    "\0" read-until [ drop f ] unless ;

: read-c-string* ( n -- str/f )
    read [ 0 = ] right-trim dup empty? [ drop f ] when ;

: (read-128-ber) ( n -- n )
    1 read first
    [ >r 7 shift r> 7 clear-bit bitor ] keep
    7 bit? [ (read-128-ber) ] when ;
    
: read-128-ber ( -- n )
    0 (read-128-ber) ;

: pack-table ( -- hash )
    H{
        { CHAR: c s8, }
        { CHAR: C u8, }
        { CHAR: s s16, }
        { CHAR: S u16, }
        { CHAR: t s24, }
        { CHAR: T u24, }
        { CHAR: i s32, }
        { CHAR: I u32, }
        { CHAR: q s64, }
        { CHAR: Q u64, }
        { CHAR: f float, }
        { CHAR: F float, }
        { CHAR: d double, }
        { CHAR: D double, }
    } ;

: unpack-table ( -- hash )
    H{
        { CHAR: c read-s8 }
        { CHAR: C read-u8 }
        { CHAR: s read-s16 }
        { CHAR: S read-u16 }
        { CHAR: t read-s24 }
        { CHAR: T read-u24 }
        { CHAR: i read-s32 }
        { CHAR: I read-u32 }
        { CHAR: q read-s64 }
        { CHAR: Q read-u64 }
        { CHAR: f read-float }
        { CHAR: F read-float }
        { CHAR: d read-double }
        { CHAR: D read-double }
    } ;

MACRO: (pack) ( seq str -- quot )
    [
        [
            [
                swap , pack-table at ,
            ] 2each
        ] [ ] make 1quotation %
       [ B{ } make ] %
    ] [ ] make ;

: pack-native ( seq str -- seq )
    [
        big-endian? big-endian set (pack)
    ] with-scope ;

: pack-be ( seq str -- seq )
    [ big-endian on (pack) ] with-scope ;

: pack-le ( seq str -- seq )
    [ big-endian off (pack) ] with-scope ;


MACRO: (unpack) ( str -- quot )
    [
        \ <string-reader> ,
        [
            [ unpack-table at , \ , , ] each
        ] [ ] make
        1quotation [ { } make ] append
        1quotation %
        \ with-stream ,
    ] [ ] make ;

: unpack-native ( seq str -- seq )
    [
        big-endian? big-endian set (unpack)
    ] with-scope ;

: unpack-be ( seq str -- seq )
    [ big-endian on (unpack) ] with-scope ;

: unpack-le ( seq str -- seq )
    [ big-endian off (unpack) ] with-scope ;
