! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
interval-maps kernel literals math namespaces sequences
simple-flat-file unicode.categories unicode.data
unicode.normalize.private words ;
IN: unicode.breaks

<PRIVATE

<<

:: load-interval-file-for ( filename n key -- table )
    filename load-data-file [ n swap nth key = ] filter
    intern-values expand-ranges ;

>>

CONSTANT: emoji-modifier-table $[
    "vocab:unicode/emoji-data.txt"
    1 "Emoji_Modifier" load-interval-file-for
]

CONSTANT: extended-pictographic-table $[
    "vocab:unicode/emoji-data.txt"
    1 "Extended_Pictographic" load-interval-file-for
]

CONSTANT: spacing-mark-exceptions-table $[
    {
        0x102B 0x102C 0x1038 { 0x1062 0x1064 } { 0x1067 0x106D }
        0x1083 { 0x1087 0x108C } 0x108F { 0x109A 0x109C } 0x1A61
        0x1A63 0x1A64 0xAA7B 0xAA7D 0x11720 0x11721
    } <interval-set>
]

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
CONSTANT: ZWJ 12
CONSTANT: Extended_Pictographic 13
CONSTANT: (Extended_Pictographic-Extend*-)ZWJ 14
CONSTANT: Regional_Indicator(even) 15
CONSTANT: Regional_Indicator(odd) 16
CONSTANT: graphemes 17

: jamo-class ( ch -- class )
    dup initial? [ drop L ]
    [ dup medial? [ drop V ] [ final? T Any ? ] if ] if ;

: hangul-class ( ch -- class )
    hangul-base - 0x1C mod zero? LV LVT ? ;

CATEGORY: extend
    Me Mn |
    "Other_Grapheme_Extend" property? ;

CATEGORY: grapheme-control Zl Zp Cc Cf ;

: control-class ( ch -- class )
    {
        { [ dup CHAR: \r = ]  [ drop CR ] }
        { [ dup CHAR: \n = ] [ drop LF ] }
        { [ dup 0x200C = ] [ drop Extend ] }
        { [ dup 0x200D = ] [ drop ZWJ ] }
        { [ dup "Other_Grapheme_Extend" property? ] [ drop Extend ] }
        [ drop Control ]
    } cond ;

: loe? ( ch -- ? )
    "Logical_Order_Exception" property? ;

CATEGORY: spacing Mc ;

: regional? ( ch -- ? )
    "Regional_Indicator" property? ;
>>

: modifier? ( ch -- ? )
    emoji-modifier-table interval-key? ; inline

:: grapheme-class ( str -- class )
    str last
    {
        { [ dup jamo? ] [ jamo-class ] }
        { [ dup hangul? ] [ hangul-class ] }
        { [ dup grapheme-control? ] [
            control-class dup ZWJ = [
                drop
                str unclip-last-slice drop dup [
                    {
                        [ extend? ]
                        [ control-class Extend = ]
                        [ modifier? ]
                    } 1|| not
                ] find-last drop [ swap ?nth ] [ last ] if*
                extended-pictographic-table interval-key? [
                    (Extended_Pictographic-Extend*-)ZWJ
                ] [ ZWJ ] if
              ] when
          ] }
        { [ dup extend? ] [ drop Extend ] }
        { [ dup modifier? ] [ drop Extend ] }
        { [ dup spacing? ] [
               spacing-mark-exceptions-table
               interval-key? [ Any ] [ SpacingMark ] if ] }
        { [ dup loe? ] [ drop Prepend ] }
        { [ dup regional? ] [
              drop
              f :> ri-even?!
              str unclip-last-slice drop [
                  regional? [ ri-even? not ri-even?! f ] [ t ] if
              ] find-last 2drop
              ri-even? [
                  Regional_Indicator(even)
              ] [
                  Regional_Indicator(odd)
              ] if
          ] }
        { [ dup extended-pictographic-table interval-key? ] [
              drop Extended_Pictographic
          ] }
        [ drop Any ]
    } cond ;

<<
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
    { CR } { LF } connect                                                       ! GB3
    { Control CR LF } graphemes <iota> disconnect                               ! GB4
    graphemes <iota> { Control CR LF } disconnect                               ! GB5
    { L } { L V LV LVT } connect                                                ! GB6
    { LV V } { V T } connect                                                    ! GB7
    { LVT T } { T } connect                                                     ! GB8
    graphemes <iota> { Extend ZWJ (Extended_Pictographic-Extend*-)ZWJ } connect ! GB9
    graphemes <iota> { SpacingMark } connect                                    ! GB9a
    { Prepend } graphemes <iota> connect                                        ! GB9b
    { (Extended_Pictographic-Extend*-)ZWJ } { Extended_Pictographic } connect   ! GB11
    { Regional_Indicator(odd) } { Regional_Indicator(even) } connect ;          ! GB12,13
>>

CONSTANT: grapheme-table $[
    graphemes init-table table
    [ make-grapheme-table finish-table ] with-variable
]

: grapheme-break? ( class1 class2 -- ? )
    grapheme-table nth nth not ;

! Word breaks
<<
CONSTANT: wOther 0
CONSTANT: wCR 1
CONSTANT: wLF 2
CONSTANT: wNewline 3
CONSTANT: wExtend 4
CONSTANT: wZWJ 5
CONSTANT: wRegional_Indicator 6
CONSTANT: wFormat 7
CONSTANT: wKatakana 8
CONSTANT: wHebrew_Letter 9
CONSTANT: wALetter 10
CONSTANT: wSingle_Quote 11
CONSTANT: wDouble_Quote 12
CONSTANT: wMidNumLet 13
CONSTANT: wMidLetter 14
CONSTANT: wMidNum 15
CONSTANT: wNumeric 16
CONSTANT: wExtendNumLet 17
CONSTANT: wWSegSpace 18
CONSTANT: unicode-words 19
>>

<<
CONSTANT: word-break-table $[
    "vocab:unicode/WordBreakProperty.txt"
    load-interval-file dup array>> [
        2 swap [
            {
                { "Other" [ wOther ] }
                { "CR" [ wCR ] }
                { "LF" [ wLF ] }
                { "Newline" [ wNewline ] }
                { "Extend" [ wExtend ] }
                { "ZWJ" [ wZWJ ]  }
                { "Regional_Indicator" [ wRegional_Indicator ] }
                { "Format" [ wFormat ] }
                { "Katakana" [ wKatakana ] }
                { "Hebrew_Letter" [ wHebrew_Letter ] }
                { "ALetter" [ wALetter ] }
                { "Single_Quote" [ wSingle_Quote ] }
                { "Double_Quote" [ wDouble_Quote ] }
                { "MidNumLet" [ wMidNumLet ] }
                { "MidLetter" [ wMidLetter ] }
                { "MidNum" [ wMidNum ] }
                { "Numeric" [ wNumeric ] }
                { "ExtendNumLet" [ wExtendNumLet ] }
                { "WSegSpace" [ wWSegSpace ] }
            } case
        ] change-nth
    ] each
]
>>

: word-break-prop ( char -- word-break-prop )
    word-break-table interval-at wOther or ;

<<
SYMBOL: check-AHletter-before
SYMBOL: check-AHletter-after
SYMBOL: check-Hebrew-letter-before
SYMBOL: check-Hebrew-letter-after
SYMBOL: check-number-before
SYMBOL: check-number-after
SYMBOL: check-Extended_Pictographic
SYMBOL: check-RI-pair

: make-word-table ( -- )
    { wCR } { wLF } connect                                                   ! WB3
    { wNewline                                                                ! WB3a
      wCR
      wLF } unicode-words <iota> disconnect
    unicode-words <iota> { wNewline                                           ! WB3b
                           wCR
                           wLF } disconnect
    { wZWJ } unicode-words <iota> check-Extended_Pictographic set-table       ! WB3c
    { wWSegSpace } { wWSegSpace } connect                                     ! WB3d
    unicode-words <iota> { wZWJ } connect                                     ! WB4
    { wALetter                                                                ! WB5
      wHebrew_Letter } { wALetter
                         wHebrew_Letter } connect
    { wALetter                                                                ! WB6
      wHebrew_Letter } { wMidLetter
                         wMidNumLet
                         wSingle_Quote } check-AHletter-after set-table
    { wMidLetter                                                              ! WB7
      wMidNumLet
      wSingle_Quote } { wALetter
                        wHebrew_Letter } check-AHletter-before set-table
    { wHebrew_Letter } { wSingle_Quote } connect                              ! WB7a
    { wHebrew_Letter } { wDouble_Quote } check-Hebrew-letter-after set-table  ! WB7b 
    { wDouble_Quote } { wHebrew_Letter } check-Hebrew-letter-before set-table ! WB7c 
    { wNumeric } { wNumeric } connect                                         ! WB8
    { wALetter
      wHebrew_Letter } { wNumeric } connect                                   ! WB9
    { wNumeric } { wALetter                                                   ! WB10
                   wHebrew_Letter } connect
    { wMidNum                                                                 ! WB11
      wMidNumLet
      wSingle_Quote } { wNumeric } check-number-before set-table
    { wNumeric } { wMidNum                                                    ! WB12
                   wMidNumLet
                   wSingle_Quote } check-number-after set-table
    { wKatakana } { wKatakana } connect                                       ! WB13
    { wALetter                                                                ! WB13a 
      wHebrew_Letter
      wNumeric
      wKatakana
      wExtendNumLet } { wExtendNumLet } connect
    { wExtendNumLet } { wALetter                                              ! WB13b
                        wHebrew_Letter
                        wNumeric
                        wKatakana } connect
    { wRegional_Indicator } { wRegional_Indicator } check-RI-pair set-table ; ! WB15,16

: finish-word-table ( -- table )
    table get [
        [ { { 0 [ f ] } { 1 [ t ] } [ ] } case ] map
    ] map ;
>>

<<
CONSTANT: word-table $[
    unicode-words init-table table
    [ make-word-table finish-word-table ] with-variable
]
>>

: word-table-nth ( class1 class2 -- ? )
    word-table nth nth ;

:: property-not= ( str i property -- ? )
    i [
        i str ?nth [ word-break-prop property = not ]
        [ f ] if*
    ] [ t ] if ;

: (format/extended?) ( class -- ? )
    ${ wExtend wFormat } member? ; inline                                     ! WB4

: format/extended? ( ch -- ? )
    word-break-prop (format/extended?) ;

: (format/extended/zwj?) ( class -- ? )
    ${ wExtend wFormat wZWJ } member? ; inline                                ! WB4

: format/extended/zwj? ( ch -- ? )
    word-break-prop (format/extended/zwj?) ;

: (walk-up) ( str i -- j )
    swap [ format/extended/zwj? not ] find-from drop ;

: walk-up ( str i -- j )
    dupd 1 + (walk-up) [ 1 + (walk-up) ] [ drop f ] if* ;

: (walk-down) ( str i -- j )
    swap [ format/extended/zwj? not ] find-last-from drop ;

: walk-down ( str i -- j )
    dupd (walk-down) [ 1 - (walk-down) ] [ drop f ] if* ;

:: word-break? ( str i table-entry -- ? )
    str i table-entry
    {
        { t [ 2drop f ] }
        { f [ 2drop t ] }
        { check-AHletter-after
          [ dupd walk-up
            { [ wALetter property-not= ] [ wHebrew_Letter property-not= ] } 2|| ] }
        { check-AHletter-before
          [ dupd walk-down
            { [ wALetter property-not= ] [ wHebrew_Letter property-not= ] } 2||  ] }
        { check-Hebrew-letter-after
          [ dupd walk-up wHebrew_Letter property-not= ] }
        { check-Hebrew-letter-before
          [ dupd walk-down wHebrew_Letter property-not= ] }
        { check-number-after
          [ dupd walk-up wNumeric property-not= ] }
        { check-number-before
          [ dupd walk-down wNumeric property-not= ] }
        { check-Extended_Pictographic
          [ swap ?nth extended-pictographic-table interval-key? ] }
        { check-RI-pair [
              2drop 
              f :> ri-even?!
              i str [
                  regional? [ ri-even? not ri-even?! f ] [ t ] if
              ] find-last-from 2drop
              ri-even? not
          ] }
    } case ;

:: word-break-next ( old-class new-char i str -- next-class ? )
    new-char word-break-prop :> new-class
    new-class (format/extended?)
    [ old-class dup ${ wCR wLF wNewline } member? ] [
        new-class old-class over word-table-nth
        [ str i 1 - ] dip word-break?
    ] if ;

PRIVATE>
