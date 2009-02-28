! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit unicode.categories kernel math
combinators splitting sequences math.parser io.files io assocs
arrays namespaces make math.ranges unicode.normalize.private values
io.encodings.ascii unicode.syntax unicode.data compiler.units fry
alien.syntax sets accessors interval-maps memoize locals words ;
IN: unicode.breaks

<PRIVATE
! Grapheme breaks

C-ENUM: Any L V T LV LVT Extend Control CR LF
    SpacingMark Prepend graphemes ;

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

CATEGORY: (extend) Me Mn ;
: extend? ( ch -- ? )
    { [ (extend)? ] [ "Other_Grapheme_Extend" property? ] } 1|| ;

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

: eval-seq ( seq -- seq ) [ dup word? [ execute ] when ] map ;

: (set-table) ( class1 class2 val -- )
    [ table get nth ] dip '[ _ or ] change-nth ;

: set-table ( classes1 classes2 val -- )
    [ [ eval-seq ] bi@ ] dip
    [ [ (set-table) ] curry with each ] 2curry each ;

: connect ( class1 class2 -- ) 1 set-table ;
: disconnect ( class1 class2 -- ) 0 set-table ;
  
: break-around ( classes1 classes2 -- )
    [ disconnect ] [ swap disconnect ] 2bi ;

: make-grapheme-table ( -- )
    { CR } { LF } connect
    { Control CR LF } graphemes disconnect
    graphemes { Control CR LF } disconnect
    { L } { L V LV LVT } connect
    { LV V } { V T } connect
    { LVT T } { T } connect
    graphemes { Extend } connect
    graphemes { SpacingMark } connect
    { Prepend } graphemes connect ;

VALUE: grapheme-table

: grapheme-break? ( class1 class2 -- ? )
    grapheme-table nth nth not ;

: chars ( i str n -- str[i] str[i+n] )
    swap [ dupd + ] dip [ ?nth ] curry bi@ ;

PRIVATE>

: first-grapheme ( str -- i )
    unclip-slice grapheme-class over
    [ grapheme-class [ nip ] [ grapheme-break? ] 2bi ] find drop
    nip swap length or 1+ ;

<PRIVATE

: >pieces ( str quot: ( str -- i ) -- graphemes )
    [ dup empty? not ] swap '[ dup @ cut-slice swap ] produce nip ; inline

PRIVATE>

: >graphemes ( str -- graphemes )
    [ first-grapheme ] >pieces ;

: string-reverse ( str -- rts )
    >graphemes reverse concat ;

: last-grapheme ( str -- i )
    unclip-last-slice grapheme-class swap
    [ grapheme-class dup rot grapheme-break? ] find-last drop ?1+ nip ;

<PRIVATE

graphemes init-table table
[ make-grapheme-table finish-table ] with-variable
to: grapheme-table

! Word breaks

VALUE: word-break-table

"vocab:unicode/data/WordBreakProperty.txt" load-script
to: word-break-table

C-ENUM: wOther wCR wLF wNewline wExtend wFormat wKatakana wALetter wMidLetter
wMidNum wMidNumLet wNumeric wExtendNumLet words ;

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
    { wNewline wCR wLF } words disconnect
    words { wNewline wCR wLF } disconnect
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
    dupd 1+ (walk-up) [ 1+ (walk-up) ] [ drop f ] if* ;

: (walk-down) ( str i -- j )
    swap [ format/extended? not ] find-last-from drop ;

: walk-down ( str i -- j )
    dupd (walk-down) [ 1- (walk-down) ] [ drop f ] if* ;

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
    nip swap length or 1+ ;

: >words ( str -- words )
    [ first-word ] >pieces ;
