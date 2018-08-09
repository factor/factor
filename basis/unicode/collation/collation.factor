! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit combinators.smart kernel locals make
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
        weight-levels new swap rest unclip ch'* = swapd >>ignorable?
        swap "." split first3 [ hex> ] tri@
        [ >>primary ] [ >>secondary ] [ >>tertiary ] tri*
    ] map ;

: parse-keys ( string -- chars )
    " " split [ hex> ] "" map-as ;

: parse-ducet ( file -- ducet )
    load-data-file [ [ parse-keys ] [ parse-weight ] bi* ] H{ } assoc-map-as ;

"vocab:unicode/UCA/allkeys.txt" parse-ducet ducet set-global

! Fix up table for long contractions
: help-one ( assoc key -- )
    ! Need to be more general? Not for DUCET, apparently
    2 head 2dup swap key? [ 2drop ] [
        [ [ 1string of ] with { } map-as concat ]
        [ swap set-at ] 2bi
    ] if ;

: insert-helpers ( assoc -- )
    dup keys [ length 3 >= ] filter [ help-one ] with each ;

ducet get-global insert-helpers

: tangut-block? ( char -- ? )
    ! Tangut Block, Tangut Components Block
    { [ 0x17000 0x187FF between? ] [ 0x18800 0x18AFF between? ] } 1|| ; inline

! Unicode TR10 - Computing Implicit Weights
: base ( char -- base )
    {
        { [ dup 0x03400 0x04DB5 between? ] [ drop 0xFB80 ] } ! Extension A
        { [ dup 0x20000 0x2A6D6 between? ] [ drop 0xFB80 ] } ! Extension B
        { [ dup 0x2A700 0x2B734 between? ] [ drop 0xFB80 ] } ! Extension C
        { [ dup 0x2B740 0x2B81D between? ] [ drop 0xFB80 ] } ! Extension D
        { [ dup 0x2B820 0x2CEA1 between? ] [ drop 0xFB80 ] } ! Extension E
        { [ dup 0x04E00 0x09FD5 between? ] [ drop 0xFB40 ] } ! CJK
        [ drop 0xFBC0 ] ! Other
    } cond ;

: tangut-AAAA ( char -- weight-levels )
    drop 0xfb00 0x0020 0x0002 <weight-levels> ; inline

: tangut-BBBB ( char -- weight-levels )
    0x17000 - 0x8000 bitor 0 0 <weight-levels> ; inline

: AAAA ( char -- weight-levels )
    [ base ] [ -15 shift ] bi + 0x0020 0x0002 <weight-levels> ; inline

: BBBB ( char -- weight-levels )
    0x7FFF bitand 0x8000 bitor 0 0 <weight-levels> ; inline

: illegal? ( char -- ? )
    {
        [ "Noncharacter_Code_Point" property? ]
        [ category "Cs" = ]
    } 1|| ;

: derive-weight ( 1string -- weight-levels-pair )
    first
    dup tangut-block? [
        [ tangut-AAAA ] [ tangut-BBBB ] bi 2array
    ] [
        first dup illegal? [
            drop { }
        ] [
            [ AAAA ] [ BBBB ] bi 2array
        ] if
    ] if ;

: building-last ( -- char )
    building get [ 0 ] [ last last ] if-empty ;

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
            [ [ [ secondary>> ] [ tertiary>> ] bi [ zero? ] bi@ and not ] filter [ variable-weight ] map ]
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
