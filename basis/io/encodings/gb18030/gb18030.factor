! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml xml.data kernel io io.encodings interval-maps splitting fry
math.parser sequences combinators assocs locals accessors math arrays
byte-arrays values ascii io.files biassocs math.order
combinators.short-circuit io.binary io.encodings.iana ;
FROM: io.encodings.ascii => ascii ;
IN: io.encodings.gb18030

SINGLETON: gb18030

gb18030 "GB18030" register-encoding

<PRIVATE

! GB to mean GB18030 is a terrible abuse of notation

! Resource file from:
! http://source.icu-project.org/repos/icu/data/trunk/charset/data/xml/gb-18030-2000.xml

! Algorithms from:
! http://www-128.ibm.com/developerworks/library/u-china.html

: linear ( bytes -- num )
    ! This hard-codes bMin and bMax
    reverse first4
    10 * + 126 * + 10 * + ; foldable

TUPLE: range ufirst ulast bfirst blast ;

: b>byte-array ( string -- byte-array )
    " " split [ hex> ] B{ } map-as ;

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
    B{ HEX: 81 HEX: 30 HEX: 81 HEX: 30 } linear -
    10 /mod HEX: 30 + swap
    126 /mod HEX: 81 + swap
    10 /mod HEX: 30 + swap
    HEX: 81 +
    4byte-array dup reverse-here ;

: >interval-map-by ( start-quot end-quot value-quot seq -- interval-map )
    '[ _ [ @ 2array ] _ tri ] { } map>assoc <interval-map> ; inline

: ranges-u>gb ( ranges -- interval-map )
    [ ufirst>> ] [ ulast>> ] [ ] >interval-map-by ;

: ranges-gb>u ( ranges -- interval-map )
    [ bfirst>> ] [ blast>> ] [ ] >interval-map-by ;

VALUE: gb>u
VALUE: u>gb
VALUE: mapping

"vocab:io/encodings/gb18030/gb-18030-2000.xml"
ascii <file-reader> xml>gb-data
[ ranges-u>gb to: u>gb ] [ ranges-gb>u to: gb>u ] bi
>biassoc to: mapping

: lookup-range ( char -- byte-array )
    dup u>gb interval-at [
        [ ufirst>> - ] [ bfirst>> ] bi + unlinear
    ] [ encode-error ] if* ;

M: gb18030 encode-char ( char stream encoding -- )
    drop [
        dup mapping at
        [ ] [ lookup-range ] ?if
    ] dip stream-write ;

: second-byte? ( ch -- ? ) ! of a double-byte character
    { [ HEX: 40 HEX: 7E between? ] [ HEX: 80 HEX: fe between? ] } 1||  ;

: quad-1/3? ( ch -- ? ) HEX: 81 HEX: fe between? ;

: quad-2/4? ( ch -- ? ) HEX: 30 HEX: 39 between? ;

: last-bytes? ( byte-array -- ? )
    { [ length 2 = ] [ first quad-1/3? ] [ second quad-2/4? ] } 1&& ;

: decode-quad ( byte-array -- char )
    dup mapping value-at [ ] [
        linear dup gb>u interval-at [
            [ bfirst>> - ] [ ufirst>> ] bi +
        ] [ drop replacement-char ] if*
    ] ?if ;

: four-byte ( stream byte1 byte2 -- char )
    rot 2 swap stream-read dup last-bytes?
    [ first2 4byte-array decode-quad ]
    [ 3drop replacement-char ] if ;

: two-byte ( stream byte -- char )
    over stream-read1 {
        { [ dup not ] [ 3drop replacement-char ] }
        { [ dup second-byte? ] [ 2byte-array mapping value-at nip ] }
        { [ dup quad-2/4? ] [ four-byte ] }
        [ 3drop replacement-char ]
    } cond ;

M: gb18030 decode-char ( stream encoding -- char )
    drop dup stream-read1 {
        { [ dup not ] [ 2drop f ] }
        { [ dup ascii? ] [ nip 1byte-array mapping value-at ] }
        { [ dup quad-1/3? ] [ two-byte ] }
        [ 2drop replacement-char ]
    } cond ;
