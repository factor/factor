! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences io.files io.encodings.ascii kernel splitting
accessors math.parser ascii io assocs strings math namespaces make
sorting combinators math.order arrays unicode.normalize unicode.data
locals macros sequences.deep words unicode.breaks quotations
combinators.short-circuit simple-flat-file ;
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
    data [ [ parse-keys ] [ parse-weight ] bi* ] H{ } assoc-map-as ;

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

: base ( char -- base )
    {
        { [ dup 0x3400 0x4DB5 between? ] [ drop 0xFB80 ] } ! Extension A
        { [ dup 0x20000 0x2A6D6 between? ] [ drop 0xFB80 ] } ! Extension B
        { [ dup 0x4E00 0x9FC3 between? ] [ drop 0xFB40 ] } ! CJK
        [ drop 0xFBC0 ] ! Other
    } cond ;

: AAAA ( char -- weight )
    [ base ] [ -15 shift ] bi + 0x20 2 f weight boa ;

: BBBB ( char -- weight )
    0x7FFF bitand 0x8000 bitor 0 0 f weight boa ;

: illegal? ( char -- ? )
    { [ "Noncharacter_Code_Point" property? ] [ category "Cs" = ] } 1|| ;

: derive-weight ( char -- weights )
    first dup illegal?
    [ drop { } ]
    [ [ AAAA ] [ BBBB ] bi 2array ] if ;

: building-last ( -- char )
    building get empty? [ 0 ] [ building get last last ] if ;

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
        dup possible-bases dup length iota
        [ ?combine ] with with any?
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
    [ [ ignorable?>> not ] filter ] dip
    map [ zero? not ] filter % 0 , ; inline

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
    [ primary>> ] [ secondary>> ] [ tertiary>> ] tri
    [ zero? ] tri@ and and ;

: filter-ignorable ( weights -- weights' )
    f swap [
        [ nip ] [ primary>> zero? and ] 2bi
        [ swap ignorable?>> or ]
        [ swap completely-ignorable? or not ] 2bi
    ] filter nip ;

: collation-key ( string -- key )
    nfd string>graphemes graphemes>weights
    filter-ignorable weights>bytes ;

<PRIVATE
: insensitive= ( str1 str2 levels-removed -- ? )
    [
        [ collation-key ] dip
        [ [ 0 = not ] trim-tail but-last ] times
    ] curry same? ;
PRIVATE>

: primary= ( str1 str2 -- ? )
    3 insensitive= ;

: secondary= ( str1 str2 -- ? )
    2 insensitive= ;

: tertiary= ( str1 str2 -- ? )
    1 insensitive= ;

: quaternary= ( str1 str2 -- ? )
    0 insensitive= ;

: w/collation-key ( str -- {str,key} )
    [ collation-key ] keep 2array ;

: sort-strings ( strings -- sorted )
    [ w/collation-key ] map natural-sort values ;

: string<=> ( str1 str2 -- <=> )
    [ w/collation-key ] compare ;
