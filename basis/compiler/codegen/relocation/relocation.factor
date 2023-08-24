! Copyright (C) 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.strings
compiler.constants kernel make math math.bitwise namespaces
sequences ;
IN: compiler.codegen.relocation

SYMBOL: extra-offset  ! Only used by non-optimizing compiler

: compiled-offset ( -- n )
    building get length extra-offset get + ;

: alignment ( align -- n )
    [ compiled-offset dup ] dip align swap - ;

: (align-code) ( n -- )
    0 <repetition> % ;

: align-code ( n -- )
    alignment (align-code) ;

SYMBOL: parameter-table

: add-parameter ( obj -- ) parameter-table get push ;

! Literal table
SYMBOL: literal-table

: add-literal ( obj -- ) literal-table get push ;

SYMBOL: relocation-table

: push-uint ( value vector -- )
    ! If we ever revive PowerPC support again, this needs to be
    ! changed to reverse the byte order when bootstrapping from
    ! x86 to PowerPC or vice versa
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

: rel-untagged ( literal class -- )
    [ add-literal ] dip rt-untagged add-relocation ;

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

: rel-megamorphic-cache-hits ( class -- )
    rt-megamorphic-cache-hits add-relocation ;

: rel-inline-cache-miss ( class -- )
    rt-inline-cache-miss add-relocation ;

: rel-safepoint ( class -- )
    rt-safepoint add-relocation ;

: init-relocation ( -- )
    V{ } clone parameter-table set
    V{ } clone literal-table set
    BV{ } clone relocation-table set
    0 extra-offset set ;
