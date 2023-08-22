! Copyright (C) 2007, 2008 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel literals make math math.parser
ranges peg peg.private sequences splitting strings unicode
vectors ;
FROM: peg.search => replace ;
IN: peg.parsers

<PRIVATE

TUPLE: just-parser p1 ;

M: just-parser parser-quot
    p1>> execute-parser-quot [
        dup [
            dup remaining>> empty? [ drop f ] unless
        ] when
    ] compose ;

PRIVATE>

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

CONSTANT: epsilon $[ V{ } token ]

CONSTANT: any-char $[ [ drop t ] satisfy ]

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
        first2 [a..b] >string
    ] action replace ;

: range-pattern ( pattern -- parser )
    ! 'pattern' is a set of characters describing the
    ! parser to be produced. Any single character in
    ! the pattern matches that character. If the pattern
    ! begins with a ^ then the set is negated (the element
    ! matches any character not in the set). Any pair of
    ! characters separated with a dash (-) represents the
    ! range of characters from the first to the second,
    ! inclusive.
    "^" ?head [
        (range-pattern) dup length 1 =
        [ first '[ _ = ] ] [ '[ _ member? ] ] if
    ] [
        [ [ not ] compose ] when satisfy
    ] bi* ;
