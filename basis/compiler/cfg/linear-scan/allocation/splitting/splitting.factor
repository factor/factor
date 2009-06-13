! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry hints kernel locals
math sequences sets sorting splitting
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.allocation.splitting

: split-range ( live-range n -- before after )
    [ [ from>> ] dip <live-range> ]
    [ 1 + swap to>> <live-range> ]
    2bi ;

: split-last-range? ( last n -- ? )
    swap to>> <= ;

: split-last-range ( before after last n -- before' after' )
    split-range [ [ but-last ] dip suffix ] [ prefix ] bi-curry* bi* ;

: split-ranges ( live-ranges n -- before after )
    [ '[ from>> _ <= ] partition ]
    [
        [ over last ] dip 2dup split-last-range?
        [ split-last-range ] [ 2drop ] if
    ] bi ;

: split-uses ( uses n -- before after )
    '[ _ <= ] partition ;

: record-split ( live-interval before after -- )
    [ >>split-next drop ]
    [ [ >>split-before ] [ >>split-after ] bi* drop ]
    2bi ; inline

ERROR: splitting-too-early ;

ERROR: splitting-atomic-interval ;

: check-split ( live-interval n -- )
    [ [ start>> ] dip > [ splitting-too-early ] when ]
    [ drop [ end>> ] [ start>> ] bi - 0 = [ splitting-atomic-interval ] when ]
    2bi ; inline

: split-before ( before -- before' )
    f >>spill-to ; inline

: split-after ( after -- after' )
    f >>copy-from f >>reg f >>reload-from ; inline

:: split-interval ( live-interval n -- before after )
    live-interval n check-split
    live-interval clone :> before
    live-interval clone :> after
    live-interval uses>> n split-uses before after [ (>>uses) ] bi-curry@ bi*
    live-interval ranges>> n split-ranges before after [ (>>ranges) ] bi-curry@ bi*
    live-interval before after record-split
    before split-before
    after split-after ;

HINTS: split-interval live-interval object ;

: reuse-register ( new existing -- )
    reg>> >>reg add-active ;

: relevant-ranges ( new inactive -- new' inactive' )
    ! Slice off all ranges of 'inactive' that precede the start of 'new'
    [ [ ranges>> ] bi@ ] [ nip start>> ] 2bi '[ to>> _ >= ] filter ;

: intersect-live-range ( range1 range2 -- n/f )
    2dup [ from>> ] bi@ > [ swap ] when
    2dup [ to>> ] [ from>> ] bi* >= [ nip from>> ] [ 2drop f ] if ;

: intersect-live-ranges ( ranges1 ranges2 -- n )
    {
        { [ over empty? ] [ 2drop 1/0. ] }
        { [ dup empty? ] [ 2drop 1/0. ] }
        [
            2dup [ first ] bi@ intersect-live-range dup [ 2nip ] [
                drop
                2dup [ first from>> ] bi@ <
                [ [ rest-slice ] dip ] [ rest-slice ] if
                intersect-live-ranges
            ] if
        ]
    } cond ;

: intersect-inactive ( new inactive active-regs -- n/f )
    ! If the interval's register is currently in use, we cannot
    ! re-use it.
    2dup [ reg>> ] dip key?
    [ 3drop f ] [ drop relevant-ranges intersect-live-ranges ] if ;

: intersecting-inactive ( new -- live-intervals )
    dup vreg>>
    [ inactive-intervals-for ]
    [ active-intervals-for [ reg>> ] map unique ] bi
    '[ tuck _ intersect-inactive ] with { } map>assoc
    [ nip ] assoc-filter ;

: insert-use-for-copy ( seq n -- seq' )
    [ 1array split1 ] keep [ 1 - ] keep 2array glue ;

: split-before-use ( new n -- before after )
    ! Find optimal split position
    ! Insert move instruction
    [ '[ _ insert-use-for-copy ] change-uses ] keep
    1 - split-interval
    2dup [ compute-start/end ] bi@ ;

: assign-inactive-register ( new live-intervals -- )
    ! If there is an interval which is inactive for the entire lifetime
    ! if the new interval, reuse its vreg. Otherwise, split new so that
    ! the first half fits.
    sort-values last
    2dup [ end>> ] [ second ] bi* < [
        first reuse-register
    ] [
        [ second split-before-use ] keep
        '[ _ first reuse-register ] [ add-unhandled ] bi*
    ] if ;