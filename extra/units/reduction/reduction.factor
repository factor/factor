! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators continuations fry kernel lexer locals
math math.functions math.order math.parser sequences splitting ;
IN: units.reduction

CONSTANT: storage-suffixes { "B" "K" "M" "G" "T" "P" "E" "Z" "Y" }

CONSTANT: unit-suffix-hash H{
        { ch'B 0 } { ch'K 1 } { ch'M 2 } { ch'G 3 }
        { ch'T 4 } { ch'P 5 } { ch'E 6 } { ch'Z 7 }
        { ch'Y 8 }
    }

: threshhold ( n multiplier base -- x )
    [ * ] dip swap ^ ; inline

:: find-unit-suffix ( suffixes n multiplier base -- i/f )
    suffixes length [
        [ [ n ] dip multiplier base threshhold < ] find-integer
    ] keep or 1 [-] ;

:: reduce-magnitude ( n multiplier base suffixes -- string )
    n 0 < [
        n neg multiplier base suffixes reduce-magnitude
        "-" prepend
    ] [
        suffixes n multiplier base find-unit-suffix :> i
        n multiplier i * base swap ^
        /i number>string i suffixes nth append
    ] if ;

: n>storage ( n -- string )
    10 2 storage-suffixes reduce-magnitude "i" append ;

: n>Storage ( n -- string )
    3 10 storage-suffixes reduce-magnitude ;

ERROR: bad-storage-string string reason ;

:: (storage>n) ( string multiplier base -- n )
    string last unit-suffix-hash ?at [
        :> unit
        string but-last string>number
        [ "not a number" throw ] unless*
        multiplier unit * base swap ^ *
    ] [
        "unrecognized unit" throw
    ] if ;

: storage>n ( string -- n )
    [ "i" ?tail [ 10 2 (storage>n) ] [ 3 10 (storage>n) ] if ]
    [ \ bad-storage-string boa rethrow ] recover ;

: n>money ( n -- string )
    3 10 { "" "K" "M" "B" "T" } reduce-magnitude ;

SYNTAX: \STORAGE: scan-token storage>n suffix! ;
