! Copyright (C) 2007 Elie CHAFTARI
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs byte-arrays combinators endian io
io.streams.string kernel make math math.parser namespaces pack
sequences strings ;

IN: asn1

<PRIVATE

: (>128-ber) ( n -- )
    dup 0 > [
        [ 0x7f bitand 0x80 bitor , ] keep -7 shift
        (>128-ber)
    ] [
        drop
    ] if ;

PRIVATE>

: >128-ber ( n -- str )
    [
        [ 0x7f bitand , ] keep -7 shift
        (>128-ber)
    ] { } make reverse ;

: tag-classes ( -- seq )
    { "universal" "application" "context_specific" "private" } ;

: builtin-syntax ( -- hashtable )
    H{
        { "universal"
            H{
                { "primitive"
                    H{
                        { 1 "boolean" }
                        { 2 "integer" }
                        { 4 "string" }
                        { 5 "null" }
                        { 6 "oid" }
                        { 10 "integer" }
                        { 13 "string" }   ! relative OID
                     }
                }
                { "constructed"
                    H{
                        { 16 "array" }
                        { 17 "array" }
                    }
                }
             }
        }
        { "context_specific"
            H{
                { "primitive"
                    H{
                        { 10 "integer" }
                    }
                }
            }
        }
    } ;

SYMBOL: elements

TUPLE: element syntax id tag tagclass encoding contentlength newobj objtype ;


: get-id ( -- id )
    elements get id>> ;

ERROR: unsupported-tag-encoding id ;

: (set-tag) ( -- )
    elements get id>> 31 bitand
    dup elements get tag<<
    31 < [
        get-id unsupported-tag-encoding
    ] unless ;

: set-tagclass ( -- )
    get-id -6 shift tag-classes nth
    elements get tagclass<< ;

: set-encoding ( -- )
    get-id 0x20 bitand
    zero? "primitive" "constructed" ?
    elements get encoding<< ;

: set-content-length ( -- )
    read1
    dup 127 <= [
        127 bitand read be>
    ] unless elements get contentlength<< ;

: set-newobj ( -- )
    elements get contentlength>> read
    elements get newobj<< ;

: set-objtype ( syntax -- )
    builtin-syntax 2array [
        elements get tagclass>> of
        elements get encoding>> of
        elements get tag>>
        of [
            elements get objtype<<
        ] when*
    ] each ;

DEFER: read-ber

SYMBOL: end

: (read-array) ( -- )
    elements get id>> [
        elements get syntax>> read-ber
        dup end = [ drop ] [ , (read-array) ] if
    ] when ;

: read-array ( -- array ) [ (read-array) ] { } make ;

: set-case ( -- object )
    elements get newobj>>
    elements get objtype>> {
        { "boolean" [ "\0" = not ] }
        { "string" [ "" or ] }
        { "integer" [ be> ] }
        { "array" [ "" or [ read-array ] with-string-reader ] }
    } case ;

: set-id ( -- boolean )
    read1 dup elements get id<< ;

: read-ber ( syntax -- object )
    element new
        swap >>syntax
    elements set
    set-id [
        (set-tag)
        set-tagclass
        set-encoding
        set-content-length
        set-newobj
        elements get syntax>> set-objtype
        set-case
    ] [ end ] if ;

! =========================================================
! Fixnum
! =========================================================

GENERIC: >ber ( obj -- byte-array )
M: fixnum >ber ( n -- byte-array )
    >128-ber dup length 2 swap 2array
    "cc" pack-native B{ } prepend-as ;

: >ber-enumerated ( n -- byte-array )
    >128-ber dup length 10 swap 2array
    "CC" pack-native B{ } prepend-as ;

: >ber-length-encoding ( n -- byte-array )
    dup 127 <= [
        1array "C" pack-be
    ] [
        1array "I" pack-be 0 swap remove dup length
        0x80 + 1array "C" pack-be B{ } prepend-as
    ] if ;

! =========================================================
! Bignum
! =========================================================

M: bignum >ber ( n -- byte-array )
    >128-ber dup length
    dup 126 > [
        "range error in bignum" throw
    ] [
        2 swap 2array "CC" pack-native B{ } prepend-as
    ] if ;

! =========================================================
! String
! =========================================================

! Universal octet-string has tag number 4, we should however
! still be able to assign an arbitrary code number.
! >ber words should be called within a with-ber.
SYMBOL: tagnum

TUPLE: tag value ;

: <tag> ( -- <tag> ) 4 tag boa ;

: with-ber ( quot -- )
    [ <tag> tagnum ] dip with-variable ; inline

: set-tag ( value -- )
    tagnum get value<< ;

M: string >ber ( str -- byte-array )
    tagnum get value>> 1array "C" pack-native swap dup
    length >ber-length-encoding swapd append swap
    >byte-array append ;

: >ber-application-string ( n str -- byte-array )
    [ 0x40 + set-tag ] dip >ber ;

: >ber-contextspecific-string ( n str -- byte-array )
    [ 0x80 + set-tag ] dip >ber ;

! =========================================================
! Array
! =========================================================

: >ber-seq-internal ( array code -- byte-array )
    1array "C" pack-native swap dup length >ber-length-encoding
    swapd append swap [ number>string ] map { } concat-as append ;

M: array >ber ( array -- byte-array )
    0x30 >ber-seq-internal ;

: >ber-set ( array -- byte-array )
    0x31 >ber-seq-internal ;

: >ber-sequence ( array -- byte-array )
    0x30 >ber-seq-internal ;

: >ber-appsequence ( array -- byte-array )
    0x60 >ber-seq-internal ;

: >ber-contextspecific-array ( array -- byte-array )
    0xA0 >ber-seq-internal ;
