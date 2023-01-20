! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien byte-arrays kernel math parser
prettyprint.custom sequences sequences.private ;
IN: nibble-arrays

TUPLE: nibble-array
{ length array-capacity read-only }
{ underlying byte-array read-only } ;

<PRIVATE

CONSTANT: nibble 0b1111

: nibbles>bytes ( m -- n ) 1 + 2/ ; inline

: byte/nibble ( n -- shift n' )
    [ 1 bitand 2 shift ] [ -1 shift ] bi ; inline

: get-nibble ( n byte -- nibble )
    swap neg shift nibble bitand ; inline

:: set-nibble ( value n byte -- byte' )
    byte nibble n shift bitnot bitand
    value n shift
    bitor ; inline

: nibble@ ( n nibble-array -- shift n' byte-array )
    [ >fixnum byte/nibble ] [ underlying>> ] bi* ; inline

PRIVATE>

ERROR: bad-array-length n ;

: <nibble-array> ( n -- nibble-array )
    dup 0 < [ bad-array-length ] when
    dup nibbles>bytes <byte-array> nibble-array boa ; inline

M: nibble-array length length>> ;

M: nibble-array nth-unsafe
    nibble@ nth-unsafe get-nibble ;

M: nibble-array set-nth-unsafe
    nibble@ [ nth-unsafe set-nibble ] 2keep set-nth-unsafe ;

M: nibble-array clone
    [ length>> ] [ underlying>> clone ] bi nibble-array boa ;

: >nibble-array ( seq -- nibble-array )
    T{ nibble-array } clone-like ; inline

M: nibble-array like
    drop dup nibble-array? [ >nibble-array ] unless ;

M: nibble-array new-sequence drop <nibble-array> ;

M: nibble-array equal?
    over nibble-array? [ sequence= ] [ 2drop f ] if ;

M: nibble-array resize
    [ drop ] [
        [ nibbles>bytes ] [ underlying>> ] bi*
        resize-byte-array
    ] 2bi
    nibble-array boa ;

M: nibble-array byte-length length nibbles>bytes ;

SYNTAX: N{ \ } [ >nibble-array ] parse-literal ;

INSTANCE: nibble-array sequence

M: nibble-array pprint-delims drop \ N{ \ } ;
M: nibble-array >pprint-sequence ;
M: nibble-array pprint* pprint-object ;
