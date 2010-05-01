! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays byte-vectors generic assocs hashtables
io.binary kernel kernel.private math namespaces make sequences
words quotations strings alien.accessors alien.strings layouts
system combinators math.bitwise math.order generalizations
accessors growable fry compiler.constants memoize ;
IN: compiler.codegen.fixup

! Owner
SYMBOL: compiling-word

! Parameter table
SYMBOL: parameter-table

: add-parameter ( obj -- ) parameter-table get push ;

! Literal table
SYMBOL: literal-table

: add-literal ( obj -- ) literal-table get push ;

! Labels
SYMBOL: label-table

TUPLE: label offset ;

: <label> ( -- label ) label new ;
: define-label ( name -- ) <label> swap set ;

: compiled-offset ( -- n ) building get length ;

: resolve-label ( label/name -- )
    dup label? [ get ] unless
    compiled-offset >>offset drop ;

TUPLE: label-fixup { label label } { class integer } { offset integer } ;

: label-fixup ( label class -- )
    compiled-offset \ label-fixup boa label-table get push ;

! Relocation table
SYMBOL: relocation-table

: push-4 ( value vector -- )
    [ length ] [ B{ 0 0 0 0 } swap push-all ] [ underlying>> ] tri
    swap set-alien-unsigned-4 ;

: add-relocation-entry ( type class offset -- )
    { 0 24 28 } bitfield relocation-table get push-4 ;

: rel-fixup ( class type -- )
    swap compiled-offset add-relocation-entry ;

! Caching common symbol names reduces image size a bit
MEMO: cached-string>symbol ( symbol -- obj ) string>symbol ;

: add-dlsym-parameters ( symbol dll -- )
    [ cached-string>symbol add-parameter ] [ add-parameter ] bi* ;

: rel-dlsym ( name dll class -- )
    [ add-dlsym-parameters ] dip rt-dlsym rel-fixup ;

: rel-word ( word class -- )
    [ add-literal ] dip rt-entry-point rel-fixup ;

: rel-word-pic ( word class -- )
    [ add-literal ] dip rt-entry-point-pic rel-fixup ;

: rel-word-pic-tail ( word class -- )
    [ add-literal ] dip rt-entry-point-pic-tail rel-fixup ;

: rel-literal ( literal class -- )
    [ add-literal ] dip rt-literal rel-fixup ;

: rel-float ( literal class -- )
    [ add-literal ] dip rt-float rel-fixup ;

: rel-byte-array ( literal class -- )
    [ add-literal ] dip rt-byte-array rel-fixup ;

: rel-this ( class -- )
    rt-this rel-fixup ;

: rel-here ( offset class -- )
    [ add-literal ] dip rt-here rel-fixup ;

: rel-vm ( offset class -- )
    [ add-parameter ] dip rt-vm rel-fixup ;

: rel-cards-offset ( class -- )
    rt-cards-offset rel-fixup ;

: rel-decks-offset ( class -- )
    rt-decks-offset rel-fixup ;

! And the rest
: resolve-offset ( label-fixup -- offset )
    label>> offset>> [ "Unresolved label" throw ] unless* ;

: resolve-absolute-label ( label-fixup -- )
    dup resolve-offset neg add-literal
    [ rt-here ] dip [ class>> ] [ offset>> ] bi add-relocation-entry ;

: resolve-relative-label ( label-fixup -- label )
    [ class>> ] [ offset>> ] [ resolve-offset ] tri 3array ;

: resolve-labels ( label-fixups -- labels' )
    [ class>> rc-absolute? ] partition
    [ [ resolve-absolute-label ] each ]
    [ [ resolve-relative-label ] map concat ]
    bi* ;

: init-fixup ( word -- )
    compiling-word set
    V{ } clone parameter-table set
    V{ } clone literal-table set
    V{ } clone label-table set
    BV{ } clone relocation-table set ;

: with-fixup ( word quot -- code )
    '[
        init-fixup
        @
        label-table [ resolve-labels ] change
        parameter-table get >array
        literal-table get >array
        relocation-table get >byte-array
        label-table get
    ] B{ } make 5 narray ; inline
