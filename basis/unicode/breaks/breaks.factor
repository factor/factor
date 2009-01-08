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

: set-table ( class1 class2 val -- )
    -rot table get nth [ swap or ] change-nth ;

: connect ( class1 class2 -- ) 1 set-table ;
: disconnect ( class1 class2 -- ) 0 set-table ;

: check-before ( class classes value -- )
    [ set-table ] curry with each ;

: check-after ( classes class value -- )
    [ set-table ] 2curry each ;

: connect-before ( class classes -- )
    1 check-before ;

: connect-after ( classes class -- )
    1 check-after ;
  
: break-around ( classes1 classes2 -- )
    [ [ 2dup disconnect swap disconnect ] with each ] curry each ;

: make-grapheme-table ( -- )
    CR LF connect
    Control CR LF 3array graphemes break-around
    L L V LV LVT 4array connect-before
    V V T 2array connect-before
    LV V T 2array connect-before
    T T connect
    LVT T connect
    graphemes Extend connect-after
    graphemes SpacingMark connect-after
    Prepend graphemes connect-before ;

VALUE: grapheme-table

: grapheme-break? ( class1 class2 -- ? )
    grapheme-table nth nth not ;

: chars ( i str n -- str[i] str[i+n] )
    swap [ dupd + ] dip [ ?nth ] curry bi@ ;

: find-index ( seq quot -- i ) find drop ; inline
: find-last-index ( seq quot -- i ) find-last drop ; inline

PRIVATE>

: first-grapheme ( str -- i )
    unclip-slice grapheme-class over
    [ grapheme-class tuck grapheme-break? ] find-index
    nip swap length or 1+ ;

<PRIVATE

: >pieces ( str quot: ( str -- i ) -- graphemes )
    [ dup empty? not ] swap '[ dup @ cut-slice swap ]
    [ ] produce nip ; inline

PRIVATE>

: >graphemes ( str -- graphemes )
    [ first-grapheme ] >pieces ;

: string-reverse ( str -- rts )
    >graphemes reverse concat ;

: last-grapheme ( str -- i )
    unclip-last-slice grapheme-class swap
    [ grapheme-class dup rot grapheme-break? ] find-last-index ?1+ nip ;

<PRIVATE

graphemes init-table table
[ make-grapheme-table finish-table ] with-variable
to: grapheme-table

! Word breaks

VALUE: word-break-table

"resource:basis/unicode/data/WordBreakProperty.txt" load-script
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

: e ( seq -- seq ) [ execute ] map ;

SYMBOL: check-letter-before
SYMBOL: check-letter-after
SYMBOL: check-number-before
SYMBOL: check-number-after

: make-word-table ( -- )
    wCR wLF connect
    { wNewline wCR wLF } e words break-around
    wALetter dup connect
    wALetter { wMidLetter wMidNumLet } e check-letter-after check-before
    { wMidLetter wMidNumLet } e wALetter check-letter-before check-after
    wNumeric dup connect
    wALetter wNumeric connect
    wNumeric wALetter connect
    wNumeric { wMidNum wMidNumLet } e check-number-after check-before
    { wMidNum wMidNumLet } e wNumeric check-number-before check-after
    wKatakana dup connect
    { wALetter wNumeric wKatakana wExtendNumLet } e wExtendNumLet
    [ connect-after ] [ swap connect-before ] 2bi ;

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

: property-not= ( i str property -- ? )
    pick [
        [ ?nth ] dip swap
        [ word-break-prop = not ] [ drop f ] if*
    ] [ 3drop t ] if ;

: format/extended? ( ch -- ? )
    word-break-prop { 4 5 } member? ;

:: walk-up ( str i -- j )
    i 1 + str [ format/extended? not ] find-from drop
    1+ str [ format/extended? not ] find-from drop ; ! possible bounds error?

:: walk-down ( str i -- j )
    i str [ format/extended? not ] find-last-from drop
    1- str [ format/extended? not ] find-last-from drop ; ! possible bounds error?

:: word-break? ( table-entry i str -- ? )
    table-entry {
        { t [ f ] }
        { f [ t ] }
        { check-letter-after
            [ str i walk-up str wALetter property-not= ] }
        { check-letter-before
            [ str i walk-down str wALetter property-not= ] }
        { check-number-after
            [ str i walk-up str wNumeric property-not= ] }
        { check-number-before
            [ str i walk-down str wNumeric property-not= ] }
    } case ;

:: word-break-next ( old-class new-char i str -- next-class ? )
    new-char word-break-prop dup { 4 5 } member?
    [ drop old-class dup { 1 2 3 } member? ]
    [ old-class over word-table-nth i str word-break? ] if ;

PRIVATE>

:: first-word ( str -- i )
    str unclip-slice word-break-prop over <enum>
    [ swap str word-break-next ] assoc-find 2drop
    nip swap length or 1+ ;

: >words ( str -- words )
    [ first-word ] >pieces ;
