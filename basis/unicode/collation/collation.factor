! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit kernel locals make math math.order
math.parser namespaces sequences simple-flat-file splitting
strings unicode.data ;
IN: unicode.collation

<PRIVATE

SYMBOL: ducet

TUPLE: weight primary secondary tertiary ignorable? ;

: parse-weight ( string -- weight )
    "]" split but-last [
        weight new swap rest unclip CHAR: * = swapd >>ignorable?
        swap "." split first3 [ hex> ] tri@
        [ >>primary ] [ >>secondary ] [ >>tertiary ] tri*
    ] map ;

: parse-keys ( string -- chars )
    " " split [ hex> ] "" map-as ;

: parse-ducet ( file -- ducet )
    load-data-file
    [ [ parse-keys ] [ parse-weight ] bi* ] H{ } assoc-map-as ;

"vocab:unicode/collation/allkeys.txt" parse-ducet ducet set-global

! Fix up table for long contractions
: help-one ( assoc key -- )
    ! Need to be more general? Not for DUCET, apparently
    2 head 2dup swap key? [ 2drop ] [
        [ [ 1string of ] with { } map-as concat ]
        [ swap set-at ] 2bi
    ] if ;

: insert-helpers ( assoc -- )
    dup keys [ length 3 >= ] filter
    [ help-one ] with each ;

ducet get-global insert-helpers

:: base ( char -- base )
    {
        { [ char 0x03400 0x04DB5 between? ] [ 0xFB80 ] } ! Extension A
        { [ char 0x20000 0x2A6D6 between? ] [ 0xFB80 ] } ! Extension B
        { [ char 0x04E00 0x09FC3 between? ] [ 0xFB40 ] } ! CJK
        [ 0xFBC0 ] ! Other
    } cond ;

: AAAA ( char -- weight )
    [ base ] [ -15 shift ] bi + 0x20 2 f weight boa ;

: BBBB ( char -- weight )
    0x7FFF bitand 0x8000 bitor 0 0 f weight boa ;

: illegal? ( char -- ? )
    {
        [ "Noncharacter_Code_Point" property? ]
        [ category "Cs" = ]
    } 1|| ;

: derive-weight ( char -- weights )
    first dup illegal? [
        drop { }
    ] [
        [ AAAA ] [ BBBB ] bi 2array
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

: graphemes>weights ( graphemes -- weights )
    [
        dup weight? [ 1array ] ! From tailoring
        [ dup ducet get-global at [ ] [ derive-weight ] ?if ] if
    ] { } map-as concat ;

: append-weights ( weights quot -- )
    [ [ ignorable?>> ] reject ] dip map
    [ zero? ] reject % 0 , ; inline

: variable-weight ( weight -- )
    dup ignorable?>> [ primary>> ] [ drop 0xFFFF ] if , ;

: weights>bytes ( weights -- byte-array )
    [
        {
            [ [ primary>> ] append-weights ]
            [ [ secondary>> ] append-weights ]
            [ [ tertiary>> ] append-weights ]
            [ [ variable-weight ] each ]
        } cleave
    ] { } make ;

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
