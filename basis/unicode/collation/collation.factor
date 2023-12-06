! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit combinators.smart fry kernel make
math math.order math.parser namespaces sequences
simple-flat-file splitting strings unicode.data ;
IN: unicode.collation

<PRIVATE

SYMBOL: ducet

TUPLE: weight-levels primary secondary tertiary ignorable? ;
: <weight-levels> ( primary secondary tertiary -- weight-levels> )
    weight-levels new
        swap >>tertiary
        swap >>secondary
        swap >>primary ; inline

: parse-weight ( string -- weight )
    "]" split but-last [
        weight-levels new swap rest unclip CHAR: * = swapd >>ignorable?
        swap "." split first3 [ hex> ] tri@
        [ >>primary ] [ >>secondary ] [ >>tertiary ] tri*
    ] map ;

: parse-keys ( string -- chars )
    split-words [ hex> ] "" map-as ;

: parse-ducet ( file -- ducet )
    load-data-file [ [ parse-keys ] [ parse-weight ] bi* ] H{ } assoc-map-as ;

"vocab:unicode/allkeys.txt" parse-ducet ducet set-global

! https://www.unicode.org/reports/tr10/tr10-41.html#Well_Formed_DUCET
! WF5 - Well-formedness 5 condition:
! https://www.unicode.org/reports/tr10/tr10-41.html#WF5
!    { "0CC6" "0CC2" "0CD5" } ! 0CD5 is not a non-starter, don't add 2-gram "0CC6" "0CC2"to ducet
!    { "0DD9" "0DCF" "0DCA" } ! already in allkeys.txt file
!    { "0FB2" "0F71" "0F80" } ! added below
!    { "0FB3" "0F71" "0F80" } ! added below
! This breaks the unicode tests that ship in CollationTest_SHIFTED.txt
! but it's supposedly more correct.
: fixup-ducet-for-tibetan ( -- )
    {
        {
            { 0x0FB2 0x0F71 } ! CE(0FB2) CE(0F71)
            {
                T{ weight-levels
                    { primary 12719 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12741 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
        {
            { 0x0FB3 0x0F71 } ! CE(0FB3) CE(0F71)
            {
                T{ weight-levels
                    { primary 12722 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12741 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }

        {
            { 0x0FB2 0x0F71 0x0F72 } ! CE(0FB2) CE(0F71 0F72)
            {
                T{ weight-levels
                    { primary 12719 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12743 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
        {
            { 0x0FB2 0x0F73        } ! CE(0FB2) CE(0F71 0F72)
            {
                T{ weight-levels
                    { primary 12719 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12743 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
        {
            { 0x0FB2 0x0F71 0x0F74 } ! CE(0FB2) CE(0F71 0F74)
            {
                T{ weight-levels
                    { primary 12719 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12747 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
        {
            { 0x0FB2 0x0F75        } ! CE(0FB2) CE(0F71 0F74)
            {
                T{ weight-levels
                    { primary 12719 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12747 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
        {
            { 0x0FB3 0x0F71 0x0F72 } ! CE(0FB3) CE(0F71 0F72)
            {
                T{ weight-levels
                    { primary 12722 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12743 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
        {
            { 0x0FB3 0x0F73        } ! CE(0FB3) CE(0F71 0F72)
            {
                T{ weight-levels
                    { primary 12722 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12743 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
        {
            { 0x0FB3 0x0F71 0x0F74 } ! CE(0FB3) CE(0F71 0F74)
            {
                T{ weight-levels
                    { primary 12722 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12747 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
        {
            { 0x0FB3 0x0F75        } ! CE(0FB3) CE(0F71 0F74)
            {
                T{ weight-levels
                    { primary 12722 }
                    { secondary 32 }
                    { tertiary 2 }
                }
                T{ weight-levels
                    { primary 12747 }
                    { secondary 32 }
                    { tertiary 2 }
                }
            }
        }
    } ducet get-global '[ swap >string _ set-at ] assoc-each ;

! These values actually break the collation unit tests in CollationTest_SHIFTED.txt
! So we disable those tests in favor of supposedly better collation for Tibetan.
! https://www.unicode.org/reports/tr10/tr10-41.html#Well_Formed_DUCET

fixup-ducet-for-tibetan

: tangut-block? ( char -- ? )
    {
        [ 0x17000 0x18AFF between? ] ! Tangut and Tangut Components
        [ 0x18D00 0x18D8F between? ] ! Tangut Supplement
    } 1|| ; inline

: nushu-block? ( char -- ? )
    0x1B170 0x1B2FF between? ; inline

: khitan-block? ( char -- ? )
    0x18B00 0x18CFF between? ; inline

! https://wiki.computercraft.cc/Module:Unicode_data
! Unicode TR10 - Computing Implicit Weights
: base ( char -- base )
    {
        { [ dup 0x03400 0x04DBF between? ] [ drop 0xFB80 ] } ! Extension A
        { [ dup 0x20000 0x2A6DF between? ] [ drop 0xFB80 ] } ! Extension B
        { [ dup 0x2A700 0x2B739 between? ] [ drop 0xFB80 ] } ! Extension C
        { [ dup 0x2B740 0x2B81D between? ] [ drop 0xFB80 ] } ! Extension D
        { [ dup 0x2B820 0x2CEA1 between? ] [ drop 0xFB80 ] } ! Extension E
        { [ dup 0x2CEB0 0x2EBE0 between? ] [ drop 0xFB80 ] } ! Extension F
        { [ dup 0x30000 0x3134A between? ] [ drop 0xFB80 ] } ! Extension G
        { [ dup 0x31350 0x323AF between? ] [ drop 0xFB80 ] } ! Extension H
        { [ dup 0x2EBF0 0x2EE5D between? ] [ drop 0xFB80 ] } ! Extension I
        { [ dup 0x2F800 0x2FA1D between? ] [ drop 0xFB80 ] } ! CJK Compatibility
        { [ dup 0x04E00 0x09FFF between? ] [ drop 0xFB40 ] } ! CJK
        { [ dup 0x0F900 0x0FAD9 between? ] [ drop 0xFB40 ] } ! CJK
        [ drop 0xFBC0 ] ! Other
    } cond ;

: tangut-AAAA ( char -- weight-levels )
    drop 0xfb00 0x0020 0x0002 <weight-levels> ; inline

: tangut-BBBB ( char -- weight-levels )
    0x17000 - 0x8000 bitor 0 0 <weight-levels> ; inline

: nushu-AAAA ( char -- weight-levels )
    drop 0xfb01 0x0020 0x0002 <weight-levels> ; inline

: nushu-BBBB ( char -- weight-levels )
    0x1B170 - 0x8000 bitor 0 0 <weight-levels> ; inline

: khitan-AAAA ( char -- weight-levels )
    drop 0xfb02 0x0020 0x0002 <weight-levels> ; inline

: khitan-BBBB ( char -- weight-levels )
    0x18b00 - 0x8000 bitor 0 0 <weight-levels> ; inline

: AAAA ( char -- weight-levels )
    [ base ] [ -15 shift ] bi + 0x0020 0x0002 <weight-levels> ; inline

: BBBB ( char -- weight-levels )
    0x7FFF bitand 0x8000 bitor 0 0 <weight-levels> ; inline

: derive-weight ( 1string -- weight-levels-pair )
    first
    {
        { [ dup tangut-block? ] [ [ tangut-AAAA ] [ tangut-BBBB ] bi 2array ] }
        { [ dup nushu-block? ] [ [ nushu-AAAA ] [ nushu-BBBB ] bi 2array ] }
        { [ dup khitan-block? ] [ [ khitan-AAAA ] [ khitan-BBBB ] bi 2array ] }
        [ [ AAAA ] [ BBBB ] bi 2array ]
    } cond ;

: building-last ( -- char )
    building get [ 0 ] [ last last ] if-empty ;

! https://www.unicode.org/reports/tr10/tr10-41.html#Collation_Graphemes
: blocked? ( char -- ? )
    combining-class dup { 0 f } member?
    [ drop building-last non-starter? ]
    [ building-last combining-class = ] if ;

: possible-bases ( -- slice-of-building )
    building get dup [ first non-starter? not ] find-last
    drop [ 0 ] unless* tail-slice ;

:: ?combine ( char slice i -- ? )
    i slice nth char suffix :> str
    str ducet get-global key? dup
    [ str i slice set-nth ] when ;

: add ( char -- )
    dup blocked? [ 1string , ] [
        dup possible-bases dup length <iota>
        [ ?combine ] 2with any?
        [ drop ] [ 1string , ] if
    ] if ;

: string>graphemes ( string -- graphemes )
    [ [ add ] each ] { } make ;

: char>weight-levels ( 1string -- weight-levels )
    ducet get-global ?at [ derive-weight ] unless ; inline

: graphemes>weights ( graphemes -- weights )
    [
        dup weight-levels?
        [ 1array ] ! From tailoring
        [ char>weight-levels ] if
    ] { } map-as concat ;

: append-weights ( weight-levels quot -- seq )
    [ [ ignorable?>> ] reject ] dip
    map [ zero? ] reject ; inline

: variable-weight ( weight-levels -- obj )
    dup ignorable?>> [ primary>> ] [ drop 0xFFFF ] if ;

: weights>bytes ( weights -- array )
    [
        {
            [ [ primary>> ] append-weights { 0 } ]
            [ [ secondary>> ] append-weights { 0 } ]
            [ [ tertiary>> ] append-weights { 0 } ]
            [ [ [ secondary>> ] [ tertiary>> ] bi [ zero? ] both? ] reject [ variable-weight ] map ]
        } cleave
    ] { } append-outputs-as ;

PRIVATE>

: completely-ignorable? ( weight -- ? )
    {
        [ primary>> zero? ]
        [ secondary>> zero? ]
        [ tertiary>> zero? ]
    } 1&& ;

: filter-ignorable ( weights -- weights' )
    f swap [
        [ nip ] [ primary>> zero? and ] 2bi
        [ swap ignorable?>> or ]
        [ swap completely-ignorable? or not ] 2bi
    ] filter nip ;
