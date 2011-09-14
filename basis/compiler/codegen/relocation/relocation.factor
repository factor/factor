! Copyright (C) 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.strings
compiler.constants kernel make math math.bitwise memoize
namespaces sequences ;
IN: compiler.codegen.relocation

! Common code shared by optimizing and non-optimizing compilers.
! Should not have too many dependencies on the rest of the
! optimizing compiler.

! Code is compiled into the 'make' vector.

: compiled-offset ( -- n ) building get length ;

: alignment ( align -- n )
    [ compiled-offset dup ] dip align swap - ;

: (align-code) ( n -- )
    0 <repetition> % ;

: align-code ( n -- )
    alignment (align-code) ;

! Parameter table
SYMBOL: parameter-table

: add-parameter ( obj -- ) parameter-table get push ;

! Literal table
SYMBOL: literal-table

: add-literal ( obj -- ) literal-table get push ;

! Relocation table
SYMBOL: relocation-table

: push-uint ( value vector -- )
    [ length ] [ B{ 0 0 0 0 } swap push-all ] [ underlying>> ] tri
    swap set-alien-unsigned-4 ;

: add-relocation-at ( class type offset -- )
    { 0 28 24 } bitfield relocation-table get push-uint ;

: add-relocation ( class type -- )
    compiled-offset add-relocation-at ;

! Caching common symbol names reduces image size a bit
MEMO: cached-string>symbol ( symbol -- obj ) string>symbol ;

: add-dlsym-parameters ( symbol dll -- )
    [ cached-string>symbol add-parameter ] [ add-parameter ] bi* ;

: rel-dlsym ( name dll class -- )
    [ add-dlsym-parameters ] dip rt-dlsym add-relocation ;

: rel-dlsym-toc ( name dll class -- )
    [ add-dlsym-parameters ] dip rt-dlsym-toc add-relocation ;

: rel-word ( word class -- )
    [ add-literal ] dip rt-entry-point add-relocation ;

: rel-word-pic ( word class -- )
    [ add-literal ] dip rt-entry-point-pic add-relocation ;

: rel-word-pic-tail ( word class -- )
    [ add-literal ] dip rt-entry-point-pic-tail add-relocation ;

: rel-literal ( literal class -- )
    [ add-literal ] dip rt-literal add-relocation ;

: rel-this ( class -- )
    rt-this add-relocation ;

: rel-here ( offset class -- )
    [ add-literal ] dip rt-here add-relocation ;

: rel-vm ( offset class -- )
    [ add-parameter ] dip rt-vm add-relocation ;

: rel-cards-offset ( class -- )
    rt-cards-offset add-relocation ;

: rel-decks-offset ( class -- )
    rt-decks-offset add-relocation ;

: init-relocation ( -- )
    V{ } clone parameter-table set
    V{ } clone literal-table set
    BV{ } clone relocation-table set ;
