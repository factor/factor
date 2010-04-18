! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit unicode.categories kernel math
combinators splitting sequences math.parser io.files io assocs
arrays namespaces make math.ranges unicode.normalize
unicode.normalize.private values io.encodings.ascii
unicode.data compiler.units fry unicode.categories.syntax
alien.syntax sets accessors interval-maps memoize locals words
simple-flat-file ;
IN: unicode.breaks

<PRIVATE
! Grapheme breaks

CONSTANT: Any 0
CONSTANT: L 1
CONSTANT: V 2
CONSTANT: T 3
CONSTANT: LV 4
CONSTANT: LVT 5
CONSTANT: Extend 6
CONSTANT: Control 7
CONSTANT: CR 8
CONSTANT: LF 9
CONSTANT: SpacingMark 10
CONSTANT: Prepend 11
CONSTANT: graphemes 12

: jamo-class ( ch -- class )
    dup initial? [ drop L ]
    [ dup medial? [ drop V ] [ final? T Any ? ] if ] if ;

: hangul-class ( ch -- class )
    hangul-base - HEX: 1C mod zero? LV LVT ? ;

CATEGORY: grapheme-control Zl Zp Cc Cf ;
: control-class ( ch -- class )
    {
        { CHAR: \r [ CR ] }
        { CHAR: \n [ LF ] }
        { HEX: 200C [ Extend ] }
        { HEX: 200D [ Extend ] }
        [ drop Control ]
    } case ;

CATEGORY: extend
    Me Mn |
    "Other_Grapheme_Extend" property? ;

: loe? ( ch -- ? )
    "Logical_Order_Exception" property? ;

CATEGORY: spacing Mc ;

: grapheme-class ( ch -- class )
    {
        { [ dup jamo? ] [ jamo-class ] }
        { [ dup hangul? ] [ hangul-class ] }
        { [ dup grapheme-control? ] [ control-class ] }
        { [ dup extend? ] [ drop Extend ] }
        { [ dup spacing? ] [ drop SpacingMark ] }
        { [ loe? ] [ Prepend ] }
        [ Any ]
    } cond ;

: init-table ( size -- table )
    dup [ f <array> ] curry replicate ;

SYMBOL: table

: finish-table ( -- table )
    table get [ [ 1 = ] map ] map ;

: eval-seq ( seq -- seq ) [ ?execute ] map ;

: (set-table) ( class1 class2 val -- )
    [ table get nth ] dip '[ _ or ] change-nth ;

: set-table ( classes1 classes2 val -- )
    [ [ eval-seq ] bi@ ] dip
    [ [ (set-table) ] curry with each ] 2curry each ;

: connect ( class1 class2 -- ) 1 set-table ;
: disconnect ( class1 class2 -- ) 0 set-table ;
  
: make-grapheme-table ( -- )
    { CR } { LF } connect
    { Control CR LF } graphemes iota disconnect
    graphemes iota { Control CR LF } disconnect
    { L } { L V LV LVT } connect
    { LV V } { V T } connect
    { LVT T } { T } connect
    graphemes iota { Extend } connect
    graphemes iota { SpacingMark } connect
    { Prepend } graphemes iota connect ;

VALUE: grapheme-table

: grapheme-break? ( class1 class2 -- ? )
    grapheme-table nth nth not ;

PRIVATE>

: first-grapheme ( str -- i )
    unclip-slice grapheme-class over
    [ grapheme-class [ nip ] [ grapheme-break? ] 2bi ] find drop
    nip swap length or 1 + ;

: first-grapheme-from ( start str -- i )
    over tail-slice first-grapheme + ;

: last-grapheme ( str -- i )
    unclip-last-slice grapheme-class swap
    [ grapheme-class dup rot grapheme-break? ] find-last drop ?1+ nip ;

: last-grapheme-from ( end str -- i )
    swap head-slice last-grapheme ;

<PRIVATE

: >pieces ( str quot: ( str -- i ) -- graphemes )
    [ dup empty? not ] swap '[ dup @ cut-slice swap ] produce nip ; inline

PRIVATE>

: >graphemes ( str -- graphemes )
    [ first-grapheme ] >pieces ;

: string-reverse ( str -- rts )
    >graphemes reverse concat ;

<PRIVATE

graphemes init-table table
[ make-grapheme-table finish-table ] with-variable
to: grapheme-table

! Word breaks

VALUE: word-break-table

"vocab:unicode/data/WordBreakProperty.txt" load-interval-file
to: word-break-table

CONSTANT: wOther 0
CONSTANT: wCR 1
CONSTANT: wLF 2
CONSTANT: wNewline 3
CONSTANT: wExtend 4
CONSTANT: wFormat 5
CONSTANT: wKatakana 6
CONSTANT: wALetter 7
CONSTANT: wMidLetter 8
CONSTANT: wMidNum 9
CONSTANT: wMidNumLet 10
CONSTANT: wNumeric 11
CONSTANT: wExtendNumLet 12
CONSTANT: words 13

: word-break-classes ( -- table ) ! Is there a way to avoid this?
    H{
        { "Other" 0 } { "CR" 1 } { "LF" 2 } { "Newline" 3 }
        { "Extend" 4 } { "Format" 5 } { "Katakana" 6 }
        { "ALetter" 7 } { "MidLetter" 8 }
        { "MidNum" 9 } { "MidNumLet" 10 } { "Numeric" 11 }
        { "ExtendNumLet" 12 }
    } ;

: word-break-prop ( char -- word-break-prop )
    word-break-table interval-at
    word-break-classes at [ wOther ] unless* ;

SYMBOL: check-letter-before
SYMBOL: check-letter-after
SYMBOL: check-number-before
SYMBOL: check-number-after

: make-word-table ( -- )
    { wCR } { wLF } connect
    { wNewline wCR wLF } words iota disconnect
    words iota { wNewline wCR wLF } disconnect
    { wALetter } { wMidLetter wMidNumLet } check-letter-after set-table
    { wMidLetter wMidNumLet } { wALetter } check-letter-before set-table
    { wNumeric wALetter } { wNumeric wALetter } connect
    { wNumeric } { wMidNum wMidNumLet } check-number-after set-table
    { wMidNum wMidNumLet } { wNumeric } check-number-before set-table
    { wKatakana } { wKatakana } connect
    { wALetter wNumeric wKatakana wExtendNumLet } { wExtendNumLet }
    [ connect ] [ swap connect ] 2bi ;

VALUE: word-table

: finish-word-table ( -- table )
    table get [
        [ { { 0 [ f ] } { 1 [ t ] } [ ] } case ] map
    ] map ;

words init-table table
[ make-word-table finish-word-table ] with-variable
to: word-table

: word-table-nth ( class1 class2 -- ? )
    word-table nth nth ;

:: property-not= ( str i property -- ? )
    i [
        i str ?nth [ word-break-prop property = not ]
        [ f ] if*
    ] [ t ] if ;

: format/extended? ( ch -- ? )
    word-break-prop { 4 5 } member? ;

: (walk-up) ( str i -- j )
    swap [ format/extended? not ] find-from drop ;

: walk-up ( str i -- j )
    dupd 1 + (walk-up) [ 1 + (walk-up) ] [ drop f ] if* ;

: (walk-down) ( str i -- j )
    swap [ format/extended? not ] find-last-from drop ;

: walk-down ( str i -- j )
    dupd (walk-down) [ 1 - (walk-down) ] [ drop f ] if* ;

: word-break? ( str i table-entry -- ? )
    {
        { t [ 2drop f ] }
        { f [ 2drop t ] }
        { check-letter-after
            [ dupd walk-up wALetter property-not= ] }
        { check-letter-before
            [ dupd walk-down wALetter property-not= ] }
        { check-number-after
            [ dupd walk-up wNumeric property-not= ] }
        { check-number-before
            [ dupd walk-down wNumeric property-not= ] }
    } case ;

:: word-break-next ( old-class new-char i str -- next-class ? )
    new-char format/extended?
    [ old-class dup { 1 2 3 } member? ] [
        new-char word-break-prop old-class over word-table-nth
        [ str i ] dip word-break?
    ] if ;

PRIVATE>

: first-word ( str -- i )
    [ unclip-slice word-break-prop over <enum> ] keep
    '[ swap _ word-break-next ] assoc-find 2drop
    nip swap length or 1 + ;

: >words ( str -- words )
    [ first-word ] >pieces ;

<PRIVATE

: nth-next ( i str -- str[i-1] str[i] )
    [ [ 1 - ] keep ] dip '[ _ nth ] bi@ ;

PRIVATE>

: word-break-at? ( i str -- ? )
    {
        [ drop zero? ]
        [ length = ]
        [
            [ nth-next [ word-break-prop ] dip ] 2keep
            word-break-next nip
        ]
    } 2|| ;

: first-word-from ( start str -- i )
    over tail-slice first-word + ;

: last-word ( str -- i )
    [ length iota ] keep '[ _ word-break-at? ] find-last drop 0 or ;

: last-word-from ( end str -- i )
    swap head-slice last-word ;
