! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private alien.accessors sequences
sequences.private math math.private byte-arrays accessors
alien.c-types parser prettyprint.backend combinators ;
IN: float-arrays

TUPLE: float-array
{ length array-capacity read-only }
{ underlying byte-array read-only } ;

: <float-array> ( n -- float-array )
    dup "double" <c-array> float-array boa ; inline

M: float-array clone
    [ length>> ] [ underlying>> clone ] bi float-array boa ;

M: float-array length length>> ;

M: float-array nth-unsafe
    underlying>> double-nth ;

M: float-array set-nth-unsafe
    [ >float ] 2dip underlying>> set-double-nth ;

: >float-array ( seq -- float-array )
    T{ float-array } clone-like ; inline

M: float-array like
    drop dup float-array? [ >float-array ] unless ;

M: float-array new-sequence
    drop <float-array> ;

M: float-array equal?
    over float-array? [ sequence= ] [ 2drop f ] if ;

M: float-array resize
    [ drop ] [
        [ "double" heap-size * ] [ underlying>> ] bi*
        resize-byte-array
    ] 2bi
    float-array boa ;

M: float-array byte-length length "double" heap-size * ;

INSTANCE: float-array sequence

: 1float-array ( x -- array )
    1 <float-array> [ set-first ] keep ; inline

: 2float-array ( x y -- array )
    T{ float-array } 2sequence ; inline

: 3float-array ( x y z -- array )
    T{ float-array } 3sequence ; inline

: 4float-array ( w x y z -- array )
    T{ float-array } 4sequence ; inline

: F{ \ } [ >float-array ] parse-literal ; parsing

M: float-array pprint-delims drop \ F{ \ } ;
M: float-array >pprint-sequence ;
M: float-array pprint* pprint-object ;

! Specializer hints
USING: hints math.vectors arrays ;

HINTS: <float-array> { 2 } { 3 } ;

HINTS: vneg { array } { float-array } ;
HINTS: v*n { array object } { float-array float } ;
HINTS: n*v { array object } { float float-array } ;
HINTS: v/n { array object } { float-array float } ;
HINTS: n/v { object array } { float float-array } ;
HINTS: v+ { array array } { float-array float-array } ;
HINTS: v- { array array } { float-array float-array } ;
HINTS: v* { array array } { float-array float-array } ;
HINTS: v/ { array array } { float-array float-array } ;
HINTS: vmax { array array } { float-array float-array } ;
HINTS: vmin { array array } { float-array float-array } ;
HINTS: v. { array array } { float-array float-array } ;
HINTS: norm-sq { array } { float-array } ;
HINTS: norm { array } { float-array } ;
HINTS: normalize { array } { float-array } ;
HINTS: distance { array array } { float-array float-array } ;

! Type functions
USING: words classes.algebra compiler.tree.propagation.info
math.intervals ;

{ v+ v- v* v/ vmax vmin } [
    [
        [ class>> float-array class<= ] both?
        float-array object ? <class-info>
    ] "outputs" set-word-prop
] each

{ n*v n/v } [
    [
        nip class>> float-array class<= float-array object ? <class-info>
    ] "outputs" set-word-prop
] each

{ v*n v/n } [
    [
        drop class>> float-array class<= float-array object ? <class-info>
    ] "outputs" set-word-prop
] each

{ vneg normalize } [
    [
        class>> float-array class<= float-array object ? <class-info>
    ] "outputs" set-word-prop
] each

\ norm-sq [
    class>> float-array class<= [ float 0. 1/0. [a,b] <class/interval-info> ] [ object-info ] if
] "outputs" set-word-prop

\ v. [
    [ class>> float-array class<= ] both?
    float object ? <class-info>
] "outputs" set-word-prop

\ distance [
    [ class>> float-array class<= ] both?
    [ float 0. 1/0. [a,b] <class/interval-info> ] [ object-info ] if
] "outputs" set-word-prop
