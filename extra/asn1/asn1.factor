! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.

USING: arrays asn1.ldap assocs byte-arrays combinators
continuations io io.binary io.streams.string kernel math
math.parser namespaces pack strings sequences ;

IN: asn1

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

: <element> element construct-empty ;

: set-id ( -- boolean )
    read1 dup elements get set-element-id ;

: get-id ( -- id )
    elements get element-id ;

: (set-tag) ( -- )
    elements get element-id 31 bitand
    dup elements get set-element-tag
    31 < [
        [ "unsupported tag encoding: #{" % 
          get-id # "}" %
        ] "" make throw
    ] unless ;

: set-tagclass ( -- )
    get-id -6 shift tag-classes nth
    elements get set-element-tagclass ;

: set-encoding ( -- )
    get-id HEX: 20 bitand
    zero? "primitive" "constructed" ?
    elements get set-element-encoding ;

: set-content-length ( -- )
    read1
    dup 127 <= [ 
        127 bitand read be>
    ] unless elements get set-element-contentlength ;

: set-newobj ( -- )
    elements get element-contentlength read
    elements get set-element-newobj ;

: set-objtype ( syntax -- )
    builtin-syntax 2array [
        elements get element-tagclass swap at
        elements get element-encoding swap at
        elements get element-tag
        swap at [ 
            elements get set-element-objtype
        ] when*
    ] each ;

DEFER: read-ber

SYMBOL: end

: (read-array) ( stream -- )
    elements get element-id [
        elements get element-syntax read-ber
        dup end = [ drop ] [ , (read-array) ] if
    ] when ;

: read-array ( -- array ) [ (read-array) ] { } make ;

: set-case ( -- )
    elements get element-newobj
    elements get element-objtype {
        { "boolean" [ "\0" = not ] }
        { "string" [ "" or ] }
        { "integer" [ be> ] }
        { "array" [ "" or [ read-array ] string-in ] }
    } case ;

: read-ber ( syntax -- object )
    <element> elements set
    elements get set-element-syntax
    set-id [
        (set-tag)
        set-tagclass
        set-encoding
        set-content-length
        set-newobj
        elements get element-syntax set-objtype
        set-case
    ] [ end ] if ;

! =========================================================
! Fixnum
! =========================================================

GENERIC: >ber ( obj -- byte-array )
M: fixnum >ber ( n -- byte-array )
    >128-ber dup length 2 swap 2array
    "cc" pack-native swap append ;

: >ber-enumerated ( n -- byte-array )
    >128-ber >byte-array dup length 10 swap 2array
    "CC" pack-native swap append ;

: >ber-length-encoding ( n -- byte-array )
    dup 127 <= [
        1array "C" pack-be
    ] [
        1array "I" pack-be 0 swap remove dup length
        HEX: 80 + 1array "C" pack-be swap append
    ] if ;

! =========================================================
! Bignum
! =========================================================

M: bignum >ber ( n -- byte-array )
    >128-ber >byte-array dup length
    dup 126 > [
        "range error in bignum" throw
    ] [
        2 swap 2array "CC" pack-native swap append
    ] if ;

! =========================================================
! String
! =========================================================

! Universal octet-string has tag number 4, we should however
! still be able to assign an arbitrary code number.
! >ber words should be called within a with-ber.
SYMBOL: tagnum

TUPLE: tag value ;

: <tag> ( -- <tag> ) 4 tag construct-boa ;

: with-ber ( quot -- )
    [
        <tag> tagnum set
        call
    ] with-scope ; inline

: set-tag ( value -- )
    tagnum get set-tag-value ;

M: string >ber ( str -- byte-array )
    tagnum get tag-value 1array "C" pack-native swap dup
    length >ber-length-encoding swapd append swap
    >byte-array append ;

: >ber-application-string ( n str -- byte-array )
    >r HEX: 40 + set-tag r> >ber ;

GENERIC: >ber-contextspecific ( n obj -- byte-array )
M: string >ber-contextspecific ( n str -- byte-array )
    >r HEX: 80 + set-tag r> >ber ;

! =========================================================
! Array
! =========================================================

: >ber-seq-internal ( array code -- byte-array )
    1array "C" pack-native swap dup length >ber-length-encoding
    swapd append swap [ number>string ] map "" join >array append ;

M: array >ber ( array -- byte-array )
    HEX: 30 >ber-seq-internal ;

: >ber-set ( array -- byte-array )
    HEX: 31 >ber-seq-internal ;

: >ber-sequence ( array -- byte-array )
    HEX: 30 >ber-seq-internal ;

: >ber-appsequence ( array -- byte-array )
    HEX: 60 >ber-seq-internal ;

M: array >ber-contextspecific ( array -- byte-array )
    HEX: A0 >ber-seq-internal ;
