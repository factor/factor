! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types combinators
compiler.units endian fry generalizations kernel macros math
namespaces sequences words alien.data ;
QUALIFIED-WITH: alien.c-types ac
IN: alien.endian

ERROR: invalid-signed-conversion n ;

: convert-signed-quot ( n -- quot )
    {
        { 1 [ [ char <ref> char deref ] ] }
        { 2 [ [ ac:short <ref> ac:short deref ] ] }
        { 4 [ [ int <ref> int deref ] ] }
        { 8 [ [ longlong <ref> longlong deref ] ] }
        [ invalid-signed-conversion ]
    } case ; inline

MACRO: byte-reverse ( n signed? -- quot )
    [
        drop
        [
            dup iota [
                [ 1 + - -8 * ] [ nip 8 * ] 2bi
                '[ _ shift HEX: ff bitand _ shift ]
            ] with map
        ] [ 1 - [ bitor ] n*quot ] bi
    ] [
        [ convert-signed-quot ] [ drop [ ] ] if
    ] 2bi
    '[ _ cleave @ @ ] ;

SYMBOLS: le8 be8 ule8 ube8
ule16 ule32 ule64 ube16 ube32 ube64
le16 le32 le64 be16 be32 be64 ;

ERROR: unknown-endian-c-type symbol ;

: endian-c-type>c-type-symbol ( symbol -- symbol' )
    {
        { [ dup { ule16 ube16 } member? ] [ drop ushort ] }
        { [ dup { le16 be16 } member? ] [ drop ac:short ] }
        { [ dup { ule32 ube32 } member? ] [ drop uint ] }
        { [ dup { le32 be32 } member? ] [ drop int ] }
        { [ dup { ule64 ube64 } member? ] [ drop ulonglong ] }
        { [ dup { le64 be64 } member? ] [ drop longlong ] }
        [ unknown-endian-c-type ]
    } cond ;

: change-c-type-accessors ( n ? c-type -- c-type' )
    endian-c-type>c-type-symbol "c-type" word-prop clone
    -rot
    [ '[ [ _ _ byte-reverse ] compose ] change-getter drop ]
    [ '[ [ [ _ _ byte-reverse ] 2dip ] prepose ] change-setter ] 3bi ;

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
