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
    [ >>split-before ] [ >>split-after ] bi* drop ; inline

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

: split-between-blocks ( new n -- before after )
    split-interval
    2dup [ compute-start/end ] bi@ ;

: insert-use-for-copy ( seq n -- seq' )
    dup 1 + [ nip 1array split1 ] 2keep 2array glue ;

: split-before-use ( new n -- before after )
    ! Find optimal split position
    ! Insert move instruction
    1 -
    2dup swap covers? [
        [ '[ _ insert-use-for-copy ] change-uses ] keep
        split-between-blocks
        2dup >>split-next drop
    ] [
        split-between-blocks
    ] if ;