! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors binary-search combinators
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals fry hints kernel locals
math math.order namespaces sequences ;
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

:: split-uses ( uses n -- before after )
    uses n uses [ n>> <=> ] with search
    n>> n <=> {
        { +eq+ [ [ head-slice ] [ 1 + tail-slice ] 2bi ] }
        { +lt+ [ 1 + cut-slice ] }
        { +gt+ [ cut-slice ] }
    } case ;

ERROR: splitting-too-early ;

ERROR: splitting-too-late ;

ERROR: splitting-atomic-interval ;

: check-split ( live-interval n -- )
    check-allocation? get [
        [ [ start>> ] dip > [ splitting-too-early ] when ]
        [ [ end>> ] dip < [ splitting-too-late ] when ]
        [ drop [ end>> ] [ start>> ] bi = [ splitting-atomic-interval ] when ]
        2tri
    ] [ 2drop ] if ; inline

: split-before ( before -- before' )
    f >>spill-to ; inline

: split-after ( after -- after' )
    f >>reg f >>reload-from ; inline

:: split-interval ( live-interval n -- before after )
    live-interval n check-split
    live-interval clone :> before
    live-interval clone :> after
    live-interval uses>> n split-uses before after [ uses<< ] bi-curry@ bi*
    live-interval ranges>> n split-ranges before after [ ranges<< ] bi-curry@ bi*
    before split-before
    after split-after ;

HINTS: split-interval live-interval object ;
