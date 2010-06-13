! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays bit-arrays byte-arrays byte-vectors generic assocs
hashtables io.binary kernel kernel.private math namespaces make
sequences words quotations strings alien.accessors alien.strings
layouts system combinators math.bitwise math.order
combinators.smart accessors growable fry compiler.constants
memoize boxes ;
IN: compiler.codegen.fixup

! Utilities
: push-uint ( value vector -- )
    [ length ] [ B{ 0 0 0 0 } swap push-all ] [ underlying>> ] tri
    swap set-alien-unsigned-4 ;

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

: add-relocation-entry ( type class offset -- )
    { 0 24 28 } bitfield relocation-table get push-uint ;

: rel-fixup ( class type -- )
    swap compiled-offset add-relocation-entry ;

! Binary literal table
SYMBOL: binary-literal-table

: add-binary-literal ( obj -- label )
    <label> [ 2array binary-literal-table get push ] keep ;

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

: rel-binary-literal ( literal class -- )
    [ add-binary-literal ] dip label-fixup ;

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

! Labels
: compute-target ( label-fixup -- offset )
    label>> offset>> [ "Unresolved label" throw ] unless* ;

: compute-relative-label ( label-fixup -- label )
    [ class>> ] [ offset>> ] [ compute-target ] tri 3array ;

: compute-absolute-label ( label-fixup -- )
    [ compute-target neg add-literal ]
    [ [ rt-here ] dip [ class>> ] [ offset>> ] bi add-relocation-entry ] bi ;

: compute-labels ( label-fixups -- labels' )
    [ class>> rc-absolute? ] partition
    [ [ compute-absolute-label ] each ]
    [ [ compute-relative-label ] map concat ]
    bi* ;

! Binary literals
: alignment ( align -- n )
    [ compiled-offset dup ] dip align swap - ;

: (align-code) ( n -- )
    0 <repetition> % ;

: align-code ( n -- )
    alignment (align-code) ;

: emit-data ( obj label -- )
    over length align-code
    resolve-label
    building get push-all ;

: emit-binary-literals ( -- )
    binary-literal-table get [ emit-data ] assoc-each ;

! GC info

! Every code block either ends with
!
! uint 0
!
! or
!
! bitmap, byte aligned, three subsequences:
! - <scrubbed data stack locations>
! - <scrubbed retain stack locations>
! - <GC root spill slots>
! uint[] <return addresses>
! uint <largest scrubbed data stack location>
! uint <largest scrubbed retain stack location>
! uint <largest GC root spill slot>
! uint <number of return addresses>

SYMBOLS: next-gc-map return-addresses gc-maps ;

: gc-map? ( triple -- ? )
    ! If there are no stack locations to scrub and no GC roots,
    ! there's no point storing the GC map.
    [ empty? not ] any? ;

: gc-map-here ( -- )
    next-gc-map get box> dup gc-map? [
        gc-maps get push
        compiled-offset return-addresses get push
    ] [ drop ] if ;

: set-next-gc-map ( gc-map -- ) next-gc-map get >box ;

: integers>bits ( seq n -- bit-array )
    <bit-array> [ '[ [ t ] dip _ set-nth ] each ] keep ;

: emit-bitmap ( seqs -- n )
    ! seqs is a sequence of sequences of integers 0..n-1
    [ 0 ] [
        dup [ [ 0 ] [ supremum 1 + ] if-empty ] [ max ] map-reduce
        [ '[ _ integers>bits % ] each ] keep
    ] if-empty ;

: emit-uint ( n -- )
    building get push-uint ;

: gc-info ( -- byte-array )
    [
        return-addresses get empty? [ 0 emit-uint ] [
            gc-maps get
            [
                [ [ first ] map emit-bitmap ]
                [ [ second ] map emit-bitmap ]
                [ [ third ] map emit-bitmap ] tri
            ] ?{ } make underlying>> %
            return-addresses get [ emit-uint ] each
            [ emit-uint ] tri@
            return-addresses get length emit-uint
        ] if
    ] B{ } make ;

: emit-gc-info ( -- )
    ! We want to place the GC info so that the end is aligned
    ! on a 16-byte boundary.
    gc-info [
        length compiled-offset +
        [ data-alignment get align ] keep -
        (align-code)
    ] [ % ] bi ;

: init-fixup ( -- )
    V{ } clone parameter-table set
    V{ } clone literal-table set
    V{ } clone label-table set
    BV{ } clone relocation-table set
    V{ } clone binary-literal-table set
    V{ } clone return-addresses set
    V{ } clone gc-maps set
    <box> next-gc-map set ;

: check-fixup ( seq -- )
    length data-alignment get mod 0 assert=
    next-gc-map get occupied>> f assert= ;

: with-fixup ( quot -- code )
    '[
        init-fixup
        [
            @
            emit-binary-literals
            emit-gc-info
            label-table [ compute-labels ] change
            parameter-table get >array
            literal-table get >array
            relocation-table get >byte-array
            label-table get
        ] B{ } make
        dup check-fixup
    ] output>array ; inline
