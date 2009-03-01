! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel io io.files combinators.short-circuit
math.order values assocs io.encodings io.binary fry strings math
io.encodings.ascii arrays byte-arrays accessors splitting
math.parser biassocs io.encodings.iana io.encodings.asian
locals ;
IN: io.encodings.japanese

SINGLETON: shift-jis

shift-jis "Shift_JIS" register-encoding

SINGLETON: windows-31j

windows-31j "Windows-31J" register-encoding

SINGLETON: eucjp

! eucjp "EUCJP" register-encoding


<PRIVATE

VALUE: shift-jis-table

M: shift-jis <encoder> drop shift-jis-table <encoder> ;
M: shift-jis <decoder> drop shift-jis-table <decoder> ;

VALUE: windows-31j-table

M: windows-31j <encoder> drop windows-31j-table <encoder> ;
M: windows-31j <decoder> drop windows-31j-table <decoder> ;



TUPLE: jis assoc ;

: <jis> ( assoc -- jis )
    [ nip ] assoc-filter
    >biassoc jis boa ;

: ch>jis ( ch tuple -- jis ) assoc>> value-at [ encode-error ] unless* ;
: jis>ch ( jis tuple -- string ) assoc>> at replacement-char or ;

: process-jis ( lines -- assoc )
    [ "#" split1 drop ] map harvest [
        "\t" split 2 head
        [ 2 short tail hex> ] map
    ] map ;

: make-jis ( filename -- jis )
    ascii file-lines process-jis <jis> ;

"vocab:io/encodings/japanese/CP932.txt"
make-jis to: windows-31j-table


"vocab:io/encodings/japanese/sjis-0208-1997-std.txt"
make-jis to: shift-jis-table


: small? ( char -- ? )
    ! ASCII range or single-byte halfwidth katakana
    { [ 0 HEX: 7F between? ] [ HEX: A1 HEX: DF between? ] } 1|| ;

: write-halfword ( stream halfword -- )
    h>b/b swap 2byte-array swap stream-write ;

M: jis encode-char
    swapd ch>jis
    dup small?
    [ swap stream-write1 ]
    [ write-halfword ] if ;

M: jis decode-char
    swap dup stream-read1 [
        dup small? [ nip swap jis>ch ] [
            swap stream-read1
            [ 2array be> swap jis>ch ]
            [ 2drop replacement-char ] if*
        ] if
    ] [ 2drop f ] if* ;


! EUC-JP

VALUE: euc-0201-table

VALUE: euc-0208-table

VALUE: euc-0212-table

"vocab:io/encodings/japanese/euc-0201.txt" <code-table>* to: euc-0201-table

"vocab:io/encodings/japanese/euc-0208.txt" <code-table>* to: euc-0208-table

"vocab:io/encodings/japanese/euc-0212.txt" <code-table>* to: euc-0212-table


:: unicode>eucjp ( u -- n )
    u
    [ euc-0201-table u>n ]
    [ euc-0208-table u>n ]
    [ euc-0212-table u>n ]
    tri 3array harvest first
    ;

:: eucjp>unicode ( n -- u )
    n
    [ euc-0201-table n>u ]
    [ euc-0208-table n>u ]
    [ euc-0212-table n>u ]
    tri 3array harvest
    dup length zero?
    [ drop replacement-char ]
    [ first ]
    if ;


M: eucjp encode-char ( c stream encoding -- )
    drop
    [let | stream [ ]
           c [ ] |
        c unicode>eucjp small?
        [
            c stream stream-write1
        ]
        [
            c unicode>eucjp
            h>b/b 2byte-array stream stream-write
        ]
        if
    ] ;

M: eucjp decode-char ( stream encoding -- char/f )
    drop
    [let | stream [ ]
           c1! [ 0 ] |
        stream stream-read1 c1!
        c1 small?
        [ c1 ]
        [
            c1
            stream stream-read1
            2byte-array be>
            eucjp>unicode
        ]
        if
    ] ;



PRIVATE>
