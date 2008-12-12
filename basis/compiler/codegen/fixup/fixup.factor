! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays byte-vectors generic assocs hashtables
io.binary kernel kernel.private math namespaces make sequences
words quotations strings alien.accessors alien.strings layouts
system combinators math.bitwise words.private math.order
accessors growable cpu.architecture compiler.constants ;
IN: compiler.codegen.fixup

GENERIC: fixup* ( obj -- )

: code-format ( -- n ) 22 getenv ;

: compiled-offset ( -- n ) building get length code-format * ;

SYMBOL: relocation-table
SYMBOL: label-table

M: label fixup* compiled-offset >>offset drop ;

TUPLE: label-fixup label class ;

: label-fixup ( label class -- ) \ label-fixup boa , ;

M: label-fixup fixup*
    dup class>> rc-absolute?
    [ "Absolute labels not supported" throw ] when
    [ label>> ] [ class>> ] bi compiled-offset 4 - rot
    3array label-table get push ;

TUPLE: rel-fixup arg class type ;

: rel-fixup ( arg class type -- ) \ rel-fixup boa , ;

: push-4 ( value vector -- )
    [ length ] [ B{ 0 0 0 0 } swap push-all ] [ underlying>> ] tri
    swap set-alien-unsigned-4 ;

M: rel-fixup fixup*
    [ [ arg>> ] [ class>> ] [ type>> ] tri { 0 8 16 } bitfield ]
    [ class>> rc-absolute-cell = cell 4 ? compiled-offset swap - ] bi
    [ relocation-table get push-4 ] bi@ ;

M: integer fixup* , ;

: indq ( elt seq -- n ) [ eq? ] with find drop ;

: adjoin* ( obj table -- n )
    2dup indq [ 2nip ] [ dup length [ push ] dip ] if* ;

SYMBOL: literal-table

: add-literal ( obj -- n ) literal-table get adjoin* ;

: add-dlsym-literals ( symbol dll -- )
    [ string>symbol ] dip 2array literal-table get push-all ;

: rel-dlsym ( name dll class -- )
    [ literal-table get length [ add-dlsym-literals ] dip ] dip
    rt-dlsym rel-fixup ;

: rel-word ( word class -- )
    [ add-literal ] dip rt-xt rel-fixup ;

: rel-primitive ( word class -- )
    [ def>> first ] dip rt-primitive rel-fixup ;

: rel-immediate ( literal class -- )
    [ add-literal ] dip rt-immediate rel-fixup ;

: rel-this ( class -- )
    0 swap rt-label rel-fixup ;

: rel-here ( offset class -- )
    rt-here rel-fixup ;

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
    ] { } make 4array ;
