! Copyright (C) 2007, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel make math math.parser math.ranges peg
peg.private peg.search sequences strings unicode vectors ;
IN: peg.parsers

TUPLE: just-parser p1 ;

CONSTANT: just-pattern [
    dup [
        dup remaining>> empty? [ drop f ] unless
    ] when
]

M: just-parser (compile) ( parser -- quot )
    p1>> compile-parser-quot just-pattern compose ;

: just ( parser -- parser )
    just-parser boa wrap-peg ;

: 1token ( ch -- parser ) 1string token ;

: (list-of) ( items separator repeat1? -- parser )
    [ over 2seq ] dip [ repeat1 ] [ repeat0 ] if
    [ concat ] action 2seq
    [ unclip 1vector swap first append ] action ;

: list-of ( items separator -- parser )
    hide f (list-of) ;

: list-of-many ( items separator -- parser )
    hide t (list-of) ;

: epsilon ( -- parser ) V{ } token ;

: any-char ( -- parser ) [ drop t ] satisfy ;

<PRIVATE

: flatten-vectors ( pair -- vector )
    first2 append! ;

PRIVATE>

: exactly-n ( parser n -- parser' )
    swap <repetition> seq ;

: at-most-n ( parser n -- parser' )
    [
        drop epsilon
    ] [
        [ exactly-n ] [ 1 - at-most-n ] 2bi 2choice
    ] if-zero ;

: at-least-n ( parser n -- parser' )
    dupd exactly-n swap repeat0 2seq
    [ flatten-vectors ] action ;

: from-m-to-n ( parser m n -- parser' )
    [ [ exactly-n ] 2keep ] dip swap - at-most-n 2seq
    [ flatten-vectors ] action ;

: pack ( begin body end -- parser )
    [ hide ] [ ] [ hide ] tri* 3seq [ first ] action ;

: surrounded-by ( parser begin end -- parser' )
    [ token ] bi@ swapd pack ;

: digit-parser ( -- parser )
    [ digit? ] satisfy [ digit> ] action ;

: integer-parser ( -- parser )
    [ digit? ] satisfy repeat1 [ string>number ] action ;

: string-parser ( -- parser )
    [
        [ CHAR: \" = ] satisfy hide ,
        [ CHAR: \" = not ] satisfy repeat0 ,
        [ CHAR: \" = ] satisfy hide ,
    ] seq* [ first >string ] action ;

: (range-pattern) ( pattern -- string )
    ! Given a range pattern, produce a string containing
    ! all characters within that range.
    [
        any-char ,
        [ CHAR: - = ] satisfy hide ,
        any-char ,
    ] seq* [
        first2 [a,b] >string
    ] action
    replace ;

: range-pattern ( pattern -- parser )
    ! 'pattern' is a set of characters describing the
    ! parser to be produced. Any single character in
    ! the pattern matches that character. If the pattern
    ! begins with a ^ then the set is negated (the element
    ! matches any character not in the set). Any pair of
    ! characters separated with a dash (-) represents the
    ! range of characters from the first to the second,
    ! inclusive.
    dup first CHAR: ^ = [
        rest (range-pattern) [ member? not ] curry satisfy
    ] [
        (range-pattern) [ member? ] curry satisfy
    ] if ;
