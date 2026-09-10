! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays binary-search io.encodings.utf8 kernel
locals math math.order sequences strings vectors ;
IN: ui.text.index-maps

! Sparse maps record only characters that occupy more than one native unit.
! ASCII strings have no auxiliary storage and require neither a scan nor a map.
TUPLE: text-index-map positions native-ends extras ;

:: <text-index-map> ( string width-quot -- map )
    V{ } clone :> positions
    V{ } clone :> ends
    V{ } clone :> extras
    0 :> extra!
    string aux>> [
        string [| ch i |
            ch width-quot call 1 - :> added
            added 0 > [
                extra added + extra!
                i positions push
                i 1 + extra + ends push
                extra extras push
            ] when
        ] each-index
    ] when
    positions ends extras text-index-map boa ; inline

: <utf8-index-map> ( string -- map )
    [ code-point-length ] <text-index-map> ;

: <utf16-index-map> ( string -- map )
    [ 0xffff > 2 1 ? ] <text-index-map> ;

:: positions-before ( n positions -- count )
    n positions natural-search :> ( i value )
    value [ i value n < [ 1 + ] when ] [ 0 ] if ;

: extra-at ( count map -- extra )
    extras>> over zero? [ 2drop 0 ] [ swap 1 - swap nth ] if ;

:: codepoint>native ( n map -- index )
    n n map positions>> positions-before map extra-at + ;

:: native>codepoint ( index map -- n )
    index 0 max :> clamped
    ! Count completed multibyte characters, flooring positions inside one.
    clamped 1 + map native-ends>> positions-before :> count
    clamped count map extra-at - :> candidate
    count map positions>> length < [
        candidate count map positions>> nth min
    ] [ candidate ] if ;
