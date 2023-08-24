! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.strings
arrays compiler.units cpu.architecture io.encodings.binary
io.encodings.utf8 kernel math sequences words ;
IN: alien.arrays

INSTANCE: array value-type

M: array lookup-c-type ;

M: array c-type-class drop object ;

M: array c-type-boxed-class drop object ;

: array-length ( seq -- n )
    [ dup word? [ def>> call( -- object ) ] when ] [ * ] map-reduce ;

M: array heap-size unclip [ array-length ] [ heap-size ] bi* * ;

M: array c-type-align first c-type-align ;

M: array c-type-align-first first c-type-align-first ;

M: array base-type drop void* base-type ;

PREDICATE: string-type < pair
    first2 [ c-string = ] [ word? ] bi* and ;

M: string-type lookup-c-type ;

M: string-type c-type-class drop object ;

M: string-type c-type-boxed-class drop object ;

M: string-type heap-size drop void* heap-size ;

M: string-type c-type-align drop void* c-type-align ;

M: string-type c-type-align-first drop void* c-type-align-first ;

M: string-type base-type drop void* base-type ;

M: string-type c-type-rep drop int-rep ;

M: string-type c-type-boxer-quot
    second dup binary =
    [ drop void* c-type-boxer-quot ]
    [ '[ _ alien>string ] ] if ;

M: string-type c-type-unboxer-quot
    second dup binary =
    [ drop void* c-type-unboxer-quot ]
    [ '[ _ string>alien ] ] if ;

M: string-type c-type-getter
    drop [ alien-cell ] ;

M: string-type c-type-copier
    drop [ ] ;

M: string-type c-type-setter
    drop [ set-alien-cell ] ;

[ { c-string utf8 } c-string typedef ] with-compilation-unit
