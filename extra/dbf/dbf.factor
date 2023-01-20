! Copyright (C) 2018 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.endian assocs calendar
calendar.parser classes.struct combinators endian io
io.encodings.8-bit io.encodings.ascii io.encodings.binary
io.encodings.string io.files io.streams.byte-array kernel math
math.parser namespaces sequences ;

IN: dbf

SYMBOL: dbf-encoding

CONSTANT: dbf-encodings H{
    { 0x00 ascii }
    { 0x01 cp437 }
    { 0x02 cp850 }
    { 0x03 windows-1252 }
    { 0x04 mac-roman }
    { 0x08 cp865 }
    { 0x09 cp437 }
    { 0x0A cp850 }
    { 0x0B cp437 }
    { 0x0D cp437 }
    { 0x0E cp850 }
    { 0x0F cp437 }
    { 0x10 cp850 }
    { 0x11 cp437 }
    { 0x12 cp850 }
    { 0x13 "cp932" }
    { 0x14 cp850 }
    { 0x15 cp437 }
    { 0x16 cp850 }
    { 0x17 cp865 }
    { 0x18 cp437 }
    { 0x19 cp437 }
    { 0x1A cp850 }
    { 0x1B cp437 }
    { 0x1C cp863 }
    { 0x1D cp850 }
    { 0x1F cp852 }
    { 0x22 cp852 }
    { 0x23 cp852 }
    { 0x24 cp860 }
    { 0x25 cp850 }
    { 0x26 cp866 }
    { 0x37 cp850 }
    { 0x40 cp852 }
    { 0x4D "cp936" }
    { 0x4E "cp949" }
    { 0x4F "cp950" }
    { 0x50 "cp874" }
    { 0x57 windows-1252 }
    { 0x58 windows-1252 }
    { 0x59 windows-1252 }
    { 0x64 cp852 }
    { 0x65 cp866 }
    { 0x66 cp865 }
    { 0x67 cp861 }
    { 0x68 f }
    { 0x69 f }
    { 0x6a "cp737" }
    { 0x6b cp857 }
    { 0x6c cp863 }
    { 0x78 "cp950" }
    { 0x79 "cp949" }
    { 0x7a "cp936" }
    { 0x7b "cp932" }
    { 0x7c "cp874" }
    { 0x7d windows-1255 }
    { 0x7e windows-1256 }
    { 0x86 "cp737" }
    { 0x87 cp852 }
    { 0x88 cp857 }
    { 0x96 "mac-cyrillic" }
    { 0x97 "mac-latin2" }
    { 0x98 "mac-greek" }
    { 0xc8 windows-1250 }
    { 0xc9 windows-1251 }
    { 0xca windows-1254 }
    { 0xcb windows-1253 }
    { 0xcc windows-1250 }
}

CONSTANT: dbf-file-types H{
    { 0x02 "FoxBASE" }
    { 0x03 "FoxBASE+/dBase III plus, no memo" }
    { 0x04 "dBase IV, no memo" }
    { 0x05 "dBase V, no memo" }
    { 0x07 "Visual Objects 1.x" }
    { 0x30 "Visual FoxPro" }
    { 0x31 "Visual FoxPro, autoincrement enabled" }
    { 0x32 "Visual FoxPro with field type Varchar or Varbinary" }
    { 0x43 "dBase IV SQL table files, no memo" }
    { 0x63 "dBase IV SQL system files, no memo" }
    { 0x7b "dBase IV, with memo" }
    { 0x83 "FoxBASE+/dBase III PLUS, with memo" }
    { 0x87 "Visual Objects 1.x, with memo" }
    { 0x8B "dBase IV with memo" }
    { 0x8E "dBase IV with SQL table" }
    { 0xCB "dBase IV SQL table files, with memo" }
    { 0xE5 "HiPer-Six format with SMT memo file" }
    { 0xF5 "FoxPro 2.x (or earlier) with memo" }
    { 0xFB "FoxBASE" }
}

STRUCT: dbf-file-header
    { file-type uint8_t }
    { year uint8_t }
    { month uint8_t }
    { day uint8_t }
    { #records uint32_t }
    { header-length uint16_t }
    { record-length uint16_t }
    { reserved1 uint16_t }
    { incomplete-transaction uint8_t }
    { encryption-flag uint8_t }
    { free-record-thread uint32_t }
    { reserved2 uint32_t }
    { reserved3 uint32_t }
    { mdx-flag uint8_t }
    { language-driver uint8_t }
    { reserved4 uint16_t } ;

: read-file-header ( -- file-header )
    dbf-file-header read-struct ;

CONSTANT: dbf-field-flags H{
    { 0x01 "System Column (not visible to user)" }
    { 0x02 "Column can store null values" }
    { 0x04 "Binary column (for CHAR and MEMO only)" }
    { 0x06 "(0x02+0x04) When a field is NULL and binary (Integer, Currency, and Character/Memo fields)" }
    { 0x0C "Column is autoincrementing" }
}

STRUCT: dbf-field-header
    { name uint8_t[11] }
    { type uint8_t }
    { address uint32_t }
    { length uint8_t }
    { #decimals uint8_t }
    { reserved1 uint16_t }
    { workarea-id uint8_t }
    { reserved2 uint8_t }
    { reserved3 uint8_t }
    { set-fields-flag uint8_t }
    { reserved4 uint8_t[7] }
    { index-field-flag uint8_t } ;

: read-field-headers ( -- field-headers )
    [ read1 dup { CHAR: \r CHAR: \n f } member? not ] [
        dbf-field-header heap-size 1 - read swap prefix
        dbf-field-header memory>struct
    ] produce nip ;

: check-field-header ( field-header -- field-header )
    dup type>> {
        { CHAR: I [ dup length>> 4 assert= ] }
        { CHAR: L [ dup length>> 1 assert= ] }
        { CHAR: O [ dup length>> 8 assert= ] }
        { CHAR: Y [ dup length>> 8 assert= ] }
        { CHAR: D [ dup length>> 8 assert= ] }
        { CHAR: T [ dup length>> 8 assert= ] }
        { CHAR: M [ dup length>> 10 assert= ] }
        [ drop ]
    } case ;

: check-record-length ( file-header field-headers -- )
    [ record-length>> ] [ [ length>> ] map-sum ] bi* assert= ;

DEFER: parse-field

TUPLE: record deleted? values ;

: read-records ( field-headers -- records )
    [ read1 dup { 0x1a f } member? not ]
    [
        CHAR: * = over [
            [ length>> read ]
            [ type>> parse-field ] bi
        ] map record boa
    ] produce 2nip ;

TUPLE: dbf file-header field-headers records ;

: load-dbf ( path -- dbf )
    binary [
        read-file-header
        read-field-headers
        over header-length>> seek-absolute seek-input
        over language-driver>> dbf-encodings at dbf-encoding [
            dup read-records dbf boa
        ] with-variable
    ] with-file-reader ;

: seek-record ( n file-header -- )
    [ record-length>> * ] [ header-length>> ] bi +
    seek-absolute seek-input ;

: parse-string ( byte-array -- string )
    [ " \0" member? ] trim-tail dbf-encoding get decode ;

: parse-date ( byte-array -- date/f )
    dup [ " \0" member? ] all? [ drop f ] [
        binary [ read-ymd <date-gmt> ] with-byte-reader
    ] if ;

: parse-float ( byte-array -- n )
    [ "\r\n\t *" member? ] trim string>number ;

: parse-int ( byte-array -- n )
    dup length 4 assert= le> ;

: parse-short ( byte-array -- n )
    dup length 2 assert= le> ;

SYMBOL: unknown

ERROR: illegal-logical value ;

: parse-logical ( byte-array -- n )
    first {
        { [ dup "TtYy" member? ] [ drop t ] }
        { [ dup "FfNn" member? ] [ drop f ] }
        { [ dup "? " member? ] [ drop unknown ] }
        [ illegal-logical ]
    } cond ;

: parse-numeric ( byte-array -- n )
    [ "\r\n\t *" member? ] trim
    H{ { CHAR: , CHAR: . } } substitute string>number ;

: parse-double ( byte-array -- n )
    dup length 8 assert= le> bits>double ;

: parse-currency ( byte-array -- n )
    dup length 8 assert= le> 10000 / ;

: parse-timestamp ( byte-array -- timestamp )
    [ -4713 1 1 <date> ] dip 4 cut [ le> ] bi@
    [ days time+ ] [ milliseconds time+ ] bi* ;

ERROR: unsupported-field-type type ;

: parse-field ( byte-array type -- data )
    {
        { CHAR: \0 [ ] }
        { CHAR: 2  [ parse-short ] }
        { CHAR: 4  [ parse-int ] }
        { CHAR: 8  [ parse-double ] }
        { CHAR: C  [ parse-string ] }
        { CHAR: D  [ parse-date ] }
        { CHAR: F  [ parse-float ] }
        { CHAR: I  [ parse-int ] }
        { CHAR: L  [ parse-logical ] }
        { CHAR: N  [ parse-numeric ] }
        { CHAR: O  [ parse-double ] }
        { CHAR: V  [ parse-string ] }
        { CHAR: Y  [ parse-currency ] }
        { CHAR: @  [ parse-timestamp ] }
        ! { CHAR: +  [ parse-autoincrement ] }
        ! { CHAR: M  [ parse-memo ] }
        ! { CHAR: T  [ parse-datetime ] }
        ! { CHAR: B  [ parse-double? ] } ! (only on dbversion in [0x30, 0x31, 0x32])
        ! { CHAR: G  [ parse-general ] }
        ! { CHAR: P  [ parse-picture ] }
        ! { CHAR: Q  [ parse-varbinary ] }
        [ unsupported-field-type ]
    } case ;

: dbase3-memo ( n path -- data )
    binary [
        512 * seek-absolute seek-input
        B{ } [
            512 read
            dup [ B{ 0 0x1a } member? ] find drop
            [ head f ] [ t ] if* [ append ] dip
        ] loop
    ] with-file-reader ;

LE-STRUCT: db4-memo-header
    { reserved uint } ! B{ 0xff 0xff 0x08 0x08 }
    { length uint } ;

: dbase4-memo ( n path -- data )
    binary [
        512 * seek-absolute seek-input
        db4-memo-header read-struct length>> read
    ] with-file-reader ;

BE-STRUCT: vfp-file-header
    { nextblock uint }
    { reserved1 ushort }
    { blocksize ushort }
    { reserved2 uchar[504] } ;

BE-STRUCT: vfp-memo-header
    { type uint }
    { length uint } ;

CONSTANT: vfp-memo-types H{
    { 0x0 "picture memo" }
    { 0x1 "text memo" }
    { 0x2 "object memo" }
}

: vfp-memo ( n path -- data )
    binary [
        vfp-file-header read-struct blocksize>> *
        seek-absolute seek-input
        vfp-memo-header read-struct length>> read
    ] with-file-reader ;
