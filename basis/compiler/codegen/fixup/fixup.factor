! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays byte-vectors generic assocs hashtables
io.binary kernel kernel.private math namespaces make sequences
words quotations strings alien.accessors alien.strings layouts
system combinators math.bitwise math.order
accessors growable cpu.architecture compiler.constants ;
IN: compiler.codegen.fixup

GENERIC: fixup* ( obj -- )

: compiled-offset ( -- n ) building get length ;

SYMBOL: relocation-table
SYMBOL: label-table

M: label fixup* compiled-offset >>offset drop ;

: offset-for-class ( class -- n )
    rc-absolute-cell = cell 4 ? compiled-offset swap - ;

TUPLE: label-fixup { label label } { class integer } ;

: label-fixup ( label class -- ) \ label-fixup boa , ;

: push-4 ( value vector -- )
    [ length ] [ B{ 0 0 0 0 } swap push-all ] [ underlying>> ] tri
    swap set-alien-unsigned-4 ;

: add-relocation-entry ( type class offset -- )
      { 0 24 28 } bitfield relocation-table get push-4 ;

M: label-fixup fixup*
    [ class>> dup offset-for-class ] [ label>> ] bi
    [ drop [ rt-here ] 2dip add-relocation-entry ]
    [ 3array label-table get push ]
    3bi ;

TUPLE: rel-fixup { class integer } { type integer } ;

: rel-fixup ( class type -- ) \ rel-fixup boa , ;

M: rel-fixup fixup*
    [ type>> ] [ class>> dup offset-for-class ] bi
    add-relocation-entry ;

M: integer fixup* , ;

SYMBOL: literal-table

: add-literal ( obj -- ) literal-table get push ;

: add-dlsym-literals ( symbol dll -- )
    [ string>symbol add-literal ] [ add-literal ] bi* ;

: rel-dlsym ( name dll class -- )
    [ add-dlsym-literals ] dip rt-dlsym rel-fixup ;

: rel-word ( word class -- )
    [ add-literal ] dip rt-xt rel-fixup ;

: rel-word-pic ( word class -- )
    [ add-literal ] dip rt-xt-pic rel-fixup ;

: rel-word-pic-tail ( word class -- )
    [ add-literal ] dip rt-xt-pic-tail rel-fixup ;

: rel-primitive ( word class -- )
    [ def>> first add-literal ] dip rt-primitive rel-fixup ;

: rel-immediate ( literal class -- )
    [ add-literal ] dip rt-immediate rel-fixup ;

: rel-this ( class -- )
    rt-this rel-fixup ;

: rel-here ( offset class -- )
    [ add-literal ] dip rt-here rel-fixup ;

: init-fixup ( -- )
    BV{ } clone relocation-table set
    V{ } clone label-table set ;

: resolve-labels ( labels -- labels' )
    [
        first3 offset>>
        [ "Unresolved label" throw ] unless*
        3array
    ] map concat ;

: fixup ( fixup-directives -- code )
    [
        init-fixup
        [ fixup* ] each
        literal-table get >array
        relocation-table get >byte-array
        label-table get resolve-labels
    ] B{ } make 4array ;
