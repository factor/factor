! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit unicode.categories kernel math
combinators splitting sequences math.parser io.files io assocs
arrays namespaces make math.ranges unicode.normalize values
io.encodings.ascii unicode.syntax unicode.data compiler.units
alien.syntax sets accessors interval-maps memoize locals words ;
IN: unicode.breaks

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

: first-grapheme ( str -- i )
    unclip-slice grapheme-class over
    [ grapheme-class tuck grapheme-break? ] find-index
    nip swap length or 1+ ;

:: (>pieces) ( str quot -- )
    str [
        dup quot call cut-slice
        swap , quot (>pieces)
    ] unless-empty ;

: >pieces ( str quot -- graphemes )
    [ (>pieces) ] { } make ;

: >graphemes ( str -- graphemes )
    [ first-grapheme ] >pieces ;

: string-reverse ( str -- rts )
    >graphemes reverse concat ;

: last-grapheme ( str -- i )
    unclip-last-slice grapheme-class swap
    [ grapheme-class dup rot grapheme-break? ] find-last-index ?1+ nip ;

graphemes init-table table
[ make-grapheme-table finish-table ] with-variable
to: grapheme-table

! Word breaks

VALUE: word-break-table

"resource:basis/unicode/data/WordBreakProperty.txt" load-script
to: word-break-table

C-ENUM: wOther wCR wLF wNewline wExtend wFormat wKatakana wALetter wMidLetter
wMidNum wMidNumLet wNumeric wExtendNumLet words ;

MEMO: word-break-classes ( -- table )
    H{
        { "Other" wOther } { "CR" wCR } { "LF" wLF } { "Newline" wNewline }
        { "Extend" wExtend } { "Format" wFormat } { "Katakana" wKatakana }
        { "ALetter" wALetter } { "MidLetter" wMidLetter }
        { "MidNum" wMidNum } { "MidNumLet" wMidNumLet } { "Numeric" wNumeric }
        { "ExtendNumLet" wExtendNumLet }
    } [ execute ] assoc-map ;

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

: word-break? ( class1 class2 -- ? )
    word-table nth nth not ;

: skip? ( char -- ? )
    word-break-prop { 4 5 } member? ; ! wExtend or wFormat

: word-break-next ( old-class new-char -- next-class ? )
    word-break-prop dup { 4 5 } member?
    [ drop f ] [ tuck word-break? ] if ;

: first-word ( str -- i )
    unclip-slice word-break-prop over
    [ word-break-next ] find-index
    nip swap length or 1+ ;
! This must be changed to ignore format/extended chars and
! handle symbols in the table specially

: >words ( str -- words )
    [ first-word ] >pieces ;
