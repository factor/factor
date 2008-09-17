! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io io.encodings.ascii io.files io.streams.string
kernel sequences splitting strings vectors math math.parser macros
fry peg.ebnf unicode.case arrays prettyprint quotations ;

IN: printf

<PRIVATE

: compose-all ( seq -- quot )
    [ ] [ compose ] reduce ;

: write-all ( seq -- quot )
    [ [ write ] append ] map ;

: apply-format ( params quot -- params string )
    [ dup pop ] dip call ; inline

: fix-neg ( string -- string )
    dup CHAR: 0 swap index 0 = 
      [ dup CHAR: - swap index dup 
        [ swap remove-nth "-" prepend ] 
        [ drop ] if ] when ;

: >digits ( string -- digits ) 
    [ 0 ] [ string>number ] if-empty ;

: max-digits ( string digits -- string ) 
    [ "." split1 ] dip [ CHAR: 0 pad-right ] [ head-slice ] bi "." swap 3append ;

: max-width ( string length -- string ) 
    [ dup length ] dip [ > ] keep swap [ head-slice >string ] [ drop ] if ;

: >exponential ( n -- base exp ) 
    0 
    [ swap dup [ 10.0 > ] keep 1.0 < or ] 
    [ dup 10.0 > 
      [ 10.0 / [ 1+ ] dip swap ] 
      [ 10.0 * [ 1- ] dip swap ] if
    ] [ swap ] while 
    [ number>string ] dip 
    dup abs number>string 2 CHAR: 0 pad-left
    [ 0 < [ "-" ] [ "+" ] if ] dip append
    "e" prepend ; 

EBNF: parse-format-string

plain-text = (!("%").)+          => [[ >string 1quotation ]]

percents  =  "%"                 => [[ '[ "%" ] ]]

pad-zero  = "0"                  => [[ CHAR: 0 ]] 
pad-char  = "'" (.)              => [[ second ]] 
pad-char_ = (pad-zero|pad-char)? => [[ CHAR: \s or 1quotation ]]
pad-align = ("-")?               => [[ [ [ pad-right ] ] [ [ pad-left ] ] if ]] 
pad-width = ([0-9])*             => [[ >digits 1quotation ]]
pad       = pad-align pad-char_ pad-width => [[ reverse compose-all ]]

width     = "." ([0-9])*         => [[ second >digits '[ _ max-width ] ]]
width_    = (width)?             => [[ [ ] or ]] 

digits    = "." ([0-9])*         => [[ second >digits '[ _ max-digits ] ]]
digits_   = (digits)?            => [[ [ ] or ]]

fmt-c     = "c"                  => [[ [ 1string ] ]]
fmt-C     = "C"                  => [[ [ 1string >upper ] ]]
chars     = (fmt-c | fmt-C)      => [[ '[ _ apply-format ] ]]

fmt-s     = "s"                  => [[ [ ] ]]
fmt-S     = "S"                  => [[ [ >upper ] ]]
strings   = pad width_ (fmt-s | fmt-S) => [[ reverse compose-all '[ _ apply-format ] ]]

fmt-d     = "d"                  => [[ [ >fixnum number>string ] ]]
decimals  = fmt-d

fmt-e     = "e"                  => [[ [ >exponential ] ]]
fmt-E     = "E"                  => [[ [ >exponential >upper ] ]]
exps      = digits_ (fmt-e | fmt-E) => [[ reverse [ swap ] join [ swap append ] append ]] 

fmt-f     = "f"                  => [[ [ >float number>string ] ]] 
floats    = digits_ fmt-f        => [[ reverse compose-all ]]

fmt-x     = "x"                  => [[ [ >hex ] ]]
fmt-X     = "X"                  => [[ [ >hex >upper ] ]]
hex       = fmt-x | fmt-X

numbers   = (pad) (decimals|floats|hex|exps) => [[ reverse compose-all [ fix-neg ] append '[ _ apply-format ] ]]

formats   = "%" (chars|strings|numbers|percents) => [[ second ]]

text      = (formats|plain-text)* => [[ write-all compose-all ]]

;EBNF

PRIVATE>

MACRO: printf ( format-string -- )
    parse-format-string '[ reverse >vector @ drop ] ;

: sprintf ( params format-string -- result )
    [ printf ] with-string-writer ;

: fprintf ( filename params format-string -- )
    rot ascii [ printf ] with-file-appender ;

