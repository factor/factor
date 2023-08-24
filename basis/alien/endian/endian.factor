! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.data arrays
classes.struct.private combinators compiler.units endian
generalizations kernel math math.bitwise namespaces sequences
slots words ;
QUALIFIED-WITH: alien.c-types c
IN: alien.endian

ERROR: invalid-signed-conversion n ;

: convert-signed-quot ( n -- quot )
    {
        { 1 [ [ char <ref> char deref ] ] }
        { 2 [ [ c:short <ref> c:short deref ] ] }
        { 4 [ [ int <ref> int deref ] ] }
        { 8 [ [ longlong <ref> longlong deref ] ] }
        [ invalid-signed-conversion ]
    } case ; inline

MACRO: byte-reverse ( n signed? -- quot )
    [
        drop
        [
            dup <iota> [
                [ 1 + - -8 * ] [ nip 8 * ] 2bi
                '[ _ shift 0xff bitand _ shift ]
            ] with map
        ] [ 1 - [ bitor ] n*quot ] bi
    ] [
        [ convert-signed-quot ] [ drop [ ] ] if
    ] 2bi
    '[ _ cleave @ @ ] ;

SYMBOLS: le8 be8 ule8 ube8
ule16 ule32 ule64 ube16 ube32 ube64
le16 le32 le64 be16 be32 be64 ;

: endian-c-type? ( symbol -- ? )
    {
        le8 be8 ule8 ube8 ule16 ule32 ule64
        ube16 ube32 ube64 le16 le32 le64 be16 be32 be64
    } member? ;

ERROR: unknown-endian-c-type symbol ;

: endian-c-type>c-type-symbol ( symbol -- symbol' )
    {
        { [ dup { ule16 ube16 } member? ] [ drop ushort ] }
        { [ dup { le16 be16 } member? ] [ drop c:short ] }
        { [ dup { ule32 ube32 } member? ] [ drop uint ] }
        { [ dup { le32 be32 } member? ] [ drop int ] }
        { [ dup { ule64 ube64 } member? ] [ drop ulonglong ] }
        { [ dup { le64 be64 } member? ] [ drop longlong ] }
        [ unknown-endian-c-type ]
    } cond ;

: change-c-type-accessors ( n ? c-type -- c-type' )
    endian-c-type>c-type-symbol "c-type" word-prop clone
    -rot over 8 = [
        [
            nip
            [
                [
                    [ alien-unsigned-4 4 f byte-reverse 32 shift ]
                    [ 4 + alien-unsigned-4 4 f byte-reverse ] 2bi bitor
                ]
            ] dip [ [ 64 >signed ] compose ] when
            >>getter drop
        ]
        [ '[ [ [ _ _ byte-reverse ] 2dip ] prepose ] change-setter ] 3bi
    ] [
        [ '[ [ _ _ byte-reverse ] compose ] change-getter drop ]
        [ '[ [ [ _ _ byte-reverse ] 2dip ] prepose ] change-setter ] 3bi
    ] if ;

: typedef-endian ( n ? c-type endian -- )
    native-endianness get = [
        2nip [ endian-c-type>c-type-symbol ] keep typedef
    ] [
        [ change-c-type-accessors ] keep typedef
    ] if ;

: typedef-le ( n ? c-type -- ) little-endian typedef-endian ;
: typedef-be ( n ? c-type -- ) big-endian typedef-endian ;

[
    \ char \ le8 typedef
    \ char \ be8 typedef
    \ uchar \ ule8 typedef
    \ uchar \ ube8 typedef
    2 f \ ule16 typedef-le
    2 f \ ube16 typedef-be
    2 t \ le16 typedef-le
    2 t \ be16 typedef-be
    4 f \ ule32 typedef-le
    4 f \ ube32 typedef-be
    4 t \ le32 typedef-le
    4 t \ be32 typedef-be
    8 f \ ule64 typedef-le
    8 f \ ube64 typedef-be
    8 t \ le64 typedef-le
    8 t \ be64 typedef-be
] with-compilation-unit

! pair: { le be }
: pair>c-type ( pair -- c-type )
    [ native-endianness get big-endian = ] dip first2 ? ;

! endian is desired endian type. if we match endianness, return the c type
! otherwise return the opposite of our endianness
: endian-slot ( endian c-type pair -- endian-slot )
    [ native-endianness get = ] 2dip rot [ drop ] [ nip pair>c-type ] if ;

ERROR: unsupported-endian-type endian slot ;

: slot>endian-slot ( endian slot -- endian-slot )
    dup array? [
        first2 [ slot>endian-slot ] dip 2array
    ] [
        {
            { [ dup bool = ] [ 2drop bool ] }
            { [ dup char = ] [ 2drop char ] }
            { [ dup uchar = ] [ 2drop uchar ] }
            { [ dup c:short = ] [ { le16 be16 } endian-slot ] }
            { [ dup ushort = ] [ { ule16 ube16 } endian-slot ] }
            { [ dup int = ] [ { le32 be32 } endian-slot ] }
            { [ dup uint = ] [ { ule32 ube32 } endian-slot ] }
            { [ dup longlong = ] [ { le64 be64 } endian-slot ] }
            { [ dup ulonglong = ] [ { ule64 ube64 } endian-slot ] }
            { [ dup endian-c-type? ] [ nip ] }
            { [ dup pointer? ] [ nip ] }
            [ unsupported-endian-type ]
        } cond
    ] if ;

: set-endian-slots ( endian slots -- slot-specs )
    [ [ slot>endian-slot ] change-type ] with map ;

: define-endian-struct-class ( class slots endian -- )
    swap make-slots set-endian-slots
    [ compute-struct-offsets ] [ struct-alignment ]
    (define-struct-class) ;

: define-endian-packed-struct-class ( class slots endian -- )
    swap make-packed-slots set-endian-slots
    [ compute-struct-offsets ] [ drop 1 ]
    (define-struct-class) ;

SYNTAX: LE-STRUCT:
    parse-struct-definition
    little-endian define-endian-struct-class ;

SYNTAX: BE-STRUCT:
    parse-struct-definition
    big-endian define-endian-struct-class ;

SYNTAX: LE-PACKED-STRUCT:
    parse-struct-definition
    little-endian define-endian-packed-struct-class ;

SYNTAX: BE-PACKED-STRUCT:
    parse-struct-definition
    big-endian define-endian-packed-struct-class ;
