! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.strings alien.c-types alien.data alien.accessors
arrays words sequences math kernel namespaces fry cpu.architecture
io.encodings.utf8 accessors ;
IN: alien.arrays

INSTANCE: array value-type

M: array c-type ;

M: array c-type-class drop object ;

M: array c-type-boxed-class drop object ;

: array-length ( seq -- n )
    [ dup word? [ def>> call( -- object ) ] when ] [ * ] map-reduce ;

M: array heap-size unclip [ array-length ] [ heap-size ] bi* * ;

M: array c-type-align first c-type-align ;

M: array c-type-align-first first c-type-align-first ;

M: array c-type-stack-align? drop f ;

M: array unbox-parameter drop void* unbox-parameter ;

M: array unbox-return drop void* unbox-return ;

M: array box-parameter drop void* box-parameter ;

M: array box-return drop void* box-return ;

M: array stack-size drop void* stack-size ;

M: array c-type-boxer-quot
    unclip
    [ array-length ]
    [ [ require-c-array ] keep ] bi*
    [ <c-direct-array> ] 2curry ;

M: array c-type-unboxer-quot drop [ >c-ptr ] ;

PREDICATE: string-type < pair
    first2 [ char* = ] [ word? ] bi* and ;

M: string-type c-type ;

M: string-type c-type-class drop object ;

M: string-type c-type-boxed-class drop object ;

M: string-type heap-size
    drop void* heap-size ;

M: string-type c-type-align
    drop void* c-type-align ;

M: string-type c-type-align-first
    drop void* c-type-align-first ;

M: string-type c-type-stack-align?
    drop void* c-type-stack-align? ;

M: string-type unbox-parameter
    drop void* unbox-parameter ;

M: string-type unbox-return
    drop void* unbox-return ;

M: string-type box-parameter
    drop void* box-parameter ;

M: string-type box-return
    drop void* box-return ;

M: string-type stack-size
    drop void* stack-size ;

M: string-type c-type-rep
    drop int-rep ;

M: string-type c-type-boxer
    drop void* c-type-boxer ;

M: string-type c-type-unboxer
    drop void* c-type-unboxer ;

M: string-type c-type-boxer-quot
    second '[ _ alien>string ] ;

M: string-type c-type-unboxer-quot
    second '[ _ string>alien ] ;

M: string-type c-type-getter
    drop [ alien-cell ] ;

M: string-type c-type-setter
    drop [ set-alien-cell ] ;

{ char* utf8 } char* typedef
char* uchar* typedef

char char* "pointer-c-type" set-word-prop
uchar uchar* "pointer-c-type" set-word-prop
