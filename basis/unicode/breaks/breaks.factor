! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry interval-maps
kernel literals locals math namespaces parser sequences
simple-flat-file unicode.categories unicode.data
unicode.normalize.private words words.constant ;
IN: unicode.breaks

<PRIVATE

! Grapheme breaks
<<
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
    hangul-base - 0x1C mod zero? LV LVT ? ;

CATEGORY: grapheme-control Zl Zp Cc Cf ;
: control-class ( ch -- class )
    {
        { CHAR: \r [ CR ] }
        { CHAR: \n [ LF ] }
        { 0x200C [ Extend ] }
        { 0x200D [ Extend ] }
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

: eval-seq ( seq -- seq )
    [ dup word? [ execute( -- x ) ] when ] map ;

: (set-table) ( class1 class2 val -- )
    [ table get nth ] dip '[ _ or ] change-nth ;

: set-table ( classes1 classes2 val -- )
    [ [ eval-seq ] bi@ ] dip
    [ [ (set-table) ] curry with each ] 2curry each ;

: connect ( class1 class2 -- ) 1 set-table ;
: disconnect ( class1 class2 -- ) 0 set-table ;

: make-grapheme-table ( -- )
    { CR } { LF } connect
    { Control CR LF } graphemes <iota> disconnect
    graphemes <iota> { Control CR LF } disconnect
    { L } { L V LV LVT } connect
    { LV V } { V T } connect
    { LVT T } { T } connect
    graphemes <iota> { Extend } connect
    graphemes <iota> { SpacingMark } connect
    { Prepend } graphemes <iota> connect ;

"grapheme-table" create-word-in
graphemes init-table table
[ make-grapheme-table finish-table ] with-variable
define-constant
>>

: grapheme-break? ( class1 class2 -- ? )
    grapheme-table nth nth not ;

! Word breaks
<<
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
CONSTANT: unicode-words 13

! Is there a way to avoid this?
CONSTANT: word-break-classes H{
    { "Other" 0 } { "CR" 1 } { "LF" 2 } { "Newline" 3 }
    { "Extend" 4 } { "Format" 5 } { "Katakana" 6 }
    { "ALetter" 7 } { "MidLetter" 8 }
    { "MidNum" 9 } { "MidNumLet" 10 } { "Numeric" 11 }
    { "ExtendNumLet" 12 }
}

"word-break-table" create-word-in
"vocab:unicode/data/WordBreakProperty.txt"
load-interval-file dup array>>
[ 2 swap [ word-break-classes at ] change-nth ] each
define-constant
>>

: word-break-prop ( char -- word-break-prop )
    word-break-table interval-at wOther or ;

<<
SYMBOL: check-letter-before
SYMBOL: check-letter-after
SYMBOL: check-number-before
SYMBOL: check-number-after

: make-word-table ( -- )
    { wCR } { wLF } connect
    { wNewline wCR wLF } unicode-words <iota> disconnect
    unicode-words <iota> { wNewline wCR wLF } disconnect
    { wALetter } { wMidLetter wMidNumLet } check-letter-after set-table
    { wMidLetter wMidNumLet } { wALetter } check-letter-before set-table
    { wNumeric wALetter } { wNumeric wALetter } connect
    { wNumeric } { wMidNum wMidNumLet } check-number-after set-table
    { wMidNum wMidNumLet } { wNumeric } check-number-before set-table
    { wKatakana } { wKatakana } connect
    { wALetter wNumeric wKatakana wExtendNumLet } { wExtendNumLet }
    [ connect ] [ swap connect ] 2bi ;

: finish-word-table ( -- table )
    table get [
        [ { { 0 [ f ] } { 1 [ t ] } [ ] } case ] map
    ] map ;

"word-table" create-word-in
unicode-words init-table table
[ make-word-table finish-word-table ] with-variable
define-constant
>>

: word-table-nth ( class1 class2 -- ? )
    word-table nth nth ;

:: property-not= ( str i property -- ? )
    i [
        i str ?nth [ word-break-prop property = not ]
        [ f ] if*
    ] [ t ] if ;

: (format/extended?) ( class -- ? )
    ${ wExtend wFormat } member? ; inline

: format/extended? ( ch -- ? )
    word-break-prop (format/extended?) ;

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
    new-char word-break-prop :> new-class
    new-class (format/extended?)
    [ old-class dup ${ wCR wLF wNewline } member? ] [
        new-class old-class over word-table-nth
        [ str i 1 - ] dip word-break?
    ] if ;

PRIVATE>
