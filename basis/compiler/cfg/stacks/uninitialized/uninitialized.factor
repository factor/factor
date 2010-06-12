! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences byte-arrays namespaces accessors classes math
math.order fry arrays combinators compiler.cfg.registers
compiler.cfg.instructions compiler.cfg.dataflow-analysis ;
IN: compiler.cfg.stacks.uninitialized

! Uninitialized stack location analysis.

! Consider the following sequence of instructions:
! ##inc-d 2
! ##gc
! ##replace ... D 0
! ##replace ... D 1
! The GC check runs before stack locations 0 and 1 have been initialized,
! and it needs to zero them out so that GC doesn't try to trace them.

<PRIVATE

GENERIC: visit-insn ( insn -- )

: handle-inc ( n symbol -- )
    [
        swap {
            { [ dup 0 < ] [ neg short tail ] }
            { [ dup 0 > ] [ <byte-array> prepend ] }
        } cond
    ] change ;

M: ##inc-d visit-insn n>> ds-loc handle-inc ;

M: ##inc-r visit-insn n>> rs-loc handle-inc ;

ERROR: uninitialized-peek insn ;

: visit-peek ( ##peek -- )
    dup loc>> [ n>> ] [ class get ] bi ?nth 0 =
    [ uninitialized-peek ] [ drop ] if ; inline

M: ##peek visit-insn visit-peek ;

: visit-replace ( ##replace -- )
    loc>> [ n>> ] [ class get ] bi
    2dup length < [ [ 1 ] 2dip set-nth ] [ 2drop ] if ;

M: ##replace visit-insn visit-replace ;
M: ##replace-imm visit-insn visit-replace ;

M: insn visit-insn drop ;

: prepare ( pair -- )
    [ first2 [ [ clone ] [ B{ } ] if* ] bi@ ] [ B{ } B{ } ] if*
    [ ds-loc set ] [ rs-loc set ] bi* ;

: visit-block ( bb -- ) instructions>> [ visit-insn ] each ;

: finish ( -- pair ) ds-loc get rs-loc get 2array ;

: (join-sets) ( seq1 seq2 -- seq )
    2dup [ length ] bi@ max '[ _ 1 pad-tail ] bi@ [ bitand ] 2map ;

: (uninitialized-locs) ( seq quot -- seq' )
    [ [ drop 0 = ] selector [ each-index ] dip ] dip map ; inline

PRIVATE>

FORWARD-ANALYSIS: uninitialized

M: uninitialized-analysis transfer-set ( pair bb analysis -- pair' )
    drop [ prepare ] dip visit-block finish ;

M: uninitialized-analysis join-sets ( sets analysis -- pair )
    2drop sift [ f ] [ [ ] [ [ (join-sets) ] 2map ] map-reduce ] if-empty ;

: uninitialized-locs ( bb -- locs )
    uninitialized-in dup [
        first2
        [ [ <ds-loc> ] (uninitialized-locs) ]
        [ [ <rs-loc> ] (uninitialized-locs) ]
        bi* append f like
    ] when ;
