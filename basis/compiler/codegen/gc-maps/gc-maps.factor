! Copyright (C) 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays combinators
combinators.short-circuit compiler.cfg.instructions
compiler.codegen.relocation cpu.architecture fry kernel layouts
make math math.order namespaces sequences ;
IN: compiler.codegen.gc-maps

! GC maps                                                       

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
! uint[] <base pointers>
! uint[] <return addresses>
! uint <largest scrubbed data stack location>
! uint <largest scrubbed retain stack location>
! uint <largest GC root spill slot>
! uint <largest derived root spill slot>
! int <number of return addresses>

SYMBOLS: return-addresses gc-maps ;

: gc-map-needed? ( gc-map -- ? )
    ! If there are no stack locations to scrub and no GC roots,
    ! there's no point storing the GC map.
    dup [
        {
            [ scrub-d>> empty? ]
            [ scrub-r>> empty? ]
            [ gc-roots>> empty? ]
            [ derived-roots>> empty? ]
        } 1&& not
    ] when ;

: gc-map-here ( gc-map -- )
    dup gc-map-needed? [
        gc-maps get push
        compiled-offset return-addresses get push
    ] [ drop ] if ;

: emit-scrub ( seqs -- n )
    ! seqs is a sequence of sequences of 0/1
    dup longest length
    [ '[ [ 0 = ] ?{ } map-as _ f pad-tail % ] each ] keep ;

: integers>bits ( seq n -- bit-array )
    <bit-array> [ '[ [ t ] dip _ set-nth ] each ] keep ;

: largest-spill-slot ( seqs -- n )
    [ [ 0 ] [ supremum 1 + ] if-empty ] [ max ] map-reduce ;

: emit-gc-roots ( seqs -- n )
    ! seqs is a sequence of sequences of integers 0..n-1
    dup largest-spill-slot
    [ '[ _ integers>bits % ] each ] keep ;

: emit-uint ( n -- )
    building get push-uint ;

: emit-uints ( n -- )
    [ emit-uint ] each ;

: gc-root-offsets ( gc-map -- offsets )
    gc-roots>> [ gc-root-offset ] map ;

: emit-gc-info-bitmaps ( -- scrub-d-count scrub-r-count gc-root-count )
    [
        gc-maps get {
            [ [ scrub-d>> ] map emit-scrub ]
            [ [ scrub-r>> ] map emit-scrub ]
            [ [ gc-root-offsets ] map emit-gc-roots ]
        } cleave
    ] ?{ } make underlying>> % ;

: emit-base-table ( alist longest -- )
    -1 <array> <enum> swap assoc-union! seq>> emit-uints ;

: derived-root-offsets ( gc-map -- offsets )
    derived-roots>> [ [ gc-root-offset ] bi@ ] assoc-map ;

: emit-base-tables ( -- count )
    gc-maps get [ derived-root-offsets ] map
    dup [ keys ] map largest-spill-slot
    [ '[ _ emit-base-table ] each ] keep ;

: emit-return-addresses ( -- )
    return-addresses get emit-uints ;

: serialize-gc-maps ( -- byte-array )
    [
        return-addresses get empty? [ 0 emit-uint ] [
            emit-gc-info-bitmaps
            emit-base-tables
            emit-return-addresses
            4array emit-uints
            return-addresses get length emit-uint
        ] if
    ] B{ } make ;

: init-gc-maps ( -- )
    V{ } clone return-addresses set
    V{ } clone gc-maps set ;

: emit-gc-maps ( -- )
    ! We want to place the GC maps so that the end is aligned
    ! on a 16-byte boundary.
    serialize-gc-maps [
        length compiled-offset +
        [ data-alignment get align ] keep -
        (align-code)
    ] [ % ] bi ;
