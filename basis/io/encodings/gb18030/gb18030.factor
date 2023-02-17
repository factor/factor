! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs biassocs byte-arrays
combinators combinators.short-circuit interval-maps io
io.encodings io.encodings.iana io.files kernel math
math.order math.parser namespaces sequences splitting xml
xml.data ;
FROM: io.encodings.ascii => ascii ;
IN: io.encodings.gb18030

SINGLETON: gb18030

gb18030 "GB18030" register-encoding

<PRIVATE

! GB to mean GB18030 is a terrible abuse of notation

! Resource file from:
! https://source.icu-project.org/repos/icu/data/trunk/charset/data/xml/gb-18030-2000.xml

! Algorithms from:
! https://www-128.ibm.com/developerworks/library/u-china.html

: linear ( bytes -- num )
    ! This hard-codes bMin and bMax
    reverse first4
    10 * + 126 * + 10 * + ; foldable

TUPLE: range ufirst ulast bfirst blast ;

: b>byte-array ( string -- byte-array )
    split-words [ hex> ] B{ } map-as ;

: add-range ( contained ranges -- )
    [
        {
            [ "uFirst" attr hex> ]
            [ "uLast" attr hex> ]
            [ "bFirst" attr b>byte-array linear ]
            [ "bLast" attr b>byte-array linear ]
        } cleave range boa
    ] dip push ;

: add-mapping ( contained mapping -- )
    [
        [ "b" attr b>byte-array ]
        [ "u" attr hex> ] bi
    ] dip set-at ;

: xml>gb-data ( stream -- mapping ranges )
    [let
        H{ } clone :> mapping V{ } clone :> ranges
        [
            dup contained? [
                dup name>> main>> {
                    { "range" [ ranges add-range ] }
                    { "a" [ mapping add-mapping ] }
                    [ 2drop ]
                } case
            ] [ drop ] if
        ] each-element mapping ranges
    ] ;

: unlinear ( num -- bytes )
    B{ 0x81 0x30 0x81 0x30 } linear -
    10 /mod 0x30 + swap
    126 /mod 0x81 + swap
    10 /mod 0x30 + swap
    0x81 +
    4byte-array reverse! ;

: >interval-map-by ( start-quot end-quot value-quot seq -- interval-map )
    '[ _ [ @ 2array ] _ tri ] { } map>assoc <interval-map> ; inline

: ranges-u>gb ( ranges -- interval-map )
    [ ufirst>> ] [ ulast>> ] [ ] >interval-map-by ;

: ranges-gb>u ( ranges -- interval-map )
    [ bfirst>> ] [ blast>> ] [ ] >interval-map-by ;

SYMBOL: gb>u
SYMBOL: u>gb
SYMBOL: mapping

"vocab:io/encodings/gb18030/gb-18030-2000.xml"
ascii <file-reader> xml>gb-data
[ ranges-u>gb u>gb set-global ] [ ranges-gb>u gb>u set-global ] bi
>biassoc mapping set-global

: lookup-range ( char -- byte-array )
    dup u>gb get-global interval-at [
        [ ufirst>> - ] [ bfirst>> ] bi + unlinear
    ] [ encode-error ] if* ;

M: gb18030 encode-char
    drop [
        [ mapping get-global at ] [ lookup-range ] ?unless
    ] dip stream-write ;

: second-byte? ( ch -- ? ) ! of a double-byte character
    { [ 0x40 0x7E between? ] [ 0x80 0xfe between? ] } 1||  ;

: quad-1/3? ( ch -- ? ) 0x81 0xfe between? ;

: quad-2/4? ( ch -- ? ) 0x30 0x39 between? ;

: last-bytes? ( byte-array -- ? )
    { [ length 2 = ] [ first quad-1/3? ] [ second quad-2/4? ] } 1&& ;

: decode-quad ( byte-array -- char )
    [ mapping get-global value-at ] [
        linear dup gb>u get-global interval-at [
            [ bfirst>> - ] [ ufirst>> ] bi +
        ] [ drop replacement-char ] if*
    ] ?unless ;

: four-byte ( stream byte1 byte2 -- char )
    rot 2 swap stream-read dup last-bytes?
    [ first2 4byte-array decode-quad ]
    [ 3drop replacement-char ] if ;

: two-byte ( stream byte -- char )
    over stream-read1 {
        { [ dup not ] [ 3drop replacement-char ] }
        { [ dup second-byte? ] [ 2byte-array mapping get-global value-at nip ] }
        { [ dup quad-2/4? ] [ four-byte ] }
        [ 3drop replacement-char ]
    } cond ;

M: gb18030 decode-char
    drop dup stream-read1 {
        { [ dup not ] [ 2drop f ] }
        { [ dup ascii? ] [ nip 1byte-array mapping get-global value-at ] }
        { [ dup quad-1/3? ] [ two-byte ] }
        [ 2drop replacement-char ]
    } cond ;

PRIVATE>
